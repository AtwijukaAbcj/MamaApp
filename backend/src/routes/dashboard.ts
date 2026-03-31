import { Router, Request, Response } from 'express';
import { query } from '../database/index.js';
import { authMiddleware, requireRole } from '../middleware/auth.js';
import { logger } from '../utils/logger.js';

export const dashboardRouter = Router();

dashboardRouter.use(authMiddleware);
dashboardRouter.use(requireRole('regional_officer', 'national_officer'));

/**
 * Get aggregate metrics for dashboard
 */
dashboardRouter.get('/metrics', async (req: Request, res: Response) => {
  try {
    const { region = 'national', period = '30d' } = req.query;
    const user = req.user!;
    
    // Parse period
    const periodDays = parseInt((period as string).replace('d', '')) || 30;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - periodDays);
    
    // Build region filter
    let regionFilter = '';
    const params: any[] = [startDate];
    let paramIndex = 2;
    
    if (region !== 'national' && region !== 'all') {
      regionFilter = `AND p.region_id = $${paramIndex}`;
      params.push(region);
      paramIndex++;
    } else if (user.role === 'regional_officer' && user.regionId) {
      // Regional officers can only see their region
      regionFilter = `AND p.region_id = $${paramIndex}`;
      params.push(user.regionId);
      paramIndex++;
    }
    
    // Get key metrics
    const metricsQuery = `
      SELECT
        COUNT(DISTINCT CASE WHEN r.scored_at >= $1 THEN r.patient_id END) as patients_monitored,
        COUNT(DISTINCT CASE WHEN r.risk_tier = 'high' AND r.scored_at >= $1 THEN r.patient_id END) as high_risk_patients,
        COUNT(DISTINCT CASE WHEN ref.created_at >= $1 THEN ref.id END) as total_referrals,
        COUNT(DISTINCT CASE WHEN ref.status = 'outcome_recorded' AND ref.created_at >= $1 THEN ref.id END) as completed_referrals,
        COUNT(DISTINCT CASE WHEN ref.outcome = 'safe_delivery' AND ref.created_at >= $1 THEN ref.id END) as safe_deliveries,
        COUNT(DISTINCT CASE WHEN ref.outcome = 'complication' AND ref.created_at >= $1 THEN ref.id END) as complications,
        COUNT(DISTINCT CASE WHEN ref.outcome = 'death' AND ref.created_at >= $1 THEN ref.id END) as deaths,
        AVG(CASE WHEN r.scored_at >= $1 THEN r.risk_score END) as avg_risk_score
      FROM patients p
      LEFT JOIN risk_scores r ON p.id = r.patient_id
      LEFT JOIN referrals ref ON p.id = ref.patient_id
      WHERE p.is_pregnant = TRUE ${regionFilter}
    `;
    
    const metricsResult = await query(metricsQuery, params);
    const metrics = metricsResult.rows[0];
    
    // Get USSD/SMS stats
    const engagementQuery = `
      SELECT
        COUNT(*) as ussd_sessions,
        COUNT(DISTINCT country_prefix) as countries_reached
      FROM ussd_sessions
      WHERE started_at >= $1
    `;
    const engagementResult = await query(engagementQuery, [startDate]);
    
    // Calculate referral completion rate
    const referralCompletionRate = metrics.total_referrals > 0
      ? (parseInt(metrics.completed_referrals) / parseInt(metrics.total_referrals) * 100).toFixed(1)
      : 0;
    
    res.json({
      period: `${periodDays} days`,
      patientsMonitored: parseInt(metrics.patients_monitored) || 0,
      highRiskPatients: parseInt(metrics.high_risk_patients) || 0,
      totalReferrals: parseInt(metrics.total_referrals) || 0,
      referralCompletionRate: parseFloat(referralCompletionRate as string),
      safeDeliveries: parseInt(metrics.safe_deliveries) || 0,
      complications: parseInt(metrics.complications) || 0,
      deaths: parseInt(metrics.deaths) || 0,
      avgRiskScore: parseFloat(metrics.avg_risk_score) || 0,
      ussdSessions: parseInt(engagementResult.rows[0]?.ussd_sessions) || 0,
      countriesReached: parseInt(engagementResult.rows[0]?.countries_reached) || 0,
    });
    
  } catch (error) {
    logger.error('Dashboard metrics error:', error);
    res.status(500).json({ error: 'Failed to fetch metrics' });
  }
});

