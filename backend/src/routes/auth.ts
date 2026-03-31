import { Router, Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { query } from '../database/index.js';
import { config } from '../config/index.js';
import { logger } from '../utils/logger.js';
import { authMiddleware } from '../middleware/auth.js';
import { v4 as uuidv4 } from 'uuid';
import { z } from 'zod';

export const authRouter = Router();

const registerSchema = z.object({
  email: z.string().email().optional(),
  phone: z.string().min(10).max(15),
  password: z.string().min(8),
  fullName: z.string().min(2).max(200),
  role: z.enum(['health_worker', 'clinician', 'regional_officer', 'national_officer']),
  facilityId: z.string().uuid().optional(),
  regionId: z.string().uuid().optional(),
});

const loginSchema = z.object({
  phone: z.string(),
  password: z.string().optional(),
  pin: z.string().optional(),
}).refine(data => data.password || data.pin, {
  message: "Password or PIN required"
});

/**
 * Register a new user
 */
authRouter.post('/register', async (req: Request, res: Response) => {
  try {
    const validation = registerSchema.safeParse(req.body);
    if (!validation.success) {
      return res.status(400).json({ error: validation.error.flatten() });
    }
    
    const { email, phone, password, fullName, role, facilityId, regionId } = validation.data;
    
    // Check if phone already exists
    const existing = await query('SELECT id FROM users WHERE phone = $1', [phone]);
    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Phone number already registered' });
    }
    
    // Hash password
    const passwordHash = await bcrypt.hash(password, 12);
    
    // Create user
    const userId = uuidv4();
    await query(
      `INSERT INTO users (id, email, phone, password_hash, full_name, role, facility_id, region_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [userId, email || null, phone, passwordHash, fullName, role, facilityId || null, regionId || null]
    );
    
    // Generate token
    const token = jwt.sign(
      { userId },
      config.jwtSecret || 'dev-secret',
      { expiresIn: config.jwtExpiresIn || '7d' }
    );
    
    logger.info(`User registered: ${userId} (${role})`);
    
    res.status(201).json({
      user: { id: userId, fullName, role, phone },
      token,
    });
    
  } catch (error) {
    logger.error('Registration error:', error);
    res.status(500).json({ error: 'Registration failed' });
  }
});

/**
 * Login
 */
authRouter.post('/login', async (req: Request, res: Response) => {
  try {
    const validation = loginSchema.safeParse(req.body);
    if (!validation.success) {
      return res.status(400).json({ error: validation.error.flatten() });
    }
    
    const { phone, password, pin } = validation.data;
    const credential = password || pin;

    // Get user
    const result = await query(
      `SELECT id, password_hash, full_name, role, facility_id, region_id, is_active
       FROM users WHERE phone = $1`,
      [phone]
    );
    
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const user = result.rows[0];
    
    if (!user.is_active) {
      return res.status(401).json({ error: 'Account is inactive' });
    }
    
    // Verify password/PIN
    const validPassword = await bcrypt.compare(credential!, user.password_hash);
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    // Generate token
    const token = jwt.sign(
      { userId: user.id },
      config.jwtSecret || 'dev-secret',
      { expiresIn: config.jwtExpiresIn || '7d' }
    );
    
    logger.info(`User logged in: ${user.id}`);
    
    res.json({
      user: {
        id: user.id,
        fullName: user.full_name,
        role: user.role,
        facilityId: user.facility_id,
        regionId: user.region_id,
      },
      token,
    });
    
  } catch (error) {
    logger.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

/**
 * Get current user
 */
authRouter.get('/me', authMiddleware, async (req: Request, res: Response) => {
  try {
    const result = await query(
      `SELECT u.id, u.email, u.phone, u.full_name, u.role, 
              u.facility_id, u.region_id,
              f.name as facility_name,
              r.name as region_name
       FROM users u
       LEFT JOIN facilities f ON u.facility_id = f.id
       LEFT JOIN regions r ON u.region_id = r.id
       WHERE u.id = $1`,
      [req.user!.id]
    );
    
    res.json(result.rows[0]);
    
  } catch (error) {
    logger.error('Get user error:', error);
    res.status(500).json({ error: 'Failed to get user' });
  }
});

/**
 * Update device token for push notifications
 */
authRouter.patch('/device-token', authMiddleware, async (req: Request, res: Response) => {
  try {
    const { deviceToken } = req.body;
    
    if (!deviceToken) {
      return res.status(400).json({ error: 'Device token required' });
    }
    
    await query(
      `UPDATE users SET device_token = $1, updated_at = NOW() WHERE id = $2`,
      [deviceToken, req.user!.id]
    );
    
    res.json({ success: true });
    
  } catch (error) {
    logger.error('Update device token error:', error);
    res.status(500).json({ error: 'Failed to update device token' });
  }
});

/**
 * Change password
 */
authRouter.post('/change-password', authMiddleware, async (req: Request, res: Response) => {
  try {
    const { currentPassword, newPassword } = req.body;
    
    if (!currentPassword || !newPassword || newPassword.length < 8) {
      return res.status(400).json({ error: 'Invalid password' });
    }
    
    // Get current hash
    const result = await query('SELECT password_hash FROM users WHERE id = $1', [req.user!.id]);
    
    // Verify current password
    const valid = await bcrypt.compare(currentPassword, result.rows[0].password_hash);
    if (!valid) {
      return res.status(401).json({ error: 'Current password is incorrect' });
    }
    
    // Update password
    const newHash = await bcrypt.hash(newPassword, 12);
    await query(
      `UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2`,
      [newHash, req.user!.id]
    );
    
    res.json({ success: true });
    
  } catch (error) {
    logger.error('Change password error:', error);
    res.status(500).json({ error: 'Failed to change password' });
  }
});
