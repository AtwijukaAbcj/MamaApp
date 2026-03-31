import Queue from 'bull';
import { config } from '../config/index.js';
import { logger } from '../utils/logger.js';
import { query } from '../database/index.js';

// Create queues
export const smsQueue = new Queue('sms', config.redisUrl || 'redis://localhost:6379');
export const pushQueue = new Queue('push', config.redisUrl || 'redis://localhost:6379');
export const escalationQueue = new Queue('escalation', config.redisUrl || 'redis://localhost:6379');
export const campaignQueue = new Queue('campaign', config.redisUrl || 'redis://localhost:6379');

// Africa's Talking SMS client
let atSmsClient: any = null;

async function getATClient() {
  if (!atSmsClient) {
    const AfricasTalking = (await import('africastalking')).default;
    const at = AfricasTalking({
      apiKey: config.atApiKey,
      username: config.atUsername,
    });
    atSmsClient = at.SMS;
  }
  return atSmsClient;
}

// Firebase Admin for push notifications
let firebaseApp: any = null;

async function getFirebaseMessaging() {
  if (!firebaseApp && config.firebaseProjectId) {
    const admin = (await import('firebase-admin')).default;
    firebaseApp = admin.initializeApp({
      credential: admin.credential.cert({
        projectId: config.firebaseProjectId,
        clientEmail: config.firebaseClientEmail,
        privateKey: config.firebasePrivateKey,
      }),
    });
  }
  return firebaseApp?.messaging();
}

