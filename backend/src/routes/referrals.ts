import { Router, Request, Response } from 'express';
import { query, transaction } from '../database/index.js';
import { logger } from '../utils/logger.js';
import { authMiddleware } from '../middleware/auth.js';
import { smsQueue, pushQueue, escalationQueue } from '../queues/index.js';
import { decrypt } from '../utils/crypto.js';
import { v4 as uuidv4 } from 'uuid';
import { z } from 'zod';

export const referralRouter = Router();

// All referral routes require authentication
referralRouter.use(authMiddleware);

// Validation schemas
const createReferralSchema = z.object({
  patientId: z.string().uuid(),
  triggerType: z.enum(['danger_sign', 'ai_score', 'manual']),
  triggerDetail: z.object({
    sign: z.string().optional(),
    value: z.string().optional(),
    description: z.string().optional(),
  }),
  vitalsSnapshot: z.record(z.any()),
  aiRiskScore: z.number().min(0).max(1).optional(),
  facilityId: z.string().uuid(),
  etaMins: z.number().optional(),
});

const updateStatusSchema = z.object({
  status: z.enum(['acknowledged', 'in_transit', 'arrived', 'outcome_recorded']),
  notes: z.string().optional(),
  outcome: z.enum(['safe_delivery', 'complication', 'death', 'false_alarm']).optional(),
});

/**
 * Create a new referral and dispatch notifications
 */
referralRouter.post('/', async (req: Request, res: Response) => {
  try {
    const validation = createReferralSchema.safeParse(req.body);
    if (!validation.success) {
      return res.status(400).json({ error: validation.error.flatten() });
    }
    
    const data = validation.data;
    const userId = req.user!.id;
    
    const referralId = uuidv4();
    
    // Create referral in transaction
    await transaction(async (client) => {
      // Insert referral
      await client.query(
        `INSERT INTO referrals (
          id, patient_id, created_by, trigger_type, trigger_detail,
          vitals_snapshot, ai_risk_score, facility_id, eta_mins, status
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 'pending')`,
        [
          referralId,
          data.patientId,
          userId,
          data.triggerType,
          JSON.stringify(data.triggerDetail),
          JSON.stringify(data.vitalsSnapshot),
          data.aiRiskScore,
          data.facilityId,
          data.etaMins,
        ]
      );
      
      // Get patient, facility, and clinician info for notifications
      const patientResult = await client.query(
        `SELECT p.*, u.device_token as hw_device_token, u.phone as hw_phone
         FROM patients p
         LEFT JOIN users u ON p.assigned_health_worker_id = u.id
         WHERE p.id = $1`,
        [data.patientId]
      );
      
      const facilityResult = await client.query(
        `SELECT f.*, u.id as clinician_id, u.device_token as clinician_device_token, 
                u.phone as clinician_phone, u.full_name as clinician_name
         FROM facilities f
         LEFT JOIN users u ON u.facility_id = f.id AND u.role = 'clinician'
         WHERE f.id = $1`,
        [data.facilityId]
      );
      
      const patient = patientResult.rows[0];
      const facility = facilityResult.rows[0];
      
      // Get patient name (decrypt if needed)
      let patientName = 'Patient';
      if (patient?.full_name_encrypted) {
        try {
          patientName = decrypt(patient.full_name_encrypted.toString());
        } catch (e) {
          patientName = 'Patient';
        }
      }
      
      // Update referral with assigned clinician
      if (facility?.clinician_id) {
        await client.query(
          `UPDATE referrals SET assigned_clinician_id = $1 WHERE id = $2`,
          [facility.clinician_id, referralId]
        );
      }
      
      // Build notification message
      const dangerSign = data.triggerDetail.sign || data.triggerDetail.description || 'Risk detected';
      const message = buildReferralMessage(
        patientName,
        dangerSign,
        data.vitalsSnapshot,
        facility?.name || 'Facility',
        data.etaMins
      );
      
      // Queue notifications to all recipients
      const notifications = [];
      
      // 1. Push notification to clinician
      if (facility?.clinician_device_token) {
        notifications.push({
          referralId,
          channel: 'push',
          recipientType: 'clinician',
          recipientRef: facility.clinician_device_token,
          title: '🚨 Emergency Referral Incoming',
          body: `${patientName} - ${dangerSign} - ETA ${data.etaMins || '?'} min`,
          data: { referralId, type: 'referral_incoming', priority: 'high' },
        });
      }
      
      // 2. SMS to clinician (fallback)
      if (facility?.clinician_phone) {
        notifications.push({
          referralId,
          channel: 'sms',
          recipientType: 'clinician',
          recipientRef: facility.clinician_phone,
          message: `URGENT REFERRAL: ${message}`,
        });
      }
      
      // 3. SMS to next of kin
      if (patient?.next_of_kin_phone_encrypted) {
        try {
          const nokPhone = decrypt(patient.next_of_kin_phone_encrypted.toString());
          notifications.push({
            referralId,
            channel: 'sms',
            recipientType: 'next_of_kin',
            recipientRef: nokPhone,
            message: `URGENT: ${patientName} has been referred to ${facility?.name || 'hospital'}. Please accompany her immediately. Contact: ${facility?.clinician_phone || facility?.phone || ''}`,
          });
        } catch (e) {
          logger.warn('Failed to decrypt next of kin phone');
        }
      }
      
      // 4. Push confirmation to health worker
      if (patient?.hw_device_token) {
        notifications.push({
          referralId,
          channel: 'push',
          recipientType: 'health_worker',
          recipientRef: patient.hw_device_token,
          title: 'Referral Sent',
          body: `${patientName} referred to ${facility?.name}`,
          data: { referralId, type: 'referral_sent' },
        });
      }
      
      // Log notification records and queue them
      for (const notif of notifications) {
        const notifId = uuidv4();
        await client.query(
          `INSERT INTO referral_notifications (id, referral_id, channel, recipient_type, recipient_ref, message_content)
           VALUES ($1, $2, $3, $4, $5, $6)`,
          [notifId, referralId, notif.channel, notif.recipientType, notif.recipientRef, notif.message || notif.body]
        );
        
        // Queue the notification
        if (notif.channel === 'push') {
          await pushQueue.add('send-push', { notificationId: notifId, ...notif });
        } else if (notif.channel === 'sms') {
          await smsQueue.add('send-sms', { notificationId: notifId, to: notif.recipientRef, message: notif.message });
        }
      }
      
      // Update status to dispatched
      await client.query(
        `UPDATE referrals SET status = 'dispatched' WHERE id = $1`,
        [referralId]
      );
    });
    
    // Schedule escalation check for 10 minutes
    await escalationQueue.add(
      'check-escalation',
      { referralId },
      { delay: 10 * 60 * 1000 } // 10 minutes
    );
    
    logger.info(`Referral created and dispatched: ${referralId}`);
    
    res.status(201).json({
      id: referralId,
      status: 'dispatched',
      message: 'Referral created and notifications sent',
    });
    
  } catch (error) {
    logger.error('Error creating referral:', error);
    res.status(500).json({ error: 'Failed to create referral' });
  }
});

