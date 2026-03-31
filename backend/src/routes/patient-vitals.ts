import { Router, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { query } from '../database/index.js';
import { config } from '../config/index.js';
import { logger } from '../utils/logger.js';
import { z } from 'zod';
import { v4 as uuidv4 } from 'uuid';

export const patientVitalsRouter = Router();

// Middleware to verify patient token
const patientAuth = async (req: Request, res: Response, next: any) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = jwt.verify(token, config.jwtSecret || 'dev-secret') as any;
    if (!decoded.patientId || decoded.type !== 'patient') {
      return res.status(401).json({ error: 'Invalid token' });
    }

    (req as any).patientId = decoded.patientId;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

// Schema for submitting vitals
const submitVitalsSchema = z.object({
  vitals: z.array(z.object({
    vitalType: z.enum(['bp', 'spo2', 'temp', 'fetal_hr', 'heart_rate']),
    values: z.record(z.number()),
    recordedAt: z.string().optional(),
    source: z.enum(['apple_watch', 'ble_device', 'manual']).default('manual'),
    deviceName: z.string().optional(),
  })),
});

/**
 * Submit vitals from patient (Apple Watch, manual entry, etc.)
 * Automatically checks thresholds and sends alerts
 */
patientVitalsRouter.post('/submit', patientAuth, async (req: Request, res: Response) => {
  try {
    const patientId = (req as any).patientId;

    const validation = submitVitalsSchema.safeParse(req.body);
    if (!validation.success) {
      return res.status(400).json({ error: validation.error.flatten() });
    }

    const { vitals } = validation.data;

    // Get patient's thresholds
    const thresholdsResult = await query(
      `SELECT 
        COALESCE(pt.vital_type, dt.vital_type) as vital_type,
        COALESCE(pt.warning_min, dt.warning_min) as warning_min,
        COALESCE(pt.warning_max, dt.warning_max) as warning_max,
        COALESCE(pt.danger_min, dt.danger_min) as danger_min,
        COALESCE(pt.danger_max, dt.danger_max) as danger_max
       FROM default_thresholds dt
       LEFT JOIN patient_thresholds pt ON pt.vital_type = dt.vital_type AND pt.patient_id = $1`,
      [patientId]
    );

    const thresholds: Record<string, any> = {};
    for (const row of thresholdsResult.rows) {
      thresholds[row.vital_type] = {
        warningMin: row.warning_min ? parseFloat(row.warning_min) : null,
        warningMax: row.warning_max ? parseFloat(row.warning_max) : null,
        dangerMin: row.danger_min ? parseFloat(row.danger_min) : null,
        dangerMax: row.danger_max ? parseFloat(row.danger_max) : null,
      };
    }

    // Create monitoring session
    const sessionId = uuidv4();
    await query(
      `INSERT INTO monitoring_sessions (id, patient_id, started_at, ended_at, device_id)
       VALUES ($1, $2, NOW(), NOW(), 'patient-self-monitor')`,
      [sessionId, patientId]
    );

    const alerts: any[] = [];
    const savedReadings: any[] = [];

    for (const vital of vitals) {
      const recordedAt = vital.recordedAt ? new Date(vital.recordedAt) : new Date();
      
      // Determine danger level
      const { dangerLevel, alertMessage } = checkThresholds(vital.vitalType, vital.values, thresholds);

      // Save reading
      const readingId = uuidv4();
      await query(
        `INSERT INTO readings (id, session_id, patient_id, vital_type, values_json, recorded_at, danger_level, source, device_name)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [
          readingId,
          sessionId,
          patientId,
          vital.vitalType,
          JSON.stringify(vital.values),
          recordedAt,
          dangerLevel,
          vital.source,
          vital.deviceName || null,
        ]
      );

      savedReadings.push({
        id: readingId,
        vitalType: vital.vitalType,
        values: vital.values,
        dangerLevel,
      });

      // Create alert if needed
      if (dangerLevel !== 'normal' && alertMessage) {
        const alertId = uuidv4();
        const severity = dangerLevel === 'danger' ? 'critical' : 'warning';

        await query(
          `INSERT INTO patient_alerts (id, patient_id, reading_id, alert_type, vital_type, message, severity, sent_via)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
          [
            alertId,
            patientId,
            readingId,
            dangerLevel === 'danger' ? 'danger_vital' : 'warning_vital',
            vital.vitalType,
            alertMessage,
            severity,
            ['push'],
          ]
        );

        alerts.push({
          id: alertId,
          type: vital.vitalType,
          message: alertMessage,
          severity,
        });

        // Notify health worker if danger
        if (dangerLevel === 'danger') {
          await notifyHealthWorker(patientId, vital.vitalType, vital.values, alertMessage);
        }
      }
    }

    logger.info(`Patient ${patientId} submitted ${vitals.length} vitals, ${alerts.length} alerts generated`);

    res.json({
      success: true,
      readings: savedReadings,
      alerts,
    });

  } catch (error) {
    logger.error('Submit vitals error:', error);
    res.status(500).json({ error: 'Failed to submit vitals' });
  }
});