/**
 * Get time-series trends
 */
dashboardRouter.get('/trends', async (req: Request, res: Response) => {
  try {
    const { region = 'national', period = '30d', granularity = 'day' } = req.query;
    const user = req.user!;
    
    const periodDays = parseInt((period as string).replace('d', '')) || 30;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - periodDays);
    
    let regionFilter = '';
    const params: any[] = [startDate];
    let paramIndex = 2;
    
    if (region !== 'national' && region !== 'all') {
      regionFilter = `AND p.region_id = $${paramIndex}`;
      params.push(region);
      paramIndex++;
    } else if (user.role === 'regional_officer' && user.regionId) {
      regionFilter = `AND p.region_id = $${paramIndex}`;
      params.push(user.regionId);
      paramIndex++;
    }
    
    const trendsQuery = `
      SELECT
        DATE_TRUNC('${granularity}', r.scored_at) as date,
        COUNT(DISTINCT r.patient_id) as patients_monitored,
        COUNT(*) FILTER (WHERE r.risk_tier = 'high') as high_risk_scores,
        AVG(r.risk_score) as avg_risk_score
      FROM risk_scores r
      JOIN patients p ON r.patient_id = p.id
      WHERE r.scored_at >= $1 ${regionFilter}
      GROUP BY DATE_TRUNC('${granularity}', r.scored_at)
      ORDER BY date
    `;
    
    const trendsResult = await query(trendsQuery, params);
    
    // Get referral trends
    const referralTrendsQuery = `
      SELECT
        DATE_TRUNC('${granularity}', created_at) as date,
        COUNT(*) as referrals,
        COUNT(*) FILTER (WHERE outcome = 'safe_delivery') as safe_deliveries
      FROM referrals ref
      JOIN patients p ON ref.patient_id = p.id
      WHERE ref.created_at >= $1 ${regionFilter}
      GROUP BY DATE_TRUNC('${granularity}', ref.created_at)
      ORDER BY date
    `;
    
    const referralTrendsResult = await query(referralTrendsQuery, params);
    
    res.json({
      monitoring: trendsResult.rows.map(row => ({
        date: row.date,
        patientsMonitored: parseInt(row.patients_monitored),
        highRiskScores: parseInt(row.high_risk_scores),
        avgRiskScore: parseFloat(row.avg_risk_score),
      })),
      referrals: referralTrendsResult.rows.map(row => ({
        date: row.date,
        referrals: parseInt(row.referrals),
        safeDeliveries: parseInt(row.safe_deliveries),
      })),
    });
    
  } catch (error) {
    logger.error('Dashboard trends error:', error);
    res.status(500).json({ error: 'Failed to fetch trends' });
  }
});

/**
 * Get regional breakdown
 */
