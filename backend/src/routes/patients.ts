import { Router, Request, Response } from 'express';
import { query, transaction } from '../database/index.js';
import { authMiddleware, requireRole } from '../middleware/auth.js';
import { encrypt, decrypt, hashPhone } from '../utils/crypto.js';
import { logger } from '../utils/logger.js';
import { v4 as uuidv4 } from 'uuid';
import { z } from 'zod';
import axios from 'axios';
import { config } from '../config/index.js';

export const patientRouter = Router();

patientRouter.use(authMiddleware);

const createPatientSchema = z.object({
  fullName: z.string().min(2).max(200),
  phone: z.string().optional(),
  dateOfBirth: z.string().optional(),
  age: z.number().int().min(10).max(60).optional(),
  regionId: z.string().uuid().optional(),
  nearestFacilityId: z.string().uuid().optional(),
  nextOfKinPhone: z.string().optional(),
  
  // Obstetric history
  gravida: z.number().int().min(0).default(0),
  parity: z.number().int().min(0).default(0),
  priorStillbirth: z.boolean().default(false),
  priorCsection: z.boolean().default(false),
  priorPreeclampsia: z.boolean().default(false),
  
  // Medical history
  hivPositive: z.boolean().default(false),
  diabetes: z.boolean().default(false),
  anaemia: z.boolean().default(false),
  
  // Current pregnancy
  isPregnant: z.boolean().default(false),
  expectedDeliveryDate: z.string().optional(),
  gestationalWeeksAtRegistration: z.number().int().min(1).max(45).optional(),
  multiplePregnancy: z.boolean().default(false),
});

const recordVitalsSchema = z.object({
  sessionId: z.string().uuid().optional(),
  deviceHardwareId: z.string().optional(),
  vitals: z.array(z.object({
    vitalType: z.enum(['bp', 'spo2', 'temp', 'fetal_hr', 'fundal_height', 'weight']),
    values: z.record(z.number()),
    recordedAt: z.string().datetime(),
    source: z.string().optional(),
    deviceName: z.string().optional(),
    deviceHardwareId: z.string().optional(),
  })),
  symptoms: z.object({
    severeHeadache: z.boolean().default(false),
    vaginalBleeding: z.boolean().default(false),
    reducedFetalMovement: z.boolean().default(false),
    oedemaFaceHands: z.boolean().default(false),
    pallor: z.boolean().default(false),
  }).optional(),
});

/**
 * Create a new patient
 */
patientRouter.post('/', async (req: Request, res: Response) => {
  try {
    const validation = createPatientSchema.safeParse(req.body);
    if (!validation.success) {
      return res.status(400).json({ error: validation.error.flatten() });
    }
    
    const data = validation.data;
    const patientId = uuidv4();
    
    // Encrypt sensitive data
    const nameEncrypted = encrypt(data.fullName);
    const phoneHash = data.phone ? hashPhone(data.phone) : null;
    const phoneEncrypted = data.phone ? encrypt(data.phone) : null;
    const nokEncrypted = data.nextOfKinPhone ? encrypt(data.nextOfKinPhone) : null;
    
    await query(
      `INSERT INTO patients (
        id, full_name_encrypted, phone_hash, phone_encrypted, date_of_birth,
        age_at_registration, region_id, nearest_facility_id, next_of_kin_phone_encrypted,
        assigned_health_worker_id, gravida, parity, prior_stillbirth, prior_csection,
        prior_preeclampsia, hiv_positive, diabetes, anaemia, is_pregnant,
        pregnancy_registered_at, expected_delivery_date, gestational_weeks_at_registration,
        multiple_pregnancy
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23)`,
      [
        patientId,
        nameEncrypted,
        phoneHash,
        phoneEncrypted,
        data.dateOfBirth || null,
        data.age || null,
        data.regionId || req.user!.regionId,
        data.nearestFacilityId || null,
        nokEncrypted,
        req.user!.id,
        data.gravida,
        data.parity,
        data.priorStillbirth,
        data.priorCsection,
        data.priorPreeclampsia,
        data.hivPositive,
        data.diabetes,
        data.anaemia,
        data.isPregnant,
        data.isPregnant ? new Date() : null,
        data.expectedDeliveryDate || null,
        data.gestationalWeeksAtRegistration || null,
        data.multiplePregnancy,
      ]
    );
    
    logger.info(`Patient created: ${patientId} by ${req.user!.id}`);
    
    res.status(201).json({
      id: patientId,
      message: 'Patient registered successfully',
    });
    
  } catch (error) {
    logger.error('Create patient error:', error);
    res.status(500).json({ error: 'Failed to create patient' });
  }
});

