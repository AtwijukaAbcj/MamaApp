import { Router, Request, Response } from 'express';
import { query, transaction } from '../database/index.js';
import { authMiddleware, requireRole } from '../middleware/auth.js';
import { logger } from '../utils/logger.js';
import { v4 as uuidv4 } from 'uuid';
import { z } from 'zod';

export const deviceRouter = Router();

deviceRouter.use(authMiddleware);

const registerDeviceSchema = z.object({
  deviceId: z.string().min(1).max(100), // BLE MAC or serial
  deviceType: z.enum(['bp_cuff', 'oximeter', 'thermometer', 'fetal_doppler', 'wearfit', 'other']),
  deviceName: z.string().max(200).optional(),
  deviceModel: z.string().max(100).optional(),
  facilityId: z.string().uuid().optional(),
});

const assignDeviceSchema = z.object({
  patientId: z.string().uuid(),
});

/**
 * Register a new device in the system
 */
deviceRouter.post('/register', async (req: Request, res: Response) => {
  try {
    const validation = registerDeviceSchema.safeParse(req.body);
    if (!validation.success) {
      return res.status(400).json({ error: validation.error.flatten() });
    }
    
    const { deviceId, deviceType, deviceName, deviceModel, facilityId } = validation.data;
    const user = req.user!;
    
    // Check if device already exists
    const existing = await query(
      'SELECT id, status, assigned_patient_id FROM devices WHERE device_id = $1',
      [deviceId]
    );
    
    if (existing.rows.length > 0) {
      // Device exists - return existing record
      return res.json({
        id: existing.rows[0].id,
        deviceId,
        status: existing.rows[0].status,
        assignedPatientId: existing.rows[0].assigned_patient_id,
        message: 'Device already registered',
      });
    }
    
    // Register new device
    const id = uuidv4();
    await query(
      `INSERT INTO devices (id, device_id, device_type, device_name, device_model, facility_id, region_id, status, last_seen_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, 'available', NOW())`,
      [id, deviceId, deviceType, deviceName, deviceModel, facilityId || user.facilityId, user.regionId]
    );
    
    logger.info(`Device registered: ${deviceId} (${deviceType}) by ${user.id}`);
    
    res.status(201).json({
      id,
      deviceId,
      deviceType,
      status: 'available',
      message: 'Device registered successfully',
    });
    
  } catch (error) {
    logger.error('Device registration error:', error);
    res.status(500).json({ error: 'Failed to register device' });
  }
});

/**
 * Assign a device to a patient
 * The device will automatically link all future readings to this patient
 */
deviceRouter.post('/:id/assign', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const validation = assignDeviceSchema.safeParse(req.body);
    
    if (!validation.success) {
      return res.status(400).json({ error: validation.error.flatten() });
    }
    
    const { patientId } = validation.data;
    const user = req.user!;
    
    await transaction(async (client) => {
      // Get device
      const deviceResult = await client.query(
        'SELECT * FROM devices WHERE id = $1',
        [id]
      );
      
      if (deviceResult.rows.length === 0) {
        throw new Error('Device not found');
      }
      
      const device = deviceResult.rows[0];
      
      // If device was previously assigned, close that assignment
      if (device.assigned_patient_id) {
        await client.query(
          `UPDATE device_assignments 
           SET unassigned_at = NOW(), unassigned_by = $1, reason = 'reassigned'
           WHERE device_id = $2 AND unassigned_at IS NULL`,
          [user.id, id]
        );
      }
      
      // Update device assignment
      await client.query(
        `UPDATE devices 
         SET assigned_patient_id = $1, assigned_at = NOW(), assigned_by = $2, status = 'assigned', updated_at = NOW()
         WHERE id = $3`,
        [patientId, user.id, id]
      );
      
      // Create assignment record
      await client.query(
        `INSERT INTO device_assignments (id, device_id, patient_id, assigned_by, assigned_at)
         VALUES ($1, $2, $3, $4, NOW())`,
        [uuidv4(), id, patientId, user.id]
      );
    });
    
    logger.info(`Device ${id} assigned to patient ${patientId} by ${user.id}`);
    
    res.json({
      success: true,
      message: 'Device assigned to patient. All readings from this device will now link to this patient.',
    });
    
  } catch (error: any) {
    logger.error('Device assignment error:', error);
    res.status(error.message === 'Device not found' ? 404 : 500).json({ 
      error: error.message || 'Failed to assign device' 
    });
  }
});

/**
 * Unassign a device from a patient
 */
deviceRouter.post('/:id/unassign', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const user = req.user!;
    
    await transaction(async (client) => {
      // Close current assignment
      await client.query(
        `UPDATE device_assignments 
         SET unassigned_at = NOW(), unassigned_by = $1, reason = $2
         WHERE device_id = $3 AND unassigned_at IS NULL`,
        [user.id, reason || 'manual_unassign', id]
      );
      
      // Update device
      await client.query(
        `UPDATE devices 
         SET assigned_patient_id = NULL, assigned_at = NULL, assigned_by = NULL, status = 'available', updated_at = NOW()
         WHERE id = $1`,
        [id]
      );
    });
    
    logger.info(`Device ${id} unassigned by ${user.id}`);
    
    res.json({ success: true, message: 'Device unassigned and available for reassignment' });
    
  } catch (error) {
    logger.error('Device unassignment error:', error);
    res.status(500).json({ error: 'Failed to unassign device' });
  }
});

