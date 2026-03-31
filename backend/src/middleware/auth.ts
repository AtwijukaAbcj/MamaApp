import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config/index.js';
import { query } from '../database/index.js';
import { logger } from '../utils/logger.js';

export interface AuthUser {
  id: string;
  email: string | null;
  phone: string;
  fullName: string;
  role: 'health_worker' | 'clinician' | 'regional_officer' | 'national_officer';
  facilityId: string | null;
  regionId: string | null;
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthUser;
    }
  }
}

export async function authMiddleware(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({ error: 'Missing or invalid authorization header' });
      return;
    }
    
    const token = authHeader.split(' ')[1];
    
    // Verify token
    const decoded = jwt.verify(token, config.jwtSecret || 'dev-secret') as { userId: string };
    
    // Get user from database
    const result = await query<{
      id: string;
      email: string | null;
      phone: string;
      full_name: string;
      role: string;
      facility_id: string | null;
      region_id: string | null;
    }>(
      `SELECT id, email, phone, full_name, role, facility_id, region_id
       FROM users WHERE id = $1 AND is_active = TRUE`,
      [decoded.userId]
    );
    
    if (result.rows.length === 0) {
      res.status(401).json({ error: 'User not found or inactive' });
      return;
    }
    
    const user = result.rows[0];
    
    req.user = {
      id: user.id,
      email: user.email,
      phone: user.phone,
      fullName: user.full_name,
      role: user.role as AuthUser['role'],
      facilityId: user.facility_id,
      regionId: user.region_id,
    };
    
    next();
    
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      res.status(401).json({ error: 'Invalid token' });
      return;
    }
    logger.error('Auth middleware error:', error);
    res.status(500).json({ error: 'Authentication failed' });
  }
}

export function requireRole(...roles: AuthUser['role'][]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      res.status(401).json({ error: 'Not authenticated' });
      return;
    }
    
    if (!roles.includes(req.user.role)) {
      res.status(403).json({ error: 'Insufficient permissions' });
      return;
    }
    
    next();
  };
}