/**
 * Record vitals and get AI risk score
 */
patientRouter.post('/:id/vitals', async (req: Request, res: Response) => {
  try {
    const { id: patientId } = req.params;
    const validation = recordVitalsSchema.safeParse(req.body);
    
    if (!validation.success) {
      return res.status(400).json({ error: validation.error.flatten() });
    }
    
    const { vitals, symptoms } = validation.data;
    let { sessionId } = validation.data;
    
    // Get patient data for AI scoring
    const patientResult = await query(
      `SELECT * FROM patients WHERE id = $1`,
      [patientId]
    );
    
    if (patientResult.rows.length === 0) {
      return res.status(404).json({ error: 'Patient not found' });
    }
    
    const patient = patientResult.rows[0];
    
    // Create session if not provided
    if (!sessionId) {
      sessionId = uuidv4();
      await query(
        `INSERT INTO monitoring_sessions (id, patient_id, health_worker_id, started_at)
         VALUES ($1, $2, $3, NOW())`,
        [sessionId, patientId, req.user!.id]
      );
    }
    
    // Process vitals and check for danger signs
    const dangerSigns: string[] = [];
    const processedVitals: any[] = [];
    const globalDeviceId = validation.data.deviceHardwareId;
    
    for (const vital of vitals) {
      const dangerLevel = checkDangerLevel(vital.vitalType, vital.values);
      
      if (dangerLevel === 'danger') {
        dangerSigns.push(`${vital.vitalType}: ${JSON.stringify(vital.values)}`);
      }
      
      const vitalId = uuidv4();
      const deviceHwId = vital.deviceHardwareId || globalDeviceId || null;
      
      await query(
        `INSERT INTO readings (id, session_id, patient_id, vital_type, values_json, recorded_at, danger_level, source, device_name, device_hardware_id)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
        [
          vitalId,
          sessionId,
          patientId,
          vital.vitalType,
          JSON.stringify(vital.values),
          vital.recordedAt,
          dangerLevel,
          vital.source || 'manual',
          vital.deviceName || null,
          deviceHwId,
        ]
      );
      
      processedVitals.push({ ...vital, id: vitalId, dangerLevel });
    }
    
    // Build features for AI scoring
    const features = buildAIFeatures(patient, vitals, symptoms);
    
    // Call AI scoring engine
    let aiScore = null;
    try {
      const aiResponse = await axios.post(`${config.aiEngineUrl}/score`, features, {
        timeout: 5000,
      });
      aiScore = aiResponse.data;
      
      // Store the score
      await query(
        `INSERT INTO risk_scores (id, patient_id, session_id, risk_score, risk_tier, top_factors, input_features, missing_features, model_version)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [
          uuidv4(),
          patientId,
          sessionId,
          aiScore.risk_score,
          aiScore.risk_tier,
          JSON.stringify(aiScore.reasons || []),
          JSON.stringify(features),
          aiScore.missing_features || [],
          aiScore.model_version || 'v1',
        ]
      );
      
    } catch (error) {
      logger.warn('AI scoring unavailable, using rule-based assessment');
      // Fall back to rule-based scoring
      aiScore = calculateRuleBasedScore(vitals, symptoms, dangerSigns);
    }
    
    // Update session
    await query(
      `UPDATE monitoring_sessions SET ended_at = NOW() WHERE id = $1`,
      [sessionId]
    );
    
    res.json({
      sessionId,
      vitals: processedVitals,
      dangerSigns,
      riskScore: aiScore,
      requiresReferral: aiScore?.risk_tier === 'high' || dangerSigns.length > 0,
    });
    
  } catch (error) {
    logger.error('Record vitals error:', error);
    res.status(500).json({ error: 'Failed to record vitals' });
  }
});

/**
 * Get patient by ID
 */
