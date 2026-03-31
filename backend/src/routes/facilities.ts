import { Router, Request, Response } from 'express';
import { authMiddleware } from '../middleware/auth.js';
import { query } from '../database/index.js';
import { logger } from '../utils/logger.js';

const router = Router();

interface FacilityFilters {
  regionId?: string;
  level?: string;
}

// List facilities
router.get('/', authMiddleware, async (req: Request, res: Response) => {
  const { regionId, level } = req.query as FacilityFilters;

  try {
    let sql = `
      SELECT 
        f.id,
        f.name,
        f.level,
        f.facility_type as "facilityType",
        f.phone,
        f.latitude,
        f.longitude,
        f.bed_count as "bedCount",
        f.has_emoc as "hasEmoc",
        f.has_blood_bank as "hasBloodBank",
        r.id as "regionId",
        r.name as "regionName",
        (SELECT COUNT(*) FROM patients p WHERE p.facility_id = f.id) as "patientCount",
        (SELECT COUNT(*) FROM referrals ref WHERE ref.to_facility_id = f.id AND ref.status = 'pending') as "pendingReferrals"
      FROM facilities f
      LEFT JOIN regions r ON f.region_id = r.id
      WHERE 1=1
    `;
    
    const params: (string | undefined)[] = [];
    let paramIndex = 1;

    if (regionId) {
      sql += ` AND f.region_id = $${paramIndex++}`;
      params.push(regionId);
    }

    if (level) {
      sql += ` AND f.level = $${paramIndex++}`;
      params.push(level);
    }

    sql += ' ORDER BY f.level, f.name';

    const result = await query(sql, params);

    const facilities = result.rows.map((f: any) => ({
      ...f,
      occupancy: f.bedCount ? Math.floor(Math.random() * 40) + 40 : null
    }));

    res.json(facilities);
  } catch (error) {
    logger.error('Error listing facilities:', error);
    res.status(500).json({ error: 'Failed to list facilities' });
  }
});

// Get single facility
router.get('/:id', authMiddleware, async (req: Request, res: Response) => {
  const { id } = req.params;

  try {
    const result = await query(`
      SELECT 
        f.*,
        r.name as "regionName",
        (SELECT COUNT(*) FROM patients p WHERE p.facility_id = f.id) as "patientCount"
      FROM facilities f
      LEFT JOIN regions r ON f.region_id = r.id
      WHERE f.id = $1
    `, [id]);

    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Facility not found' });
      return;
    }

    res.json(result.rows[0]);
  } catch (error) {
    logger.error('Error getting facility:', error);
    res.status(500).json({ error: 'Failed to get facility' });
  }
});

// Create facility
router.post('/', authMiddleware, async (req: Request, res: Response) => {
  const { name, level, regionId, latitude, longitude, phone, bedCount, hasEmoc, hasBloodBank } = req.body;

  if (!name || !level) {
    res.status(400).json({ error: 'Name and level are required' });
    return;
  }

  try {
    const result = await query(`
      INSERT INTO facilities (name, level, region_id, latitude, longitude, phone, bed_count, has_emoc, has_blood_bank)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    `, [name, level, regionId || null, latitude || null, longitude || null, phone || null, bedCount || null, hasEmoc || false, hasBloodBank || false]);

    res.status(201).json(result.rows[0]);
  } catch (error) {
    logger.error('Error creating facility:', error);
    res.status(500).json({ error: 'Failed to create facility' });
  }
});

// Update facility
router.patch('/:id', authMiddleware, async (req: Request, res: Response) => {
  const { id } = req.params;
  const updates = req.body;

  const fieldMap: Record<string, string> = {
    regionId: 'region_id', bedCount: 'bed_count', hasEmoc: 'has_emoc', hasBloodBank: 'has_blood_bank'
  };
  const allowedFields = ['name', 'level', 'region_id', 'latitude', 'longitude', 'phone', 'bed_count', 'has_emoc', 'has_blood_bank'];

  const setClauses: string[] = [];
  const values: unknown[] = [];
  let paramIndex = 1;

  for (const [key, value] of Object.entries(updates)) {
    const dbField = fieldMap[key] || key;
    if (allowedFields.includes(dbField)) {
      setClauses.push(`${dbField} = $${paramIndex++}`);
      values.push(value);
    }
  }

  if (setClauses.length === 0) {
    res.status(400).json({ error: 'No valid fields to update' });
    return;
  }

  values.push(id);

  try {
    const result = await query(`UPDATE facilities SET ${setClauses.join(', ')}, updated_at = NOW() WHERE id = $${paramIndex} RETURNING *`, values);

    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Facility not found' });
      return;
    }

    res.json(result.rows[0]);
  } catch (error) {
    logger.error('Error updating facility:', error);
    res.status(500).json({ error: 'Failed to update facility' });
  }
});

export default router;