/**
 * Get patient by device hardware ID
 * Used by the app to auto-link readings
 */
deviceRouter.get('/lookup/:deviceId', async (req: Request, res: Response) => {
  try {
    const { deviceId } = req.params;
    
    const result = await query(
      `SELECT d.id, d.device_id, d.device_type, d.device_name, d.status,
              d.assigned_patient_id, d.assigned_at,
              p.age_at_registration as patient_age, p.gravida, p.gestational_weeks_at_registration
       FROM devices d
       LEFT JOIN patients p ON d.assigned_patient_id = p.id
       WHERE d.device_id = $1`,
      [deviceId]
    );
    
    if (result.rows.length === 0) {
      // Device not registered - return null patient but allow registration
      return res.json({
        registered: false,
        deviceId,
        patientId: null,
        message: 'Device not registered. Register it first.',
      });
    }
    
    const device = result.rows[0];
    
    // Update last seen
    await query(
      'UPDATE devices SET last_seen_at = NOW() WHERE device_id = $1',
      [deviceId]
    );
    
    res.json({
      registered: true,
      id: device.id,
      deviceId: device.device_id,
      deviceType: device.device_type,
      deviceName: device.device_name,
      status: device.status,
      patientId: device.assigned_patient_id,
      assignedAt: device.assigned_at,
      patient: device.assigned_patient_id ? {
        age: device.patient_age,
        gravida: device.gravida,
        gestationalWeeks: device.gestational_weeks_at_registration,
      } : null,
    });
    
  } catch (error) {
    logger.error('Device lookup error:', error);
    res.status(500).json({ error: 'Failed to lookup device' });
  }
});

/**
 * List all devices (for facility/region)
 */
deviceRouter.get('/', async (req: Request, res: Response) => {
  try {
    const { status, type, assigned } = req.query;
    const user = req.user!;
    
    let whereClause = 'WHERE 1=1';
    const params: any[] = [];
    let paramIndex = 1;
    
    // Filter by user's facility or region
    if (user.role === 'health_worker' && user.facilityId) {
      whereClause += ` AND d.facility_id = $${paramIndex}`;
      params.push(user.facilityId);
      paramIndex++;
    } else if (user.role === 'regional_officer' && user.regionId) {
      whereClause += ` AND d.region_id = $${paramIndex}`;
      params.push(user.regionId);
      paramIndex++;
    }
    
    if (status) {
      whereClause += ` AND d.status = $${paramIndex}`;
      params.push(status);
      paramIndex++;
    }
    
    if (type) {
      whereClause += ` AND d.device_type = $${paramIndex}`;
      params.push(type);
      paramIndex++;
    }
    
    if (assigned === 'true') {
      whereClause += ` AND d.assigned_patient_id IS NOT NULL`;
    } else if (assigned === 'false') {
      whereClause += ` AND d.assigned_patient_id IS NULL`;
    }
    
    const result = await query(
      `SELECT d.*, 
              f.name as facility_name,
              u.full_name as assigned_by_name
       FROM devices d
       LEFT JOIN facilities f ON d.facility_id = f.id
       LEFT JOIN users u ON d.assigned_by = u.id
       ${whereClause}
       ORDER BY d.status, d.device_type, d.device_name`,
      params
    );
    
    res.json({ devices: result.rows });
    
  } catch (error) {
    logger.error('Device list error:', error);
    res.status(500).json({ error: 'Failed to list devices' });
  }
});

/**
 * Get device assignment history
 */
deviceRouter.get('/:id/history', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    
    const result = await query(
      `SELECT da.*,
              u1.full_name as assigned_by_name,
              u2.full_name as unassigned_by_name
       FROM device_assignments da
       LEFT JOIN users u1 ON da.assigned_by = u1.id
       LEFT JOIN users u2 ON da.unassigned_by = u2.id
       WHERE da.device_id = $1
       ORDER BY da.assigned_at DESC`,
      [id]
    );
    
    res.json({ history: result.rows });
    
  } catch (error) {
    logger.error('Device history error:', error);
    res.status(500).json({ error: 'Failed to get device history' });
  }
});

/**
 * Update device status (maintenance, lost, etc.)
 */
deviceRouter.patch('/:id/status', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { status, notes, batteryLevel, firmwareVersion } = req.body;
    
    const updates: string[] = [];
    const params: any[] = [];
    let paramIndex = 1;
    
    if (status) {
      updates.push(`status = $${paramIndex}`);
      params.push(status);
      paramIndex++;
    }
    
    if (notes !== undefined) {
      updates.push(`notes = $${paramIndex}`);
      params.push(notes);
      paramIndex++;
    }
    
    if (batteryLevel !== undefined) {
      updates.push(`battery_level = $${paramIndex}`);
      params.push(batteryLevel);
      paramIndex++;
    }
    
    if (firmwareVersion) {
      updates.push(`firmware_version = $${paramIndex}`);
      params.push(firmwareVersion);
      paramIndex++;
    }
    
    if (updates.length === 0) {
      return res.status(400).json({ error: 'No updates provided' });
    }
    
    updates.push('updated_at = NOW()');
    params.push(id);
    
    await query(
      `UPDATE devices SET ${updates.join(', ')} WHERE id = $${paramIndex}`,
      params
    );
    
    res.json({ success: true });
    
  } catch (error) {
    logger.error('Device status update error:', error);
    res.status(500).json({ error: 'Failed to update device status' });
  }
});