patientRouter.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    
    const result = await query(
      `SELECT p.*, 
              f.name as facility_name,
              r.name as region_name,
              u.full_name as health_worker_name
       FROM patients p
       LEFT JOIN facilities f ON p.nearest_facility_id = f.id
       LEFT JOIN regions r ON p.region_id = r.id
       LEFT JOIN users u ON p.assigned_health_worker_id = u.id
       WHERE p.id = $1`,
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Patient not found' });
    }
    
    const patient = result.rows[0];
    
    // Decrypt sensitive fields
    try {
      patient.fullName = decrypt(patient.full_name_encrypted.toString());
      if (patient.phone_encrypted) {
        patient.phone = decrypt(patient.phone_encrypted.toString());
      }
    } catch (e) {
      patient.fullName = '[Encrypted]';
    }
    
    // Remove encrypted fields from response
    delete patient.full_name_encrypted;
    delete patient.phone_encrypted;
    delete patient.phone_hash;
    delete patient.next_of_kin_phone_encrypted;
    
    // Get latest vitals
    const vitalsResult = await query(
      `SELECT vital_type, values_json, recorded_at, danger_level
       FROM readings
       WHERE patient_id = $1
       ORDER BY recorded_at DESC
       LIMIT 10`,
      [id]
    );
    
    // Get latest risk score
    const scoreResult = await query(
      `SELECT risk_score, risk_tier, top_factors, scored_at
       FROM risk_scores
       WHERE patient_id = $1
       ORDER BY scored_at DESC
       LIMIT 1`,
      [id]
    );
    
    res.json({
      ...patient,
      latestVitals: vitalsResult.rows,
      latestRiskScore: scoreResult.rows[0] || null,
    });
    
  } catch (error) {
    logger.error('Get patient error:', error);
    res.status(500).json({ error: 'Failed to get patient' });
  }
});

/**
 * List patients for current user
 */
patientRouter.get('/', async (req: Request, res: Response) => {
  try {
    const { limit = 50, offset = 0, pregnantOnly = false, highRiskOnly = false } = req.query;
    const user = req.user!;
    
    let whereClause = 'WHERE 1=1';
    const params: any[] = [];
    let paramIndex = 1;
    
    // Filter by user role
    if (user.role === 'health_worker') {
      whereClause += ` AND p.assigned_health_worker_id = $${paramIndex}`;
      params.push(user.id);
      paramIndex++;
    } else if (user.role === 'clinician' && user.facilityId) {
      whereClause += ` AND p.nearest_facility_id = $${paramIndex}`;
      params.push(user.facilityId);
      paramIndex++;
    } else if (user.role === 'regional_officer' && user.regionId) {
      whereClause += ` AND p.region_id = $${paramIndex}`;
      params.push(user.regionId);
      paramIndex++;
    }
    
    if (pregnantOnly === 'true') {
      whereClause += ` AND p.is_pregnant = TRUE`;
    }
    
    if (highRiskOnly === 'true') {
      whereClause += ` AND EXISTS (
        SELECT 1 FROM risk_scores rs 
        WHERE rs.patient_id = p.id AND rs.risk_tier = 'high'
        AND rs.scored_at > NOW() - INTERVAL '7 days'
      )`;
    }
    
    params.push(limit, offset);
    
    const result = await query(
      `SELECT p.id, p.age_at_registration, p.gravida, p.parity, p.is_pregnant,
              p.gestational_weeks_at_registration, p.pregnancy_registered_at,
              f.name as facility_name, r.name as region_name,
              rs.risk_score as latest_risk_score, rs.risk_tier as latest_risk_tier
       FROM patients p
       LEFT JOIN facilities f ON p.nearest_facility_id = f.id
       LEFT JOIN regions r ON p.region_id = r.id
       LEFT JOIN LATERAL (
         SELECT risk_score, risk_tier FROM risk_scores
         WHERE patient_id = p.id ORDER BY scored_at DESC LIMIT 1
       ) rs ON TRUE
       ${whereClause}
       ORDER BY rs.risk_score DESC NULLS LAST, p.created_at DESC
       LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`,
      params
    );
    
    // Decrypt names
    for (const patient of result.rows) {
      const fullPatient = await query(
        'SELECT full_name_encrypted FROM patients WHERE id = $1',
        [patient.id]
      );
      try {
        patient.fullName = decrypt(fullPatient.rows[0].full_name_encrypted.toString());
      } catch {
        patient.fullName = '[Patient]';
      }
    }
    
    res.json({
      patients: result.rows,
      count: result.rowCount,
    });
    
  } catch (error) {
    logger.error('List patients error:', error);
    res.status(500).json({ error: 'Failed to list patients' });
  }
});

// Helper functions

