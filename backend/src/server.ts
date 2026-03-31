import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import { config } from './config/index.js';
import { logger } from './utils/logger.js';
import { ussdRouter } from './routes/ussd.js';
import { smsRouter } from './routes/sms.js';
import { referralRouter } from './routes/referrals.js';
import { authRouter } from './routes/auth.js';
import { patientRouter } from './routes/patients.js';
import { patientAuthRouter } from './routes/patient-auth.js';
import { patientVitalsRouter } from './routes/patient-vitals.js';
import { syncRouter } from './routes/sync.js';
import { dashboardRouter } from './routes/dashboard.js';
import { deviceRouter } from './routes/devices.js';
import facilitiesRouter from './routes/facilities.js';
import regionsRouter from './routes/regions.js';
import { errorHandler } from './middleware/errorHandler.js';
import { initializeDatabase } from './database/index.js';
import { initializeQueues } from './queues/index.js';

const app = express();

// Security middleware
app.use(helmet());
app.use(cors({
  origin: config.corsOrigins,
  credentials: true,
}));

// Request parsing
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(compression());

// Logging
app.use(morgan('combined', {
  stream: { write: (message) => logger.info(message.trim()) }
}));

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// API Routes
app.use('/api/ussd', ussdRouter);
app.use('/api/sms', smsRouter);
app.use('/api/referrals', referralRouter);
app.use('/api/auth', authRouter);
app.use('/api/patients', patientRouter);
app.use('/api/patient', patientAuthRouter);  // Patient self-service auth
app.use('/api/patient/vitals', patientVitalsRouter);  // Patient vitals submission
app.use('/api/sync', syncRouter);
app.use('/api/dashboard', dashboardRouter);
app.use('/api/devices', deviceRouter);
app.use('/api/facilities', facilitiesRouter);
app.use('/api/regions', regionsRouter);

// Error handling
app.use(errorHandler);

// Start server
async function start() {
  try {
    await initializeDatabase();
    await initializeQueues();
    
    app.listen(config.port, () => {
      logger.info(`🚀 MamaApp Backend running on port ${config.port}`);
      logger.info(`📱 USSD endpoint: POST /api/ussd`);
      logger.info(`💬 SMS endpoint: POST /api/sms`);
      logger.info(`🏥 Referral API: /api/referrals`);
      logger.info(`📟 Device API: /api/devices`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

start();

export default app;