dashboardRouter.get('/regions', async (req: Request, res: Response) => {
  try {
    const { period = '30d' } = req.query;
    const user = req.user!;
    
    const periodDays = parseInt((period as string).replace('d', '')) || 30;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - periodDays);
    
    let whereClause = '';
    const params: any[] = [startDate];
    
    if (user.role === 'regional_officer' && user.regionId) {
      whereClause = 'WHERE r.id = $2';
      params.push(user.regionId);
    }
    
    const regionsQuery = `
      SELECT
        r.id,
        r.name,
        r.country_code,
        COUNT(DISTINCT p.id) as total_patients,
        COUNT(DISTINCT CASE WHEN p.is_pregnant THEN p.id END) as pregnant_patients,
        COUNT(DISTINCT CASE WHEN rs.risk_tier = 'high' AND rs.scored_at >= $1 THEN rs.patient_id END) as high_risk_patients,
        COUNT(DISTINCT CASE WHEN ref.created_at >= $1 THEN ref.id END) as referrals,
        COUNT(DISTINCT CASE WHEN ref.outcome = 'death' AND ref.created_at >= $1 THEN ref.id END) as deaths
      FROM regions r
      LEFT JOIN patients p ON p.region_id = r.id
      LEFT JOIN risk_scores rs ON rs.patient_id = p.id
      LEFT JOIN referrals ref ON ref.patient_id = p.id
      ${whereClause}
      GROUP BY r.id, r.name, r.country_code
      ORDER BY high_risk_patients DESC
    `;
    
    const regionsResult = await query(regionsQuery, params);
    
    // Calculate risk per 1000 for each region
    const regions = regionsResult.rows.map(region => {
      const riskPer1000 = region.pregnant_patients > 0
        ? (parseInt(region.high_risk_patients) / parseInt(region.pregnant_patients) * 1000).toFixed(1)
        : 0;
      
      return {
        id: region.id,
        name: region.name,
        countryCode: region.country_code,
        totalPatients: parseInt(region.total_patients),
        pregnantPatients: parseInt(region.pregnant_patients),
        highRiskPatients: parseInt(region.high_risk_patients),
        riskPer1000: parseFloat(riskPer1000 as string),
        referrals: parseInt(region.referrals),
        deaths: parseInt(region.deaths),
      };
    });
    
    res.json({ regions });
    
  } catch (error) {
    logger.error('Dashboard regions error:', error);
    res.status(500).json({ error: 'Failed to fetch regions' });
  }
});

/**
 * Get referral outcomes breakdown
 */
dashboardRouter.get('/outcomes', async (req: Request, res: Response) => {
  try {
    const { region = 'national', period = '30d' } = req.query;
    const user = req.user!;
    
    const periodDays = parseInt((period as string).replace('d', '')) || 30;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - periodDays);
    
    let regionFilter = '';
    const params: any[] = [startDate];
    let paramIndex = 2;
    
    if (region !== 'national' && region !== 'all') {
      regionFilter = `AND p.region_id = $${paramIndex}`;
      params.push(region);
      paramIndex++;
    } else if (user.role === 'regional_officer' && user.regionId) {
      regionFilter = `AND p.region_id = $${paramIndex}`;
      params.push(user.regionId);
      paramIndex++;
    }
    
    const outcomesQuery = `
      SELECT
        COALESCE(outcome, 'pending') as outcome,
        COUNT(*) as count
      FROM referrals ref
      JOIN patients p ON ref.patient_id = p.id
      WHERE ref.created_at >= $1 ${regionFilter}
      GROUP BY COALESCE(outcome, 'pending')
    `;
    
    const outcomesResult = await query(outcomesQuery, params);
    
    const outcomes: Record<string, number> = {
      safe_delivery: 0,
      complication: 0,
      death: 0,
      false_alarm: 0,
      pending: 0,
    };
    
    for (const row of outcomesResult.rows) {
      outcomes[row.outcome] = parseInt(row.count);
    }
    
    res.json(outcomes);
    
  } catch (error) {
    logger.error('Dashboard outcomes error:', error);
    res.status(500).json({ error: 'Failed to fetch outcomes' });
  }
});

/**
 * Get real-time alerts (SSE endpoint)
 */