/**
 * Get patient's recent vitals
 */
patientVitalsRouter.get('/recent', patientAuth, async (req: Request, res: Response) => {
  try {
    const patientId = (req as any).patientId;
    const limit = parseInt(req.query.limit as string) || 50;

    const result = await query(
      `SELECT id, vital_type, values_json, recorded_at, danger_level, source, device_name
       FROM readings
       WHERE patient_id = $1
       ORDER BY recorded_at DESC
       LIMIT $2`,
      [patientId, limit]
    );

    const readings = result.rows.map(row => ({
      id: row.id,
      vitalType: row.vital_type,
      values: row.values_json,
      recordedAt: row.recorded_at,
      dangerLevel: row.danger_level,
      source: row.source,
      deviceName: row.device_name,
    }));

    res.json({ readings });

  } catch (error) {
    logger.error('Get recent vitals error:', error);
    res.status(500).json({ error: 'Failed to get vitals' });
  }
});

/**
 * Get latest reading for each vital type
 */
patientVitalsRouter.get('/latest', patientAuth, async (req: Request, res: Response) => {
  try {
    const patientId = (req as any).patientId;

    const result = await query(
      `SELECT DISTINCT ON (vital_type) 
        id, vital_type, values_json, recorded_at, danger_level, source
       FROM readings
       WHERE patient_id = $1
       ORDER BY vital_type, recorded_at DESC`,
      [patientId]
    );

    const latestVitals: Record<string, any> = {};
    for (const row of result.rows) {
      latestVitals[row.vital_type] = {
        id: row.id,
        values: row.values_json,
        recordedAt: row.recorded_at,
        dangerLevel: row.danger_level,
        source: row.source,
      };
    }

    res.json({ latestVitals });

  } catch (error) {
    logger.error('Get latest vitals error:', error);
    res.status(500).json({ error: 'Failed to get latest vitals' });
  }
});

/**
 * Get vital history for charting
 */
patientVitalsRouter.get('/history/:vitalType', patientAuth, async (req: Request, res: Response) => {
  try {
    const patientId = (req as any).patientId;
    const { vitalType } = req.params;
    const days = parseInt(req.query.days as string) || 30;

    const result = await query(
      `SELECT values_json, recorded_at, danger_level
       FROM readings
       WHERE patient_id = $1 AND vital_type = $2 AND recorded_at > NOW() - INTERVAL '${days} days'
       ORDER BY recorded_at ASC`,
      [patientId, vitalType]
    );

    const history = result.rows.map(row => ({
      values: row.values_json,
      recordedAt: row.recorded_at,
      dangerLevel: row.danger_level,
    }));

    res.json({ history });

  } catch (error) {
    logger.error('Get vital history error:', error);
    res.status(500).json({ error: 'Failed to get history' });
  }
});

