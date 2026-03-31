import { Router, Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { query } from '../database/index.js';
import { config } from '../config/index.js';
import { logger } from '../utils/logger.js';
import { z } from 'zod';

export const patientAuthRouter = Router();

// Patient registration schema
const patientRegisterSchema = z.object({
  phone: z.string().min(10).max(15),
  pin: z.string().length(4).regex(/^\d+$/, 'PIN must be 4 digits'),
  fullName: z.string().min(2).max(200),
  dateOfBirth: z.string().optional(), // ISO date
  nextOfKinPhone: z.string().optional(),
});

// Patient login schema
const patientLoginSchema = z.object({
  phone: z.string(),
  pin: z.string(),
});

/**
 * Patient self-registration
 * Creates a new patient who can self-monitor
 */
patientAuthRouter.post('/register', async (req: Request, res: Response) => {
  try {
    const validation = patientRegisterSchema.safeParse(req.body);
    if (!validation.success) {
      return res.status(400).json({ error: validation.error.flatten() });
    }

    const { phone, pin, fullName, dateOfBirth, nextOfKinPhone } = validation.data;

    // Check if phone already registered
    const existing = await query('SELECT id FROM patients WHERE phone = $1', [phone]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Phone number already registered' });
    }

    // Hash PIN
    const pinHash = await bcrypt.hash(pin, 12);

    // Encrypt name (simple encoding for now - in production use AES)
    const encryptedName = Buffer.from(fullName, 'utf8');
    const encryptedNextOfKin = nextOfKinPhone ? Buffer.from(nextOfKinPhone, 'utf8') : null;

    // Calculate age
    let age = null;
    if (dateOfBirth) {
      const dob = new Date(dateOfBirth);
      const today = new Date();
      age = today.getFullYear() - dob.getFullYear();
    }

    // Create patient
    const result = await query(
      `INSERT INTO patients (
        full_name_encrypted, phone, pin_hash, phone_encrypted,
        date_of_birth, age_at_registration, next_of_kin_phone_encrypted,
        is_pregnant, alert_preferences
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, false, '{"sms": true, "push": true, "healthWorker": true}')
      RETURNING id`,
      [
        encryptedName,
        phone,
        pinHash,
        Buffer.from(phone, 'utf8'),
        dateOfBirth || null,
        age,
        encryptedNextOfKin,
      ]
    );

    const patientId = result.rows[0].id;

    // Generate token
    const token = jwt.sign(
      { patientId, type: 'patient' },
      config.jwtSecret || 'dev-secret',
      { expiresIn: '30d' }
    );

    logger.info(`Patient registered: ${patientId}`);

    res.status(201).json({
      patient: {
        id: patientId,
        fullName,
        phone,
      },
      token,
    });

  } catch (error) {
    logger.error('Patient registration error:', error);
    res.status(500).json({ error: 'Registration failed' });
  }
});

/**
 * Patient login
 */
patientAuthRouter.post('/login', async (req: Request, res: Response) => {
  try {
    const validation = patientLoginSchema.safeParse(req.body);
    if (!validation.success) {
      return res.status(400).json({ error: validation.error.flatten() });
    }

    const { phone, pin } = validation.data;

    // Get patient
    const result = await query(
      `SELECT id, pin_hash, full_name_encrypted, is_pregnant, 
              expected_delivery_date, gestational_weeks_at_registration,
              assigned_health_worker_id, nearest_facility_id
       FROM patients WHERE phone = $1`,
      [phone]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid phone or PIN' });
    }

    const patient = result.rows[0];

    // Verify PIN
    if (!patient.pin_hash) {
      return res.status(401).json({ error: 'Account not set up for login. Contact your health worker.' });
    }

    const validPin = await bcrypt.compare(pin, patient.pin_hash);
    if (!validPin) {
      return res.status(401).json({ error: 'Invalid phone or PIN' });
    }

    // Update last login
    await query('UPDATE patients SET last_login_at = NOW() WHERE id = $1', [patient.id]);

    // Get health worker info
    let healthWorker = null;
    if (patient.assigned_health_worker_id) {
      const hwResult = await query(
        'SELECT full_name, phone FROM users WHERE id = $1',
        [patient.assigned_health_worker_id]
      );
      if (hwResult.rows.length > 0) {
        healthWorker = {
          name: hwResult.rows[0].full_name,
          phone: hwResult.rows[0].phone,
        };
      }
    }

    // Generate token
    const token = jwt.sign(
      { patientId: patient.id, type: 'patient' },
      config.jwtSecret || 'dev-secret',
      { expiresIn: '30d' }
    );

    // Decode name
    const fullName = patient.full_name_encrypted.toString('utf8');

    logger.info(`Patient logged in: ${patient.id}`);

    res.json({
      patient: {
        id: patient.id,
        fullName,
        isPregnant: patient.is_pregnant,
        expectedDeliveryDate: patient.expected_delivery_date,
        gestationalWeeks: patient.gestational_weeks_at_registration,
        healthWorker,
      },
      token,
    });

  } catch (error) {
    logger.error('Patient login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

/**
 * Get patient profile (authenticated)
 */
patientAuthRouter.get('/me', async (req: Request, res: Response) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = jwt.verify(token, config.jwtSecret || 'dev-secret') as any;
    if (!decoded.patientId || decoded.type !== 'patient') {
      return res.status(401).json({ error: 'Invalid token' });
    }

    const result = await query(
      `SELECT p.id, p.full_name_encrypted, p.phone, p.date_of_birth,
              p.is_pregnant, p.expected_delivery_date, p.gestational_weeks_at_registration,
              p.gravida, p.parity, p.assigned_health_worker_id, p.nearest_facility_id,
              p.alert_preferences, p.hiv_positive, p.diabetes, p.anaemia,
              u.full_name as hw_name, u.phone as hw_phone,
              f.name as facility_name, f.phone as facility_phone
       FROM patients p
       LEFT JOIN users u ON p.assigned_health_worker_id = u.id
       LEFT JOIN facilities f ON p.nearest_facility_id = f.id
       WHERE p.id = $1`,
      [decoded.patientId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Patient not found' });
    }

    const patient = result.rows[0];
    const fullName = patient.full_name_encrypted.toString('utf8');

    res.json({
      id: patient.id,
      fullName,
      phone: patient.phone,
      dateOfBirth: patient.date_of_birth,
      isPregnant: patient.is_pregnant,
      expectedDeliveryDate: patient.expected_delivery_date,
      gestationalWeeks: patient.gestational_weeks_at_registration,
      gravida: patient.gravida,
      parity: patient.parity,
      conditions: {
        hivPositive: patient.hiv_positive,
        diabetes: patient.diabetes,
        anaemia: patient.anaemia,
      },
      alertPreferences: patient.alert_preferences,
      healthWorker: patient.hw_name ? {
        name: patient.hw_name,
        phone: patient.hw_phone,
      } : null,
      facility: patient.facility_name ? {
        name: patient.facility_name,
        phone: patient.facility_phone,
      } : null,
    });

  } catch (error) {
    logger.error('Get patient profile error:', error);
    res.status(500).json({ error: 'Failed to get profile' });
  }
});

/**
 * Update device token for push notifications
 */
patientAuthRouter.post('/device-token', async (req: Request, res: Response) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = jwt.verify(token, config.jwtSecret || 'dev-secret') as any;
    if (!decoded.patientId) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    const { deviceToken } = req.body;
    if (!deviceToken) {
      return res.status(400).json({ error: 'Device token required' });
    }

    await query(
      'UPDATE patients SET device_token = $1 WHERE id = $2',
      [deviceToken, decoded.patientId]
    );

    res.json({ success: true });

  } catch (error) {
    logger.error('Update device token error:', error);
    res.status(500).json({ error: 'Failed to update device token' });
  }
});

/**
 * Get patient's alerts
 */
patientAuthRouter.get('/alerts', async (req: Request, res: Response) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = jwt.verify(token, config.jwtSecret || 'dev-secret') as any;
    if (!decoded.patientId) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    const result = await query(
      `SELECT id, alert_type, vital_type, message, severity, sent_at, read_at
       FROM patient_alerts
       WHERE patient_id = $1
       ORDER BY sent_at DESC
       LIMIT 50`,
      [decoded.patientId]
    );

    res.json({ alerts: result.rows });

  } catch (error) {
    logger.error('Get alerts error:', error);
    res.status(500).json({ error: 'Failed to get alerts' });
  }
});