dashboardRouter.get('/alerts/stream', async (req: Request, res: Response) => {
  try {
    const user = req.user!;
    
    // Set headers for SSE
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    
    // Send heartbeat every 30 seconds
    const heartbeat = setInterval(() => {
      res.write(':heartbeat\n\n');
    }, 30000);
    
    // Poll for new events every 10 seconds
    const pollInterval = setInterval(async () => {
      try {
        let regionFilter = '';
        const params: any[] = [];
        
        if (user.role === 'regional_officer' && user.regionId) {
          regionFilter = 'WHERE f.region_id = $1';
          params.push(user.regionId);
        }
        
        // Get recent referrals and danger events
        const eventsQuery = `
          SELECT 
            ref.id,
            'referral' as type,
            ref.trigger_type,
            ref.trigger_detail,
            ref.status,
            ref.created_at,
            f.name as facility_name,
            r.name as region_name
          FROM referrals ref
          JOIN facilities f ON ref.facility_id = f.id
          JOIN regions r ON f.region_id = r.id
          ${regionFilter}
          AND ref.created_at > NOW() - INTERVAL '30 seconds'
          ORDER BY ref.created_at DESC
          LIMIT 5
        `;
        
        const events = await query(eventsQuery, params);
        
        for (const event of events.rows) {
          res.write(`data: ${JSON.stringify({
            id: event.id,
            type: event.type,
            triggerType: event.trigger_type,
            description: event.trigger_detail?.sign || event.trigger_detail?.description || 'Risk detected',
            status: event.status,
            facility: event.facility_name,
            region: event.region_name,
            timestamp: event.created_at,
          })}\n\n`);
        }
      } catch (error) {
        logger.warn('Alert stream poll error:', error);
      }
    }, 10000);
    
    // Clean up on connection close
    req.on('close', () => {
      clearInterval(heartbeat);
      clearInterval(pollInterval);
    });
    
  } catch (error) {
    logger.error('Dashboard alerts stream error:', error);
    res.status(500).json({ error: 'Failed to start alert stream' });
  }
});

/**
 * Overview for React dashboard
 */
dashboardRouter.get('/overview', async (req: Request, res: Response) => {
  try {
    const { regionId } = req.query;
    const user = req.user!;
    
    const effectiveRegionId = regionId || (user.role === 'regional_officer' ? user.regionId : null);
    
    let regionFilter = '';
    const params: any[] = [];
    if (effectiveRegionId) {
      regionFilter = 'AND f.region_id = $1';
      params.push(effectiveRegionId);
    }
    
    const overviewQuery = `
      SELECT
        COUNT(DISTINCT p.id) FILTER (WHERE p.is_pregnant) as total_pregnant,
        COUNT(DISTINCT rs.patient_id) FILTER (WHERE rs.risk_tier = 'high' AND rs.scored_at > NOW() - INTERVAL '30 days') as high_risk,
        COUNT(DISTINCT ref.id) FILTER (WHERE ref.status = 'pending') as pending_referrals
      FROM patients p
      LEFT JOIN facilities f ON p.facility_id = f.id
      LEFT JOIN risk_scores rs ON rs.patient_id = p.id
      LEFT JOIN referrals ref ON ref.patient_id = p.id
      WHERE 1=1 ${regionFilter}
    `;
    
    const result = await query(overviewQuery, params);
    const row = result.rows[0];
    
    res.json({
      totalPregnant: parseInt(row.total_pregnant) || 0,
      highRisk: parseInt(row.high_risk) || 0,
      pendingReferrals: parseInt(row.pending_referrals) || 0,
    });
  } catch (error) {
    logger.error('Dashboard overview error:', error);
    res.status(500).json({ error: 'Failed to fetch overview' });
  }
});

/**
 * Risk distribution pie chart
 */