/**
 * Update referral status (acknowledge, arrive, record outcome)
 */
referralRouter.patch('/:id/status', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const validation = updateStatusSchema.safeParse(req.body);
    
    if (!validation.success) {
      return res.status(400).json({ error: validation.error.flatten() });
    }
    
    const { status, notes, outcome } = validation.data;
    const userId = req.user!.id;
    
    // Build update query based on status
    let updateQuery = 'UPDATE referrals SET status = $1, updated_at = NOW()';
    const params: any[] = [status];
    let paramIndex = 2;
    
    if (status === 'acknowledged') {
      updateQuery += `, acknowledged_by = $${paramIndex}, acknowledged_at = NOW()`;
      params.push(userId);
      paramIndex++;
    } else if (status === 'arrived') {
      updateQuery += `, arrived_at = NOW()`;
    } else if (status === 'outcome_recorded') {
      if (!outcome) {
        return res.status(400).json({ error: 'Outcome required for outcome_recorded status' });
      }
      updateQuery += `, outcome = $${paramIndex}, outcome_notes = $${paramIndex + 1}, outcome_recorded_at = NOW(), outcome_recorded_by = $${paramIndex + 2}`;
      params.push(outcome, notes || null, userId);
      paramIndex += 3;
    }
    
    updateQuery += ` WHERE id = $${paramIndex} RETURNING *`;
    params.push(id);
    
    const result = await query(updateQuery, params);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Referral not found' });
    }
    
    const referral = result.rows[0];
    
    // Send confirmation notifications based on status change
    if (status === 'acknowledged') {
      // Notify health worker that clinician acknowledged
      await notifyStatusChange(referral, 'Clinician has acknowledged the referral');
    } else if (status === 'arrived') {
      // Notify health worker and next of kin that patient arrived
      await notifyStatusChange(referral, 'Patient has arrived at the facility');
    } else if (status === 'outcome_recorded') {
      // Log outcome for AI model retraining
      logger.info(`Outcome recorded for referral ${id}: ${outcome}`);
    }
    
    res.json(referral);
    
  } catch (error) {
    logger.error('Error updating referral status:', error);
    res.status(500).json({ error: 'Failed to update referral status' });
  }
});

