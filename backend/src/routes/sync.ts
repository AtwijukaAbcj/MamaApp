import { Router, Request, Response } from 'express';
import { query, transaction } from '../database/index.js';
import { authMiddleware } from '../middleware/auth.js';
import { logger } from '../utils/logger.js';
import { v4 as uuidv4 } from 'uuid';

export const syncRouter = Router();

syncRouter.use(authMiddleware);

/**
 * Upload offline data batch
 * The Flutter app uses this to sync data collected offline
 */
syncRouter.post('/upload', async (req: Request, res: Response) => {
  try {
    const { deviceId, records } = req.body;
    
    if (!deviceId || !Array.isArray(records)) {
      return res.status(400).json({ error: 'Invalid sync payload' });
    }
    
    const results = {
      success: [] as string[],
      failed: [] as { id: string; error: string }[],
    };
    
    for (const record of records) {
      try {
        await processOutboxRecord(record, req.user!.id);
        results.success.push(record.id);
      } catch (error: any) {
        logger.warn(`Sync record ${record.id} failed:`, error.message);
        results.failed.push({ id: record.id, error: error.message });
      }
    }
    
    // Log sync
    await query(
      `INSERT INTO sync_outbox (id, device_id, table_name, record_id, operation, payload_json, created_at, synced_at)
       VALUES ($1, $2, 'sync_batch', $3, 'batch_upload', $4, NOW(), NOW())`,
      [uuidv4(), deviceId, deviceId, JSON.stringify({ 
        total: records.length, 
        success: results.success.length,
        failed: results.failed.length 
      })]
    );
    
    logger.info(`Sync complete for device ${deviceId}: ${results.success.length} success, ${results.failed.length} failed`);
    
    res.json({
      synced: results.success.length,
      failed: results.failed.length,
      details: results,
    });
    
  } catch (error) {
    logger.error('Sync upload error:', error);
    res.status(500).json({ error: 'Sync failed' });
  }
});

async function processOutboxRecord(record: any, userId: string): Promise<void> {
  const { tableName, recordId, operation, payload } = record;
  
  switch (tableName) {
    case 'monitoring_sessions':
      await syncMonitoringSession(payload, userId);
      break;
    case 'readings':
      await syncReading(payload);
      break;
    case 'referrals':
      await syncReferral(payload, userId);
      break;
    case 'patients':
      await syncPatient(payload, userId);
      break;
    default:
      throw new Error(`Unknown table: ${tableName}`);
  }
}

async function syncMonitoringSession(payload: any, userId: string): Promise<void> {
  const existing = await query('SELECT id FROM monitoring_sessions WHERE id = $1', [payload.id]);
  
  if (existing.rows.length > 0) {
    // Update
    await query(
      `UPDATE monitoring_sessions SET ended_at = $1, synced_at = NOW() WHERE id = $2`,
      [payload.endedAt, payload.id]
    );
  } else {
    // Insert
    await query(
      `INSERT INTO monitoring_sessions (id, patient_id, health_worker_id, started_at, ended_at, location_lat, location_lng, device_id, synced_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())`,
      [
        payload.id,
        payload.patientId,
        userId,
        payload.startedAt,
        payload.endedAt,
        payload.locationLat,
        payload.locationLng,
        payload.deviceId,
      ]
    );
  }
}

async function syncReading(payload: any): Promise<void> {
  const existing = await query('SELECT id FROM readings WHERE id = $1 AND recorded_at = $2', [payload.id, payload.recordedAt]);
  
  if (existing.rows.length > 0) {
    // Already exists - idempotent
    return;
  }
  
  await query(
    `INSERT INTO readings (id, session_id, patient_id, vital_type, values_json, recorded_at, danger_level, source, device_name, device_hardware_id, synced_at)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW())`,
    [
      payload.id,
      payload.sessionId,
      payload.patientId,
      payload.vitalType,
      JSON.stringify(payload.values),
      payload.recordedAt,
      payload.dangerLevel,
      payload.source,
      payload.deviceName,
      payload.deviceHardwareId,
    ]
  );
}