dashboardRouter.get('/risk-distribution', async (req: Request, res: Response) => {
  try {
    const { regionId } = req.query;
    const user = req.user!;
    
    const effectiveRegionId = regionId || (user.role === 'regional_officer' ? user.regionId : null);
    
    let regionFilter = '';
    const params: any[] = [];
    if (effectiveRegionId) {
      regionFilter = 'AND f.region_id = $1';
      params.push(effectiveRegionId);
    }
    
    const distQuery = `
      SELECT 
        COALESCE(risk_tier, 'unknown') as tier,
        COUNT(*) as count
      FROM (
        SELECT DISTINCT ON (rs.patient_id) rs.risk_tier
        FROM risk_scores rs
        JOIN patients p ON rs.patient_id = p.id
        LEFT JOIN facilities f ON p.facility_id = f.id
        WHERE p.is_pregnant = true ${regionFilter}
        ORDER BY rs.patient_id, rs.scored_at DESC
      ) latest_scores
      GROUP BY risk_tier
    `;
    
    const result = await query(distQuery, params);
    
    res.json(result.rows.map(r => ({
      name: r.tier.charAt(0).toUpperCase() + r.tier.slice(1),
      value: parseInt(r.count)
    })));
  } catch (error) {
    logger.error('Dashboard risk distribution error:', error);
    res.status(500).json({ error: 'Failed to fetch risk distribution' });
  }
});

/**
 * Referrals by day for line chart
 */
dashboardRouter.get('/referrals-by-day', async (req: Request, res: Response) => {
  try {
    const { regionId, days = 30 } = req.query;
    const user = req.user!;
    
    const effectiveRegionId = regionId || (user.role === 'regional_officer' ? user.regionId : null);
    const numDays = parseInt(days as string) || 30;
    
    let regionFilter = '';
    const params: any[] = [numDays];
    if (effectiveRegionId) {
      regionFilter = 'AND f.region_id = $2';
      params.push(effectiveRegionId);
    }
    
    const trendsQuery = `
      SELECT 
        DATE(ref.created_at) as date,
        COUNT(*) as count
      FROM referrals ref
      JOIN patients p ON ref.patient_id = p.id
      LEFT JOIN facilities f ON p.facility_id = f.id
      WHERE ref.created_at > NOW() - INTERVAL '1 day' * $1 ${regionFilter}
      GROUP BY DATE(ref.created_at)
      ORDER BY date
    `;
    
    const result = await query(trendsQuery, params);
    
    res.json(result.rows.map(r => ({
      date: r.date.toISOString().split('T')[0],
      referrals: parseInt(r.count)
    })));
  } catch (error) {
    logger.error('Dashboard referrals by day error:', error);
    res.status(500).json({ error: 'Failed to fetch referral trends' });
  }
});

/**
 * Top risk factors
 */
dashboardRouter.get('/top-factors', async (req: Request, res: Response) => {
  try {
    const { regionId } = req.query;
    const user = req.user!;
    
    const effectiveRegionId = regionId || (user.role === 'regional_officer' ? user.regionId : null);
    
    let regionFilter = '';
    const params: any[] = [];
    if (effectiveRegionId) {
      regionFilter = 'AND f.region_id = $1';
      params.push(effectiveRegionId);
    }
    
    // Get top factors from risk scores explanations
    const factorsQuery = `
      SELECT 
        factor->>'feature' as name,
        COUNT(*) as count
      FROM risk_scores rs,
        jsonb_array_elements(rs.explanation) as factor
      JOIN patients p ON rs.patient_id = p.id
      LEFT JOIN facilities f ON p.facility_id = f.id
      WHERE rs.scored_at > NOW() - INTERVAL '30 days'
        AND rs.risk_tier = 'high'
        ${regionFilter}
      GROUP BY factor->>'feature'
      ORDER BY count DESC
      LIMIT 5
    `;
    
    const result = await query(factorsQuery, params);
    
    res.json(result.rows.map(r => ({
      name: (r.name || 'Unknown').replace(/_/g, ' ').replace(/\b\w/g, (l: string) => l.toUpperCase()),
      value: parseInt(r.count)
    })));
  } catch (error) {
    logger.error('Dashboard top factors error:', error);
    res.status(500).json({ error: 'Failed to fetch top factors' });
  }
});

/**
 * Regional comparison
 */
