import { Router, Request, Response } from 'express';
import { authMiddleware } from '../middleware/auth.js';
import { query } from '../database/index.js';
import { logger } from '../utils/logger.js';

const router = Router();

// List all regions
router.get('/', authMiddleware, async (req: Request, res: Response) => {
  try {
    const result = await query(`
      SELECT 
        r.id,
        r.name,
        r.code,
        (SELECT COUNT(*) FROM facilities f WHERE f.region_id = r.id) as "facilityCount",
        (SELECT COUNT(*) FROM patients p 
         JOIN facilities f ON p.facility_id = f.id 
         WHERE f.region_id = r.id AND p.is_pregnant = true) as "pregnantCount"
      FROM regions r
      ORDER BY r.name
    `, []);

    res.json(result.rows);
  } catch (error) {
    logger.error('Error listing regions:', error);
    res.status(500).json({ error: 'Failed to list regions' });
  }
});

// Get single region
router.get('/:id', authMiddleware, async (req: Request, res: Response) => {
  const { id } = req.params;

  try {
    const result = await query(`
      SELECT 
        r.*,
        (SELECT COUNT(*) FROM facilities f WHERE f.region_id = r.id) as "facilityCount",
        (SELECT COUNT(*) FROM patients p 
         JOIN facilities f ON p.facility_id = f.id 
         WHERE f.region_id = r.id) as "patientCount"
      FROM regions r
      WHERE r.id = $1
    `, [id]);

    if (result.rows.length === 0) {
      res.status(404).json({ error: 'Region not found' });
      return;
    }

    res.json(result.rows[0]);
  } catch (error) {
    logger.error('Error getting region:', error);
    res.status(500).json({ error: 'Failed to get region' });
  }
});

export default router;