function checkDangerLevel(vitalType: string, values: Record<string, number>): string {
  const thresholds: Record<string, { warn: Record<string, number>; danger: Record<string, number> }> = {
    bp: {
      warn: { systolic: 140, diastolic: 90 },
      danger: { systolic: 160, diastolic: 110 },
    },
    spo2: {
      warn: { spo2: 95 },
      danger: { spo2: 90 },
    },
    temp: {
      warn: { temp: 37.5 },
      danger: { temp: 38.5 },
    },
    fetal_hr: {
      warn: { bpm_low: 110, bpm_high: 160 },
      danger: { bpm_low: 100, bpm_high: 180 },
    },
  };
  
  const t = thresholds[vitalType];
  if (!t) return 'normal';
  
  // Check danger thresholds
  if (vitalType === 'bp') {
    if ((values.systolic && values.systolic >= 160) || 
        (values.diastolic && values.diastolic >= 110)) {
      return 'danger';
    }
    if ((values.systolic && values.systolic >= 140) || 
        (values.diastolic && values.diastolic >= 90)) {
      return 'warning';
    }
  }
  
  if (vitalType === 'spo2' && values.spo2) {
    if (values.spo2 < 90) return 'danger';
    if (values.spo2 < 95) return 'warning';
  }
  
  if (vitalType === 'temp' && values.temp) {
    if (values.temp >= 38.5) return 'danger';
    if (values.temp >= 37.5) return 'warning';
  }
  
  if (vitalType === 'fetal_hr' && values.bpm) {
    if (values.bpm < 100 || values.bpm > 180) return 'danger';
    if (values.bpm < 110 || values.bpm > 160) return 'warning';
  }
  
  return 'normal';
}

function buildAIFeatures(patient: any, vitals: any[], symptoms?: any): Record<string, any> {
  const features: Record<string, any> = {
    age: patient.age_at_registration,
    gravida: patient.gravida,
    parity: patient.parity,
    gestational_weeks: calculateGestationalWeeks(
      patient.pregnancy_registered_at,
      patient.gestational_weeks_at_registration
    ),
    prior_stillbirth: patient.prior_stillbirth,
    prior_csection: patient.prior_csection,
    prior_preeclampsia: patient.prior_preeclampsia,
    multiple_pregnancy: patient.multiple_pregnancy,
    hiv_positive: patient.hiv_positive,
    diabetes: patient.diabetes,
    anaemia: patient.anaemia,
  };
  
  // Add vitals
  for (const vital of vitals) {
    if (vital.vitalType === 'bp') {
      features.systolic_bp = vital.values.systolic;
      features.diastolic_bp = vital.values.diastolic;
    } else if (vital.vitalType === 'spo2') {
      features.spo2 = vital.values.spo2;
      features.heart_rate = vital.values.heartRate;
    } else if (vital.vitalType === 'temp') {
      features.temperature = vital.values.temp;
    } else if (vital.vitalType === 'fetal_hr') {
      features.fetal_hr = vital.values.bpm;
    } else if (vital.vitalType === 'fundal_height') {
      features.fundal_height = vital.values.cm;
    }
  }
  
  // Add symptoms
  if (symptoms) {
    features.severe_headache = symptoms.severeHeadache;
    features.vaginal_bleeding = symptoms.vaginalBleeding;
    features.reduced_fetal_movement = symptoms.reducedFetalMovement;
    features.oedema_face_hands = symptoms.oedemaFaceHands;
    features.pallor = symptoms.pallor;
  }
  
  return features;
}

function calculateGestationalWeeks(registrationDate: Date | null, weeksAtReg: number | null): number | null {
  if (!registrationDate || !weeksAtReg) return null;
  
  const now = new Date();
  const reg = new Date(registrationDate);
  const weeksSince = Math.floor((now.getTime() - reg.getTime()) / (7 * 24 * 60 * 60 * 1000));
  
  return weeksAtReg + weeksSince;
}

function calculateRuleBasedScore(vitals: any[], symptoms: any, dangerSigns: string[]): any {
  let score = 0;
  
  // Each danger sign adds significant weight
  score += dangerSigns.length * 0.25;
  
  // Symptoms
  if (symptoms?.vaginalBleeding) score += 0.4;
  if (symptoms?.severeHeadache) score += 0.2;
  if (symptoms?.reducedFetalMovement) score += 0.3;
  if (symptoms?.oedemaFaceHands) score += 0.15;
  if (symptoms?.pallor) score += 0.15;
  
  score = Math.min(score, 1);
  
  return {
    risk_score: score,
    risk_tier: score >= 0.6 ? 'high' : score >= 0.25 ? 'medium' : 'low',
    reasons: dangerSigns.map(s => ({ factor: s, direction: 'increases risk', strength: 0.25 })),
    model_version: 'rule-based-v1',
  };
}

/**
 * Record vitals from a device - auto-lookup patient by device hardware ID
 * This endpoint is used by BLE devices or IoT integrations
 */