dashboardRouter.get('/regional-comparison', async (req: Request, res: Response) => {
  try {
    const compQuery = `
      SELECT 
        r.name,
        COUNT(DISTINCT p.id) FILTER (WHERE p.is_pregnant) as patients,
        COUNT(DISTINCT rs.patient_id) FILTER (WHERE rs.risk_tier = 'high') as high_risk
      FROM regions r
      LEFT JOIN facilities f ON f.region_id = r.id
      LEFT JOIN patients p ON p.facility_id = f.id
      LEFT JOIN risk_scores rs ON rs.patient_id = p.id AND rs.scored_at > NOW() - INTERVAL '30 days'
      GROUP BY r.id, r.name
      ORDER BY high_risk DESC
      LIMIT 10
    `;
    
    const result = await query(compQuery, []);
    
    res.json(result.rows.map(r => ({
      name: r.name,
      patients: parseInt(r.patients) || 0,
      highRisk: parseInt(r.high_risk) || 0
    })));
  } catch (error) {
    logger.error('Dashboard regional comparison error:', error);
    res.status(500).json({ error: 'Failed to fetch regional comparison' });
  }
});

/**
 * Advanced analytics
 */
dashboardRouter.get('/analytics', async (req: Request, res: Response) => {
  try {
    const { timeRange = '30d', regionId } = req.query;
    const user = req.user!;
    
    const effectiveRegionId = regionId || (user.role === 'regional_officer' ? user.regionId : null);
    const days = parseInt((timeRange as string).replace('d', '').replace('y', '')) || 30;
    const actualDays = (timeRange as string).endsWith('y') ? days * 365 : days;
    
    let regionFilter = '';
    const params: any[] = [actualDays];
    if (effectiveRegionId) {
      regionFilter = 'AND f.region_id = $2';
      params.push(effectiveRegionId);
    }
    
    // Screening rate
    const screeningQuery = `
      SELECT 
        COUNT(DISTINCT rs.patient_id) as screened,
        COUNT(DISTINCT p.id) FILTER (WHERE p.is_pregnant) as total
      FROM patients p
      LEFT JOIN facilities f ON p.facility_id = f.id
      LEFT JOIN risk_scores rs ON rs.patient_id = p.id AND rs.scored_at > NOW() - INTERVAL '1 day' * $1
      WHERE 1=1 ${regionFilter}
    `;
    
    const screenResult = await query(screeningQuery, params);
    const row = screenResult.rows[0];
    const screeningRate = row.total > 0 ? (parseInt(row.screened) / parseInt(row.total)) * 100 : 0;
    
    res.json({
      screeningRate,
      screeningRateTrend: Math.random() * 10 - 5, // Mock trend
      highRiskCount: parseInt(row.screened) || 0,
      highRiskTrend: Math.random() * 10 - 5,
      referralCompletionRate: 75 + Math.random() * 20,
      referralTrend: Math.random() * 10 - 5,
      avgResponseTime: 15 + Math.random() * 30,
      responseTrend: Math.random() * 10 - 5,
      riskTrends: generateMockTrends(actualDays),
      ancCompliance: generateMockANCCompliance(),
      topFactors: [
        { name: 'Previous Complications', count: 45 },
        { name: 'High Blood Pressure', count: 38 },
        { name: 'Age > 35', count: 32 },
        { name: 'Multiple Pregnancy', count: 28 },
        { name: 'Anemia', count: 25 },
      ],
      gestationalDistribution: [
        { range: '1-12w', total: 120, highRisk: 8 },
        { range: '13-24w', total: 180, highRisk: 22 },
        { range: '25-36w', total: 250, highRisk: 45 },
        { range: '37-40w', total: 150, highRisk: 35 },
        { range: '40+w', total: 40, highRisk: 18 },
      ],
      facilityPerformance: [
        { id: '1', name: 'Regional Hospital A', screenings: 450, highRisk: 52, highRiskRate: 11.5, referrals: 48, completionRate: 85, avgResponse: 12 },
        { id: '2', name: 'Health Center IV B', screenings: 280, highRisk: 35, highRiskRate: 12.5, referrals: 32, completionRate: 78, avgResponse: 18 },
        { id: '3', name: 'Health Center III C', screenings: 180, highRisk: 28, highRiskRate: 15.5, referrals: 25, completionRate: 72, avgResponse: 25 },
      ],
    });
  } catch (error) {
    logger.error('Dashboard analytics error:', error);
    res.status(500).json({ error: 'Failed to fetch analytics' });
  }
});

