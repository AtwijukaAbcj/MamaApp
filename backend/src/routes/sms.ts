import { Router, Request, Response } from 'express';
import { query } from '../database/index.js';
import { logger } from '../utils/logger.js';
import { hashPhone, encrypt } from '../utils/crypto.js';
import { smsQueue } from '../queues/index.js';
import { v4 as uuidv4 } from 'uuid';

export const smsRouter = Router();

// Keyword handlers
const KEYWORDS: Record<string, (phone: string, fullText: string) => Promise<string>> = {
  'LEARN': handleLearn,
  'PREGNANT': handlePregnant,
  'HELP': handleHelp,
  'STOP': handleStop,
  'INFO': handleInfo,
  'CLINIC': handleClinic,
};

/**
 * Incoming SMS webhook handler
 * Africa's Talking sends POST requests here
 */
smsRouter.post('/incoming', async (req: Request, res: Response) => {
  try {
    const { from, text, to, date } = req.body;
    
    logger.info(`SMS Received: from=${from.substring(0, 7)}***, text="${text}"`);
    
    // Parse the keyword (first word of the message)
    const words = text.trim().toUpperCase().split(/\s+/);
    const keyword = words[0];
    
    // Find and execute the handler
    const handler = KEYWORDS[keyword];
    let response: string;
    
    if (handler) {
      response = await handler(from, text);
    } else {
      response = await handleUnknown(from, text);
    }
    
    // Queue the response SMS
    await smsQueue.add('send-sms', {
      to: from,
      message: response,
    });
    
    res.status(200).json({ status: 'received' });
    
  } catch (error) {
    logger.error('SMS handler error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * LEARN - Subscribe to weekly SRH education series
 */
async function handleLearn(phone: string, fullText: string): Promise<string> {
  const phoneHash = hashPhone(phone);
  const phoneEncrypted = encrypt(phone);
  
  // Check if already subscribed
  const existing = await query(
    `SELECT id, current_message FROM sms_subscriptions 
     WHERE phone_hash = $1 AND unsubscribed_at IS NULL`,
    [phoneHash]
  );
  
  if (existing.rows.length > 0) {
    return `You're already enrolled in our health education series! Message ${existing.rows[0].current_message} coming soon. Text STOP to unsubscribe.`;
  }
  
  // Get the default campaign (or parse language from message)
  const language = detectLanguage(fullText) || 'en';
  const campaign = await query<{ id: string; name: string; total_messages: number }>(
    `SELECT id, name, total_messages FROM sms_campaigns 
     WHERE language = $1 AND is_active = TRUE 
     LIMIT 1`,
    [language]
  );
  
  if (campaign.rows.length === 0) {
    // Use default English campaign
    const defaultCampaign = await query<{ id: string }>(
      `SELECT id FROM sms_campaigns WHERE language = 'en' AND is_active = TRUE LIMIT 1`,
      []
    );
    
    if (defaultCampaign.rows.length === 0) {
      return `Thank you for your interest! Our education series will start soon. We'll send you health tips weekly.`;
    }
  }
  
  const campaignId = campaign.rows[0]?.id;
  
  // Create subscription
  await query(
    `INSERT INTO sms_subscriptions (id, phone_hash, phone_encrypted, campaign_id, current_message, subscribed_at)
     VALUES ($1, $2, $3, $4, 1, NOW())`,
    [uuidv4(), phoneHash, phoneEncrypted, campaignId]
  );
  
  // Send first message immediately
  const firstMessage = await getEducationMessage(campaignId, 1);
  
  return `Welcome to MamaApp Health Education! 📚\n\n${firstMessage}\n\nYou'll receive weekly health tips. Text STOP anytime to unsubscribe.`;
}

/**
 * PREGNANT - Immediate pregnancy information
 */
async function handlePregnant(phone: string, fullText: string): Promise<string> {
  return `Congratulations on your pregnancy! 🤰

Important early steps:
1. Visit a health clinic for antenatal care (ANC)
2. Take folic acid supplements
3. Eat nutritious foods
4. Get tested for HIV, malaria, and other infections

DANGER SIGNS - Seek help IMMEDIATELY if you experience:
⚠️ Vaginal bleeding
⚠️ Severe headache
⚠️ Swelling in face/hands
⚠️ Reduced baby movement
⚠️ High fever

Text CLINIC to find a health facility near you.
Text LEARN for weekly pregnancy tips.`;
}

/**
 * HELP - Crisis resources and emergency contacts
 */
async function handleHelp(phone: string, fullText: string): Promise<string> {
  const countryPrefix = extractCountryPrefix(phone);
  
  const helplines: Record<string, string> = {
    '+234': 'Nigeria: NAPTIP 0800-0000-0001\nGender Violence: 08006002000',
    '+254': 'Kenya: Gender Violence: 0800-720-990\nChild Helpline: 116',
    '+233': 'Ghana: DOVVSU: 0800-111-222\nChild Helpline: 0800-900-900',
    '+256': 'Uganda: National Helpline: 0800-111-511',
    '+255': 'Tanzania: GBV Hotline: 116',
  };
  
  const localHelp = helplines[countryPrefix] || 'Contact your local health center or police station for help.';
  
  return `You are NOT alone. Help is available. 💙

${localHelp}

If you're in immediate danger, go to the nearest police station or health facility.

You deserve to be safe and respected.

Text CLINIC to find a health facility.`;
}

/**
 * STOP - Unsubscribe from SMS series
 */
async function handleStop(phone: string, fullText: string): Promise<string> {
  const phoneHash = hashPhone(phone);
  
  await query(
    `UPDATE sms_subscriptions SET unsubscribed_at = NOW() WHERE phone_hash = $1`,
    [phoneHash]
  );
  
  return `You've been unsubscribed from MamaApp messages. We hope the information was helpful! Text LEARN anytime to rejoin.`;
}

/**
 * INFO - General information about MamaApp
 */
async function handleInfo(phone: string, fullText: string): Promise<string> {
  return `MamaApp provides free, confidential health education for young women and mothers.

Available commands:
📚 LEARN - Start weekly health education
🤰 PREGNANT - Pregnancy information
🏥 CLINIC - Find health facilities
🆘 HELP - Crisis support
❌ STOP - Unsubscribe

All information is private and anonymous.`;
}

/**
 * CLINIC - Find nearby health facilities
 */
async function handleClinic(phone: string, fullText: string): Promise<string> {
  const countryPrefix = extractCountryPrefix(phone);
  const countryCode = countryCodeFromPrefix(countryPrefix);
  
  try {
    const result = await query<{ name: string; address: string; phone: string }>(
      `SELECT f.name, f.address, f.phone FROM facilities f
       JOIN regions r ON f.region_id = r.id
       WHERE r.country_code = $1
       LIMIT 3`,
      [countryCode]
    );
    
    if (result.rows.length > 0) {
      const facilities = result.rows
        .map(f => `📍 ${f.name}\n${f.address || ''}\n📞 ${f.phone}`)
        .join('\n\n');
      
      return `Health Facilities Near You:\n\n${facilities}`;
    }
    
    return `For health services, visit your nearest government health center or hospital. They provide free or low-cost maternal care.`;
    
  } catch (error) {
    logger.error('Error finding clinics:', error);
    return `For health services, visit your nearest government health center or hospital.`;
  }
}

/**
 * Unknown keyword - provide help
 */
async function handleUnknown(phone: string, fullText: string): Promise<string> {
  return `Welcome to MamaApp! 💙

Text one of these keywords:
• LEARN - Health education series
• PREGNANT - Pregnancy info
• CLINIC - Find health facilities
• HELP - Crisis support
• INFO - Learn more about MamaApp`;
}

/**
 * Get education message content from database
 */
async function getEducationMessage(campaignId: string, messageNumber: number): Promise<string> {
  try {
    const result = await query<{ content: string }>(
      `SELECT c.content FROM srh_content c
       JOIN sms_campaigns sc ON c.topic = sc.topic AND c.language = sc.language
       WHERE sc.id = $1 AND c.page = $2 AND c.channel = 'sms'`,
      [campaignId, messageNumber]
    );
    
    if (result.rows.length > 0) {
      return result.rows[0].content;
    }
    
    // Fallback content
    return 'Your health matters! Visit your nearest clinic for check-ups. Text HELP if you need support.';
    
  } catch (error) {
    logger.error('Error getting education message:', error);
    return 'Stay healthy! Visit your nearest clinic for regular check-ups.';
  }
}

function detectLanguage(text: string): string | null {
  const lower = text.toLowerCase();
  if (lower.includes('francais') || lower.includes('français') || lower.includes('french')) return 'fr';
  if (lower.includes('swahili') || lower.includes('kiswahili')) return 'sw';
  if (lower.includes('hausa')) return 'ha';
  if (lower.includes('yoruba') || lower.includes('yorùbá')) return 'yo';
  return null;
}

function extractCountryPrefix(phone: string): string {
  const match = phone.match(/^\+(\d{1,3})/);
  return match ? `+${match[1]}` : '+234';
}

function countryCodeFromPrefix(prefix: string): string {
  const map: Record<string, string> = {
    '+234': 'NG',
    '+254': 'KE',
    '+233': 'GH',
    '+256': 'UG',
    '+255': 'TZ',
    '+250': 'RW',
    '+225': 'CI',
  };
  return map[prefix] || 'NG';
}