const deviceVitalsSchema = z.object({
  deviceHardwareId: z.string().min(1),
  vitals: z.array(z.object({
    vitalType: z.enum(['bp', 'spo2', 'temp', 'fetal_hr', 'fundal_height', 'weight']),
    values: z.record(z.number()),
    recordedAt: z.string().datetime(),
  })),
  batteryLevel: z.number().min(0).max(100).optional(),
});

patientRouter.post('/device-vitals', async (req: Request, res: Response) => {
  try {
    const validation = deviceVitalsSchema.safeParse(req.body);
    if (!validation.success) {
      return res.status(400).json({ error: validation.error.flatten() });
    }
    
    const { deviceHardwareId, vitals, batteryLevel } = validation.data;
    
    // Look up patient by device hardware ID
    const deviceResult = await query(
      `SELECT d.*, p.id as patient_id, p.full_name_encrypted
       FROM devices d
       JOIN patients p ON d.assigned_patient_id = p.id
       WHERE d.device_hardware_id = $1 AND d.status = 'active'`,
      [deviceHardwareId]
    );
    
    if (deviceResult.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Device not found or not assigned to a patient',
        deviceHardwareId,
      });
    }
    
    const device = deviceResult.rows[0];
    const patientId = device.patient_id;
    
    // Update device last_seen and battery
    await query(
      `UPDATE devices SET last_seen_at = NOW(), battery_level = COALESCE($1, battery_level) 
       WHERE id = $2`,
      [batteryLevel, device.id]
    );
    
    // Get patient data for AI scoring
    const patientResult = await query(
      `SELECT * FROM patients WHERE id = $1`,
      [patientId]
    );
    
    const patient = patientResult.rows[0];
    
    // Create a monitoring session
    const sessionId = uuidv4();
    await query(
      `INSERT INTO monitoring_sessions (id, patient_id, health_worker_id, started_at)
       VALUES ($1, $2, $3, NOW())`,
      [sessionId, patientId, req.user!.id]
    );
    
    // Process vitals
    const dangerSigns: string[] = [];
    const processedVitals: any[] = [];
    
    for (const vital of vitals) {
      const dangerLevel = checkDangerLevel(vital.vitalType, vital.values);
      
      if (dangerLevel === 'danger') {
        dangerSigns.push(`${vital.vitalType}: ${JSON.stringify(vital.values)}`);
      }
      
      const vitalId = uuidv4();
      await query(
        `INSERT INTO readings (id, session_id, patient_id, vital_type, values_json, recorded_at, danger_level, source, device_name, device_hardware_id)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
        [
          vitalId,
          sessionId,
          patientId,
          vital.vitalType,
          JSON.stringify(vital.values),
          vital.recordedAt,
          dangerLevel,
          'device',
          device.device_name,
          deviceHardwareId,
        ]
      );
      
      processedVitals.push({ ...vital, id: vitalId, dangerLevel });
    }
    
    // Build features for AI scoring
    const features = buildAIFeatures(patient, vitals, {});
    
    // Call AI scoring engine
    let aiScore = null;
    try {
      const aiResponse = await axios.post(`${config.aiEngineUrl}/score`, features, {
        timeout: 5000,
      });
      aiScore = aiResponse.data;
      
      await query(
        `INSERT INTO risk_scores (id, patient_id, session_id, risk_score, risk_tier, top_factors, input_features, missing_features, model_version)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [
          uuidv4(),
          patientId,
          sessionId,
          aiScore.risk_score,
          aiScore.risk_tier,
          JSON.stringify(aiScore.reasons || []),
          JSON.stringify(features),
          aiScore.missing_features || [],
          aiScore.model_version || 'v1',
        ]
      );
    } catch (error) {
      logger.warn('AI scoring unavailable, using rule-based assessment');
      aiScore = calculateRuleBasedScore(vitals, {}, dangerSigns);
    }
    
    // Update session
    await query(
      `UPDATE monitoring_sessions SET ended_at = NOW() WHERE id = $1`,
      [sessionId]
    );
    
    logger.info(`Device vitals recorded: device=${deviceHardwareId}, patient=${patientId}, vitals=${vitals.length}`);
    
    res.json({
      sessionId,
      patientId,
      deviceId: device.id,
      vitals: processedVitals,
      dangerSigns,
      riskScore: aiScore,
      requiresReferral: aiScore?.risk_tier === 'high' || dangerSigns.length > 0,
    });
    
  } catch (error) {
    logger.error('Device vitals error:', error);
    res.status(500).json({ error: 'Failed to record device vitals' });
  }
});
