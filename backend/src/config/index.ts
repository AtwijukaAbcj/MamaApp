import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const configSchema = z.object({
  port: z.number().default(4000),
  nodeEnv: z.enum(['development', 'production', 'test']).default('development'),
  
  // Database
  databaseUrl: z.string().default('postgres://mama:mama_dev_password@localhost:5432/mamaapp'),
  redisUrl: z.string().default('redis://localhost:6379'),
  
  // Africa's Talking
  atApiKey: z.string().default('sandbox'),
  atUsername: z.string().default('sandbox'),
  atSenderId: z.string().default('MamaApp'),
  atUssdCode: z.string().default('*384*123#'),
  
  // Firebase
  firebaseProjectId: z.string().optional(),
  firebaseClientEmail: z.string().optional(),
  firebasePrivateKey: z.string().optional(),
  
  // JWT
  jwtSecret: z.string().default('dev_jwt_secret_at_least_32_characters_long'),
  jwtExpiresIn: z.string().default('7d'),
  
  // Encryption
  encryptionKey: z.string().default('dev_encryption_key_32_chars_here!'),
  
  // AI Engine
  aiEngineUrl: z.string().default('http://localhost:8000'),
  
  // CORS
  corsOrigins: z.array(z.string()).default(['http://localhost:3000', 'http://localhost:5173']),
  
  // Twilio (optional)
  twilioAccountSid: z.string().optional(),
  twilioAuthToken: z.string().optional(),
  twilioPhoneNumber: z.string().optional(),
});

const parseConfig = () => {
  const result = configSchema.safeParse({
    port: parseInt(process.env.PORT || '3000'),
    nodeEnv: process.env.NODE_ENV,
    databaseUrl: process.env.DATABASE_URL,
    redisUrl: process.env.REDIS_URL,
    atApiKey: process.env.AT_API_KEY,
    atUsername: process.env.AT_USERNAME,
    atSenderId: process.env.AT_SENDER_ID,
    atUssdCode: process.env.AT_USSD_CODE,
    firebaseProjectId: process.env.FIREBASE_PROJECT_ID,
    firebaseClientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    firebasePrivateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    jwtSecret: process.env.JWT_SECRET,
    jwtExpiresIn: process.env.JWT_EXPIRES_IN,
    encryptionKey: process.env.ENCRYPTION_KEY,
    aiEngineUrl: process.env.AI_ENGINE_URL,
    corsOrigins: process.env.CORS_ORIGINS?.split(',') || ['http://localhost:3001'],
    twilioAccountSid: process.env.TWILIO_ACCOUNT_SID,
    twilioAuthToken: process.env.TWILIO_AUTH_TOKEN,
    twilioPhoneNumber: process.env.TWILIO_PHONE_NUMBER,
  });

  if (!result.success) {
    console.error('Invalid configuration:', result.error.format());
    // In development, allow missing optional fields
    if (process.env.NODE_ENV === 'development') {
      console.warn('Running in development mode with partial config');
    }
  }

  return result.data || {} as z.infer<typeof configSchema>;
};

export const config = parseConfig();
export type Config = z.infer<typeof configSchema>;