async function syncReferral(payload: any, userId: string): Promise<void> {
  const existing = await query('SELECT id FROM referrals WHERE id = $1', [payload.id]);
  
  if (existing.rows.length > 0) {
    // Already exists - update status if needed
    await query(
      `UPDATE referrals SET status = $1, updated_at = NOW() 
       WHERE id = $2 AND updated_at < $3`,
      [payload.status, payload.id, payload.updatedAt]
    );
    return;
  }
  
  await query(
    `INSERT INTO referrals (id, patient_id, created_by, trigger_type, trigger_detail, vitals_snapshot, ai_risk_score, facility_id, status, created_at)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
    [
      payload.id,
      payload.patientId,
      userId,
      payload.triggerType,
      JSON.stringify(payload.triggerDetail),
      JSON.stringify(payload.vitalsSnapshot),
      payload.aiRiskScore,
      payload.facilityId,
      payload.status,
      payload.createdAt,
    ]
  );
}

async function syncPatient(payload: any, userId: string): Promise<void> {
  const existing = await query('SELECT id FROM patients WHERE id = $1', [payload.id]);
  
  if (existing.rows.length > 0) {
    // Update patient - but only certain fields
    await query(
      `UPDATE patients SET 
         is_pregnant = COALESCE($1, is_pregnant),
         expected_delivery_date = COALESCE($2, expected_delivery_date),
         updated_at = NOW()
       WHERE id = $3`,
      [
        payload.isPregnant,
        payload.expectedDeliveryDate,
        payload.id,
      ]
    );
    return;
  }
  
  // New patient - requires full data (handled by patients route)
  throw new Error('New patient sync requires full registration');
}

/**
 * Get pending data for offline device
 * Returns data that needs to be downloaded to the device
 */
syncRouter.get('/download', async (req: Request, res: Response) => {
  try {
    const { lastSyncAt, deviceId } = req.query;
    const user = req.user!;
    
    const sinceTime = lastSyncAt ? new Date(lastSyncAt as string) : new Date(0);
    
    // Get patients assigned to this health worker that were updated
    const patients = await query(
      `SELECT id, gravida, parity, is_pregnant, gestational_weeks_at_registration,
              prior_stillbirth, prior_csection, prior_preeclampsia,
              hiv_positive, diabetes, anaemia, multiple_pregnancy,
              nearest_facility_id, updated_at
       FROM patients
       WHERE assigned_health_worker_id = $1 AND updated_at > $2
       ORDER BY updated_at DESC
       LIMIT 100`,
      [user.id, sinceTime]
    );
    
    // Get facilities in user's region
    const facilities = await query(
      `SELECT id, name, facility_type, address, phone, latitude, longitude
       FROM facilities
       WHERE region_id = $1 AND updated_at > $2`,
      [user.regionId, sinceTime]
    );
    
    // Get referral status updates
    const referrals = await query(
      `SELECT id, status, acknowledged_at, arrived_at, outcome, updated_at
       FROM referrals
       WHERE created_by = $1 AND updated_at > $2`,
      [user.id, sinceTime]
    );
    
    // Get device assignments for this user's patients
    const devices = await query(
      `SELECT d.id, d.device_hardware_id, d.device_name, d.device_type, 
              d.assigned_patient_id, d.status, d.battery_level, d.updated_at
       FROM devices d
       JOIN patients p ON d.assigned_patient_id = p.id
       WHERE p.assigned_health_worker_id = $1 AND d.updated_at > $2`,
      [user.id, sinceTime]
    );
    
    res.json({
      syncAt: new Date().toISOString(),
      patients: patients.rows,
      facilities: facilities.rows,
      referrals: referrals.rows,
      devices: devices.rows,
    });
    
  } catch (error) {
    logger.error('Sync download error:', error);
    res.status(500).json({ error: 'Download failed' });
  }
});

/**
 * Report sync status
 */
syncRouter.post('/status', async (req: Request, res: Response) => {
  try {
    const { deviceId, pendingCount, lastSyncAt, appVersion } = req.body;
    
    logger.info(`Device ${deviceId} status: ${pendingCount} pending, last sync ${lastSyncAt}, version ${appVersion}`);
    
    res.json({ acknowledged: true });
    
  } catch (error) {
    logger.error('Sync status error:', error);
    res.status(500).json({ error: 'Status report failed' });
  }
});