export async function initializeQueues(): Promise<void> {
  // SMS Queue Processor
  smsQueue.process('send-sms', async (job) => {
    const { to, message, notificationId } = job.data;
    
    try {
      const sms = await getATClient();
      
      const result = await sms.send({
        to: [to],
        message: message,
        from: config.atSenderId,
      });
      
      logger.info(`SMS sent to ${to.substring(0, 7)}***: ${result.SMSMessageData?.Recipients?.[0]?.status}`);
      
      // Update notification record if exists
      if (notificationId) {
        await query(
          `UPDATE referral_notifications SET sent_at = NOW(), delivered_at = NOW() WHERE id = $1`,
          [notificationId]
        );
      }
      
      return result;
      
    } catch (error: any) {
      logger.error(`SMS failed to ${to.substring(0, 7)}***:`, error.message);
      
      // Update notification record with error
      if (notificationId) {
        await query(
          `UPDATE referral_notifications SET failed_at = NOW(), error = $1, retry_count = retry_count + 1 WHERE id = $2`,
          [error.message, notificationId]
        );
      }
      
      throw error;
    }
  });
  
  // Push Notification Queue Processor
  pushQueue.process('send-push', async (job) => {
    const { to, title, body, data, notificationId } = job.data;
    
    try {
      const messaging = await getFirebaseMessaging();
      
      if (!messaging) {
        logger.warn('Firebase not configured, skipping push notification');
        return { skipped: true };
      }
      
      const result = await messaging.send({
        token: to,
        notification: { title, body },
        data: data || {},
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            priority: 'high',
            channelId: 'emergencies',
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      });
      
      logger.info(`Push notification sent: ${result}`);
      
      // Update notification record
      if (notificationId) {
        await query(
          `UPDATE referral_notifications SET sent_at = NOW(), delivered_at = NOW() WHERE id = $1`,
          [notificationId]
        );
      }
      
      return result;
      
    } catch (error: any) {
      logger.error('Push notification failed:', error.message);
      
      if (notificationId) {
        await query(
          `UPDATE referral_notifications SET failed_at = NOW(), error = $1, retry_count = retry_count + 1 WHERE id = $2`,
          [error.message, notificationId]
        );
      }
      
      throw error;
    }
  });
  
  // Escalation Queue Processor
  escalationQueue.process('check-escalation', async (job) => {
    const { referralId } = job.data;
    
    try {
      // Get referral status
      const result = await query(
        `SELECT r.*, f.region_id, 
                EXTRACT(EPOCH FROM (NOW() - r.created_at)) / 60 as minutes_elapsed
         FROM referrals r
         JOIN facilities f ON r.facility_id = f.id
         WHERE r.id = $1`,
        [referralId]
      );
      
      if (result.rows.length === 0) {
        return { skipped: true, reason: 'Referral not found' };
      }
      
      const referral = result.rows[0];
      const minutesElapsed = Math.floor(referral.minutes_elapsed);
      
      // Already handled - no escalation needed
      if (['acknowledged', 'arrived', 'outcome_recorded'].includes(referral.status)) {
        logger.info(`Referral ${referralId} already ${referral.status}, no escalation needed`);
        return { skipped: true, reason: `Already ${referral.status}` };
      }
      
      // First escalation at 10 minutes
      if (minutesElapsed >= 10 && referral.status === 'dispatched') {
        logger.warn(`Referral ${referralId} not acknowledged after ${minutesElapsed} minutes - escalating`);
        
        // Get District Medical Officer
        const dmoResult = await query(
          `SELECT id, phone, device_token, full_name FROM users
           WHERE role = 'regional_officer' AND region_id = $1
           LIMIT 1`,
          [referral.region_id]
        );
        
        if (dmoResult.rows[0]) {
          const dmo = dmoResult.rows[0];
          
          // SMS to DMO
          await smsQueue.add('send-sms', {
            to: dmo.phone,
            message: `ESCALATION: Referral RF-${referralId.slice(0, 6)} not acknowledged after ${minutesElapsed} min. Please follow up immediately.`,
          });
          
          // Push to DMO
          if (dmo.device_token) {
            await pushQueue.add('send-push', {
              to: dmo.device_token,
              title: '⚠️ Unacknowledged Referral',
              body: `Referral RF-${referralId.slice(0, 6)} needs attention`,
              data: { referralId, type: 'escalation' },
            });
          }
        }
        
        // Retry the clinician
        const clinicianResult = await query(
          `SELECT u.phone, u.device_token FROM users u
           WHERE u.id = $1`,
          [referral.assigned_clinician_id]
        );
        
        if (clinicianResult.rows[0]?.phone) {
          await smsQueue.add('send-sms', {
            to: clinicianResult.rows[0].phone,
            message: `URGENT REMINDER: Referral RF-${referralId.slice(0, 6)} still pending. Please acknowledge immediately.`,
          });
        }
        
        // Schedule another check in 10 minutes
        await escalationQueue.add(
          'check-escalation',
          { referralId },
          { delay: 10 * 60 * 1000 }
        );
        
        return { escalated: true, level: 1 };
      }
      
      // Final escalation at 30 minutes
      if (minutesElapsed >= 30 && referral.status === 'dispatched') {
        logger.error(`CRITICAL: Referral ${referralId} not acknowledged after ${minutesElapsed} minutes`);
        
        // Get National Health Officer
        const nationalResult = await query(
          `SELECT id, phone, device_token FROM users
           WHERE role = 'national_officer'
           LIMIT 1`,
          []
        );
        
        if (nationalResult.rows[0]) {
          await smsQueue.add('send-sms', {
            to: nationalResult.rows[0].phone,
            message: `CRITICAL INCIDENT: Referral RF-${referralId.slice(0, 6)} unresolved after 30+ minutes. Immediate action required.`,
          });
        }
        
        // Flag as critical incident
        await query(
          `INSERT INTO audit_log (user_id, action, entity_type, entity_id, new_values)
           VALUES (NULL, 'critical_incident', 'referral', $1, $2)`,
          [referralId, JSON.stringify({ minutes_elapsed: minutesElapsed, escalation_level: 'critical' })]
        );
        
        return { escalated: true, level: 'critical' };
      }
      
      return { checked: true, status: referral.status };
      
    } catch (error) {
      logger.error('Escalation check failed:', error);
      throw error;
    }
  });
  
  // Campaign Queue - for scheduled SMS drip campaigns
  campaignQueue.process('send-campaign-message', async (job) => {
    const { subscriptionId } = job.data;
    
    try {
      // Get subscription and campaign details
      const result = await query(
        `SELECT s.*, c.topic, c.language, c.total_messages
         FROM sms_subscriptions s
         JOIN sms_campaigns c ON s.campaign_id = c.id
         WHERE s.id = $1 AND s.unsubscribed_at IS NULL`,
        [subscriptionId]
      );
      
      if (result.rows.length === 0) {
        return { skipped: true, reason: 'Subscription not found or unsubscribed' };
      }
      
      const sub = result.rows[0];
      
      // Get message content
      const contentResult = await query(
        `SELECT content FROM srh_content
         WHERE topic = $1 AND language = $2 AND page = $3 AND channel = 'sms'`,
        [sub.topic, sub.language, sub.current_message]
      );
      
      if (contentResult.rows.length === 0) {
        return { skipped: true, reason: 'Content not found' };
      }
      
      // Send SMS
      // Note: phone is encrypted, need to decrypt
      const { decrypt } = await import('../utils/crypto.js');
      const phone = decrypt(sub.phone_encrypted.toString());
      
      await smsQueue.add('send-sms', {
        to: phone,
        message: `MamaApp (${sub.current_message}/${sub.total_messages}): ${contentResult.rows[0].content}`,
      });
      
      // Update subscription
      const nextMessage = sub.current_message + 1;
      
      if (nextMessage <= sub.total_messages) {
        await query(
          `UPDATE sms_subscriptions SET current_message = $1, last_sent_at = NOW() WHERE id = $2`,
          [nextMessage, subscriptionId]
        );
      } else {
        // Series complete
        await query(
          `UPDATE sms_subscriptions SET last_sent_at = NOW() WHERE id = $1`,
          [subscriptionId]
        );
        
        // Send completion message
        await smsQueue.add('send-sms', {
          to: phone,
          message: `Congratulations! You've completed the MamaApp health education series. 🎉 Text LEARN to start again or HELP if you need support.`,
        });
      }
      
      return { sent: true, message: sub.current_message };
      
    } catch (error) {
      logger.error('Campaign message failed:', error);
      throw error;
    }
  });
  
  // Queue error handlers
  [smsQueue, pushQueue, escalationQueue, campaignQueue].forEach((queue) => {
    queue.on('error', (error) => {
      logger.error(`Queue error:`, error);
    });
    
    queue.on('failed', (job, error) => {
      logger.error(`Job ${job.id} failed:`, error.message);
    });
  });
  
  logger.info('📬 Job queues initialized');
}

// Scheduled job to process daily campaign messages
export async function scheduleCampaignMessages(): Promise<void> {
  try {
    // Get all active subscriptions due for a message
    const result = await query(
      `SELECT s.id FROM sms_subscriptions s
       JOIN sms_campaigns c ON s.campaign_id = c.id
       WHERE s.unsubscribed_at IS NULL
         AND s.current_message <= c.total_messages
         AND (s.last_sent_at IS NULL OR s.last_sent_at < NOW() - (c.interval_days || ' days')::interval)`,
      []
    );
    
    for (const row of result.rows) {
      await campaignQueue.add('send-campaign-message', { subscriptionId: row.id });
    }
    
    logger.info(`Scheduled ${result.rowCount} campaign messages`);
    
  } catch (error) {
    logger.error('Failed to schedule campaign messages:', error);
  }
}