/**
 * Get referrals for current user's facility or region
 */
referralRouter.get('/', async (req: Request, res: Response) => {
  try {
    const { status, limit = 50, offset = 0 } = req.query;
    const user = req.user!;
    
    let whereClause = '';
    const params: any[] = [];
    let paramIndex = 1;
    
    // Filter based on user role
    if (user.role === 'health_worker') {
      whereClause = `WHERE r.created_by = $${paramIndex}`;
      params.push(user.id);
      paramIndex++;
    } else if (user.role === 'clinician') {
      whereClause = `WHERE r.facility_id = $${paramIndex}`;
      params.push(user.facilityId);
      paramIndex++;
    } else if (user.role === 'regional_officer') {
      whereClause = `WHERE f.region_id = $${paramIndex}`;
      params.push(user.regionId);
      paramIndex++;
    }
    // national_officer sees all
    
    if (status) {
      whereClause += whereClause ? ' AND' : 'WHERE';
      whereClause += ` r.status = $${paramIndex}`;
      params.push(status);
      paramIndex++;
    }
    
    params.push(limit, offset);
    
    const result = await query(
      `SELECT r.*, f.name as facility_name, 
              p.age_at_registration as patient_age,
              u.full_name as created_by_name
       FROM referrals r
       JOIN facilities f ON r.facility_id = f.id
       JOIN patients p ON r.patient_id = p.id
       JOIN users u ON r.created_by = u.id
       ${whereClause}
       ORDER BY r.created_at DESC
       LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
      params
    );
    
    res.json({
      referrals: result.rows,
      count: result.rowCount,
    });
    
  } catch (error) {
    logger.error('Error fetching referrals:', error);
    res.status(500).json({ error: 'Failed to fetch referrals' });
  }
});

/**
 * Get single referral by ID
 */
referralRouter.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    
    const result = await query(
      `SELECT r.*, f.name as facility_name, f.phone as facility_phone,
              f.address as facility_address,
              p.age_at_registration as patient_age, p.gravida, p.parity,
              u.full_name as created_by_name, u.phone as created_by_phone,
              c.full_name as clinician_name, c.phone as clinician_phone
       FROM referrals r
       JOIN facilities f ON r.facility_id = f.id
       JOIN patients p ON r.patient_id = p.id
       JOIN users u ON r.created_by = u.id
       LEFT JOIN users c ON r.assigned_clinician_id = c.id
       WHERE r.id = $1`,
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Referral not found' });
    }
    
    // Get notification history
    const notifications = await query(
      `SELECT channel, recipient_type, sent_at, delivered_at, failed_at, error
       FROM referral_notifications
       WHERE referral_id = $1
       ORDER BY created_at`,
      [id]
    );
    
    res.json({
      ...result.rows[0],
      notifications: notifications.rows,
    });
    
  } catch (error) {
    logger.error('Error fetching referral:', error);
    res.status(500).json({ error: 'Failed to fetch referral' });
  }
});

// Helper functions

function buildReferralMessage(
  patientName: string,
  dangerSign: string,
  vitals: Record<string, any>,
  facilityName: string,
  etaMins?: number
): string {
  const vitalsStr = Object.entries(vitals)
    .map(([k, v]) => `${k}: ${v}`)
    .slice(0, 3)
    .join(', ');
  
  return `${patientName} referred to ${facilityName}. ${dangerSign}. Vitals: ${vitalsStr}. ETA: ${etaMins || '?'} min.`;
}

async function notifyStatusChange(referral: any, message: string): Promise<void> {
  try {
    // Get health worker device token
    const hwResult = await query(
      `SELECT u.device_token, u.phone
       FROM users u
       WHERE u.id = $1`,
      [referral.created_by]
    );
    
    if (hwResult.rows[0]?.device_token) {
      await pushQueue.add('send-push', {
        to: hwResult.rows[0].device_token,
        title: 'Referral Update',
        body: message,
        data: { referralId: referral.id, type: 'referral_update' },
      });
    }
  } catch (error) {
    logger.warn('Failed to send status change notification:', error);
  }
}