// Helper function to check thresholds
function checkThresholds(
  vitalType: string,
  values: Record<string, number>,
  thresholds: Record<string, any>
): { dangerLevel: string; alertMessage: string | null } {
  let dangerLevel = 'normal';
  let alertMessage: string | null = null;

  if (vitalType === 'bp') {
    const systolic = values.systolic;
    const diastolic = values.diastolic;
    const sysThresh = thresholds['bp_systolic'] || {};
    const diaThresh = thresholds['bp_diastolic'] || {};

    // Check danger first
    if (
      (sysThresh.dangerMax && systolic >= sysThresh.dangerMax) ||
      (diaThresh.dangerMax && diastolic >= diaThresh.dangerMax)
    ) {
      dangerLevel = 'danger';
      alertMessage = `⚠️ DANGER: Blood pressure is critically high (${systolic}/${diastolic}). Seek immediate medical attention!`;
    } else if (
      (sysThresh.warningMax && systolic >= sysThresh.warningMax) ||
      (diaThresh.warningMax && diastolic >= diaThresh.warningMax)
    ) {
      dangerLevel = 'warning';
      alertMessage = `Warning: Blood pressure is elevated (${systolic}/${diastolic}). Please rest and monitor.`;
    }
  } else if (vitalType === 'spo2') {
    const spo2 = values.spo2;
    const thresh = thresholds['spo2'] || {};

    if (thresh.dangerMin && spo2 <= thresh.dangerMin) {
      dangerLevel = 'danger';
      alertMessage = `⚠️ DANGER: Blood oxygen is critically low (${spo2}%). Seek immediate medical attention!`;
    } else if (thresh.warningMin && spo2 <= thresh.warningMin) {
      dangerLevel = 'warning';
      alertMessage = `Warning: Blood oxygen is low (${spo2}%). Please rest and breathe deeply.`;
    }
  } else if (vitalType === 'temp') {
    const temp = values.temperature;
    const thresh = thresholds['temp'] || {};

    if (thresh.dangerMax && temp >= thresh.dangerMax) {
      dangerLevel = 'danger';
      alertMessage = `⚠️ DANGER: Temperature is critically high (${temp}°C). Seek immediate medical attention!`;
    } else if (thresh.dangerMin && temp <= thresh.dangerMin) {
      dangerLevel = 'danger';
      alertMessage = `⚠️ DANGER: Temperature is critically low (${temp}°C). Seek immediate medical attention!`;
    } else if (thresh.warningMax && temp >= thresh.warningMax) {
      dangerLevel = 'warning';
      alertMessage = `Warning: You have a fever (${temp}°C). Rest and stay hydrated.`;
    } else if (thresh.warningMin && temp <= thresh.warningMin) {
      dangerLevel = 'warning';
      alertMessage = `Warning: Temperature is low (${temp}°C). Please keep warm.`;
    }
  } else if (vitalType === 'fetal_hr') {
    const hr = values.heartRate;
    const thresh = thresholds['fetal_hr'] || {};

    if ((thresh.dangerMax && hr >= thresh.dangerMax) || (thresh.dangerMin && hr <= thresh.dangerMin)) {
      dangerLevel = 'danger';
      alertMessage = `⚠️ DANGER: Fetal heart rate is abnormal (${hr} BPM). Seek immediate medical attention!`;
    } else if ((thresh.warningMax && hr >= thresh.warningMax) || (thresh.warningMin && hr <= thresh.warningMin)) {
      dangerLevel = 'warning';
      alertMessage = `Warning: Fetal heart rate is slightly abnormal (${hr} BPM). Please rest and monitor.`;
    }
  } else if (vitalType === 'heart_rate') {
    const hr = values.heartRate;
    const thresh = thresholds['heart_rate'] || {};

    if ((thresh.dangerMax && hr >= thresh.dangerMax) || (thresh.dangerMin && hr <= thresh.dangerMin)) {
      dangerLevel = 'danger';
      alertMessage = `⚠️ DANGER: Heart rate is abnormal (${hr} BPM). Seek medical attention!`;
    } else if ((thresh.warningMax && hr >= thresh.warningMax) || (thresh.warningMin && hr <= thresh.warningMin)) {
      dangerLevel = 'warning';
      alertMessage = `Warning: Heart rate is slightly abnormal (${hr} BPM). Please rest.`;
    }
  }

  return { dangerLevel, alertMessage };
}

// Helper to notify health worker
async function notifyHealthWorker(patientId: string, vitalType: string, values: any, alertMessage: string) {
  try {
    // Get patient and health worker info
    const result = await query(
      `SELECT p.full_name_encrypted, p.assigned_health_worker_id, u.device_token, u.phone
       FROM patients p
       LEFT JOIN users u ON p.assigned_health_worker_id = u.id
       WHERE p.id = $1`,
      [patientId]
    );

    if (result.rows.length === 0 || !result.rows[0].assigned_health_worker_id) {
      logger.warn(`No health worker assigned to patient ${patientId}`);
      return;
    }

    const { full_name_encrypted, assigned_health_worker_id, device_token } = result.rows[0];
    const patientName = full_name_encrypted.toString('utf8');

    // Update the alert to mark health worker notified
    await query(
      `UPDATE patient_alerts 
       SET health_worker_notified = true, health_worker_notified_at = NOW()
       WHERE patient_id = $1 AND vital_type = $2 AND health_worker_notified = false
       ORDER BY created_at DESC LIMIT 1`,
      [patientId, vitalType]
    );

    // TODO: Send push notification to health worker via FCM
    // TODO: Send SMS to health worker
    logger.info(`Health worker ${assigned_health_worker_id} notified about ${patientName}'s ${vitalType}`);

  } catch (error) {
    logger.error('Failed to notify health worker:', error);
  }
}