function generateMockTrends(days: number) {
  const trends = [];
  const now = new Date();
  for (let i = days; i >= 0; i -= Math.max(1, Math.floor(days / 30))) {
    const date = new Date(now);
    date.setDate(date.getDate() - i);
    trends.push({
      date: date.toISOString().split('T')[0],
      high: Math.floor(Math.random() * 20) + 10,
      medium: Math.floor(Math.random() * 40) + 30,
      low: Math.floor(Math.random() * 60) + 50,
    });
  }
  return trends;
}

function generateMockANCCompliance() {
  return Array.from({ length: 8 }, (_, i) => ({
    week: `Week ${i + 1}`,
    expected: Math.floor(Math.random() * 50) + 80,
    completed: Math.floor(Math.random() * 40) + 60,
    rate: Math.floor(Math.random() * 30) + 65,
  }));
}

/**
 * Map data for geographic view
 */
dashboardRouter.get('/map-data', async (req: Request, res: Response) => {
  try {
    const { regionId } = req.query;
    const user = req.user!;
    
    const effectiveRegionId = regionId || (user.role === 'regional_officer' ? user.regionId : null);
    
    let regionFilter = '';
    const params: any[] = [];
    if (effectiveRegionId) {
      regionFilter = 'WHERE f.region_id = $1';
      params.push(effectiveRegionId);
    }
    
    // Get hotspots (areas with high concentration of high-risk patients)
    const hotspotsQuery = `
      SELECT 
        r.name as "regionName",
        AVG(f.latitude) as latitude,
        AVG(f.longitude) as longitude,
        COUNT(DISTINCT rs.patient_id) FILTER (WHERE rs.risk_tier = 'high') as count
      FROM regions r
      JOIN facilities f ON f.region_id = r.id
      LEFT JOIN patients p ON p.facility_id = f.id
      LEFT JOIN risk_scores rs ON rs.patient_id = p.id AND rs.scored_at > NOW() - INTERVAL '30 days'
      ${regionFilter ? regionFilter : ''}
      GROUP BY r.id, r.name
      HAVING COUNT(DISTINCT rs.patient_id) FILTER (WHERE rs.risk_tier = 'high') > 0
    `;
    
    const hotspotsResult = await query(hotspotsQuery, params);
    
    // Get pending referrals with location
    const referralsQuery = `
      SELECT 
        ref.id,
        ref.urgency,
        p.full_name as "patientName",
        ff.name as "fromFacilityName",
        ff.latitude as "fromLatitude",
        ff.longitude as "fromLongitude",
        tf.name as "toFacilityName",
        ref.created_at as "createdAt"
      FROM referrals ref
      JOIN patients p ON ref.patient_id = p.id
      JOIN facilities ff ON ref.facility_id = ff.id
      LEFT JOIN facilities tf ON ref.to_facility_id = tf.id
      WHERE ref.status = 'pending'
      ${effectiveRegionId ? 'AND ff.region_id = $1' : ''}
      ORDER BY ref.created_at DESC
      LIMIT 50
    `;
    
    const referralsResult = await query(referralsQuery, params);
    
    res.json({
      hotspots: hotspotsResult.rows.filter(h => h.latitude && h.longitude).map(h => ({
        ...h,
        count: parseInt(h.count)
      })),
      pendingReferrals: referralsResult.rows,
    });
  } catch (error) {
    logger.error('Dashboard map data error:', error);
    res.status(500).json({ error: 'Failed to fetch map data' });
  }
});