/**
 * Mark alert as read
 */
patientAuthRouter.post('/alerts/:alertId/read', async (req: Request, res: Response) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = jwt.verify(token, config.jwtSecret || 'dev-secret') as any;
    if (!decoded.patientId) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    await query(
      'UPDATE patient_alerts SET read_at = NOW() WHERE id = $1 AND patient_id = $2',
      [req.params.alertId, decoded.patientId]
    );

    res.json({ success: true });

  } catch (error) {
    logger.error('Mark alert read error:', error);
    res.status(500).json({ error: 'Failed to mark alert as read' });
  }
});

/**
 * Get thresholds for the patient
 */
patientAuthRouter.get('/thresholds', async (req: Request, res: Response) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = jwt.verify(token, config.jwtSecret || 'dev-secret') as any;
    if (!decoded.patientId) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    // Get patient-specific thresholds, falling back to defaults
    const result = await query(
      `SELECT 
        COALESCE(pt.vital_type, dt.vital_type) as vital_type,
        COALESCE(pt.warning_min, dt.warning_min) as warning_min,
        COALESCE(pt.warning_max, dt.warning_max) as warning_max,
        COALESCE(pt.danger_min, dt.danger_min) as danger_min,
        COALESCE(pt.danger_max, dt.danger_max) as danger_max
       FROM default_thresholds dt
       LEFT JOIN patient_thresholds pt ON pt.vital_type = dt.vital_type AND pt.patient_id = $1`,
      [decoded.patientId]
    );

    const thresholds: Record<string, any> = {};
    for (const row of result.rows) {
      thresholds[row.vital_type] = {
        warningMin: row.warning_min ? parseFloat(row.warning_min) : null,
        warningMax: row.warning_max ? parseFloat(row.warning_max) : null,
        dangerMin: row.danger_min ? parseFloat(row.danger_min) : null,
        dangerMax: row.danger_max ? parseFloat(row.danger_max) : null,
      };
    }

    res.json({ thresholds });

  } catch (error) {
    logger.error('Get thresholds error:', error);
    res.status(500).json({ error: 'Failed to get thresholds' });
  }
});
