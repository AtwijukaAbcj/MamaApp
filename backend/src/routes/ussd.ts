import { Router, Request, Response } from 'express';
import { query } from '../database/index.js';
import { logger } from '../utils/logger.js';
import { v4 as uuidv4 } from 'uuid';

export const ussdRouter = Router();

// Store session state in memory (use Redis in production)
const sessionStore = new Map<string, USSDSession>();

interface USSDSession {
  id: string;
  language: string;
  topicsAccessed: string[];
  currentTopic?: string;
  currentPage: number;
  startedAt: Date;
}

interface USSDRequest {
  sessionId: string;
  phoneNumber: string;
  text: string;
  serviceCode: string;
}

// Content structure for SRH education
const TOPICS = {
  '1': { key: 'reproductive_health', name: { en: 'Reproductive Health', fr: 'Santé Reproductive', sw: 'Afya ya Uzazi' }},
  '2': { key: 'menstruation', name: { en: 'Menstruation', fr: 'Menstruation', sw: 'Hedhi' }},
  '3': { key: 'pregnancy', name: { en: 'Pregnancy Info', fr: 'Infos Grossesse', sw: 'Taarifa za Ujauzito' }},
  '4': { key: 'contraception', name: { en: 'Contraception', fr: 'Contraception', sw: 'Uzazi wa Mpango' }},
  '5': { key: 'consent', name: { en: 'Consent & Safety', fr: 'Consentement & Sécurité', sw: 'Ridhaa na Usalama' }},
  '6': { key: 'find_help', name: { en: 'Find Help Near Me', fr: 'Trouver de l\'Aide', sw: 'Pata Msaada' }},
};

const LANGUAGES: Record<string, string> = {
  '1': 'en',
  '2': 'fr',
  '3': 'sw',
  '4': 'ha',
  '5': 'yo',
};

/**
 * Main USSD webhook handler
 * Africa's Talking sends POST requests here
 */
ussdRouter.post('/', async (req: Request, res: Response) => {
  try {
    const { sessionId, phoneNumber, text, serviceCode }: USSDRequest = req.body;
    
    logger.info(`USSD Request: session=${sessionId}, text="${text}"`);
    
    // Get or create session
    let session = sessionStore.get(sessionId);
    if (!session) {
      session = {
        id: uuidv4(),
        language: 'en',
        topicsAccessed: [],
        currentPage: 1,
        startedAt: new Date(),
      };
      sessionStore.set(sessionId, session);
    }
    
    // Parse user input
    const steps = text ? text.split('*').filter(s => s) : [];
    
    let response = '';
    
    // State machine for USSD navigation
    if (steps.length === 0) {
      // Initial menu - Language selection
      response = buildMainMenu(session.language);
    } else if (steps.length === 1 && steps[0] === '0') {
      // Language selection menu
      response = buildLanguageMenu();
    } else if (steps.length === 2 && steps[0] === '0') {
      // Language selected
      session.language = LANGUAGES[steps[1]] || 'en';
      response = buildMainMenu(session.language);
    } else if (steps.length === 1 && TOPICS[steps[0] as keyof typeof TOPICS]) {
      // Topic selected
      const topic = TOPICS[steps[0] as keyof typeof TOPICS];
      session.currentTopic = topic.key;
      session.topicsAccessed.push(topic.key);
      session.currentPage = 1;
      response = await buildTopicContent(topic.key, session.language, 1);
    } else if (steps.length === 2 && TOPICS[steps[0] as keyof typeof TOPICS]) {
      // Navigation within topic (next page or back)
      const action = steps[1];
      if (action === '1' && session.currentTopic) {
        // Next page
        session.currentPage++;
        response = await buildTopicContent(session.currentTopic, session.language, session.currentPage);
      } else if (action === '0') {
        // Back to main menu
        session.currentTopic = undefined;
        session.currentPage = 1;
        response = buildMainMenu(session.language);
      } else {
        response = buildMainMenu(session.language);
      }
    } else if (steps[0] === '6') {
      // Find help - show nearest clinic
      const countryPrefix = extractCountryPrefix(phoneNumber);
      response = await buildFindHelpResponse(countryPrefix, session.language);
    } else {
      // Invalid input - show main menu
      response = buildMainMenu(session.language);
    }
    
    // Log anonymous analytics
    await logUSSDSession(sessionId, extractCountryPrefix(phoneNumber), session);
    
    // Send response
    res.set('Content-Type', 'text/plain');
    res.send(response);
    
  } catch (error) {
    logger.error('USSD handler error:', error);
    res.set('Content-Type', 'text/plain');
    res.send('END Sorry, an error occurred. Please try again.');
  }
});

function buildMainMenu(lang: string): string {
  const menus: Record<string, string> = {
    en: `CON Welcome to MamaApp Health Info
1. Reproductive Health
2. Menstruation
3. Pregnancy Info
4. Contraception
5. Consent & Safety
6. Find Help Near Me
0. Change Language`,
    fr: `CON Bienvenue sur MamaApp
1. Santé Reproductive
2. Menstruation
3. Infos Grossesse
4. Contraception
5. Consentement & Sécurité
6. Trouver de l'Aide
0. Changer de Langue`,
    sw: `CON Karibu MamaApp
1. Afya ya Uzazi
2. Hedhi
3. Taarifa za Ujauzito
4. Uzazi wa Mpango
5. Ridhaa na Usalama
6. Pata Msaada
0. Badilisha Lugha`,
  };
  return menus[lang] || menus.en;
}

function buildLanguageMenu(): string {
  return `CON Select Language / Choisir la langue:
1. English
2. Français
3. Kiswahili
4. Hausa
5. Yorùbá`;
}

async function buildTopicContent(topic: string, lang: string, page: number): Promise<string> {
  try {
    // Fetch content from database
    const result = await query<{ content: string }>(
      `SELECT content FROM srh_content 
       WHERE topic = $1 AND language = $2 AND page = $3 AND channel = 'ussd'`,
      [topic, lang, page]
    );
    
    if (result.rows.length > 0) {
      const content = result.rows[0].content;
      
      // Check if there's a next page
      const nextResult = await query(
        `SELECT 1 FROM srh_content 
         WHERE topic = $1 AND language = $2 AND page = $3 AND channel = 'ussd'`,
        [topic, lang, page + 1]
      );
      
      if (nextResult.rows.length > 0) {
        return `CON ${content}\n\n1. Next\n0. Back to Menu`;
      } else {
        return `END ${content}\n\nText LEARN to ${getShortCode()} for weekly tips.`;
      }
    }
    
    // Fallback content if not in database
    return buildFallbackContent(topic, lang);
    
  } catch (error) {
    logger.error('Error fetching topic content:', error);
    return buildFallbackContent(topic, lang);
  }
}

function buildFallbackContent(topic: string, lang: string): string {
  const fallback: Record<string, Record<string, string>> = {
    reproductive_health: {
      en: `END Reproductive health includes your physical, mental, and social well-being in all matters related to reproduction.\n\nYour body belongs to you. You have the right to information and healthcare.\n\nText LEARN to get weekly health tips.`,
      fr: `END La santé reproductive comprend votre bien-être physique, mental et social.\n\nVotre corps vous appartient. Vous avez droit à l'information.\n\nEnvoyez LEARN pour des conseils.`,
    },
    menstruation: {
      en: `END Menstruation is a normal, healthy part of life for girls and women.\n\nPeriods typically last 3-7 days and occur every 21-35 days.\n\nCramps, mood changes, and fatigue are common.\n\nText LEARN for more info.`,
      fr: `END Les règles sont normales et saines.\n\nElles durent généralement 3-7 jours, tous les 21-35 jours.\n\nEnvoyez LEARN pour plus d'infos.`,
    },
    pregnancy: {
      en: `END Signs of pregnancy: missed period, nausea, breast tenderness, fatigue.\n\nIf pregnant, visit a health clinic early for proper care.\n\nDanger signs: bleeding, severe headache, swelling, reduced baby movement.\n\nSeek help immediately if these occur.`,
      fr: `END Signes de grossesse: retard de règles, nausées, fatigue.\n\nConsultez une clinique tôt pour des soins appropriés.`,
    },
    contraception: {
      en: `END Contraception helps you decide if and when to have children.\n\nOptions include: pills, injections, implants, IUDs, condoms.\n\nVisit a health facility to discuss what's right for you.\n\nCondoms also protect against STIs.`,
      fr: `END La contraception vous aide à décider si et quand avoir des enfants.\n\nConsultez un centre de santé.`,
    },
    consent: {
      en: `END You have the right to say NO to any sexual activity.\n\nConsent must be freely given, informed, and can be withdrawn.\n\nIf you've experienced violence, you are not alone.\n\nText HELP for crisis resources.`,
      fr: `END Vous avez le droit de dire NON.\n\nEnvoyez HELP pour des ressources d'aide.`,
    },
  };
  
  return fallback[topic]?.[lang] || fallback[topic]?.en || 'END Content not available. Text LEARN for more info.';
}

async function buildFindHelpResponse(countryPrefix: string, lang: string): Promise<string> {
  try {
    // Find nearest facilities based on country
    const result = await query<{ name: string; address: string; phone: string }>(
      `SELECT name, address, phone FROM facilities 
       WHERE region_id IN (
         SELECT id FROM regions WHERE country_code = $1
       )
       LIMIT 3`,
      [countryCodeFromPrefix(countryPrefix)]
    );
    
    if (result.rows.length > 0) {
      const facilities = result.rows.map(f => `${f.name}\n${f.phone}`).join('\n\n');
      return `END Nearby Health Facilities:\n\n${facilities}\n\nCall any facility for help.`;
    }
    
    // Fallback
    return `END For health emergencies, contact your nearest health center.\n\nNational helplines:\n🇳🇬 Nigeria: 0800-HEALTH\n🇰🇪 Kenya: 0800-720-990\n🇬🇭 Ghana: 112`;
    
  } catch (error) {
    logger.error('Error finding help:', error);
    return `END For health emergencies, contact your nearest health center or call emergency services.`;
  }
}

function extractCountryPrefix(phone: string): string {
  // Extract country code prefix (e.g., +234 for Nigeria)
  const match = phone.match(/^\+(\d{1,3})/);
  return match ? `+${match[1]}` : '+000';
}

function countryCodeFromPrefix(prefix: string): string {
  const map: Record<string, string> = {
    '+234': 'NG', // Nigeria
    '+254': 'KE', // Kenya
    '+233': 'GH', // Ghana
    '+256': 'UG', // Uganda
    '+255': 'TZ', // Tanzania
    '+250': 'RW', // Rwanda
    '+225': 'CI', // Côte d'Ivoire
  };
  return map[prefix] || 'NG';
}

function getShortCode(): string {
  return '40123'; // SMS shortcode
}

async function logUSSDSession(
  sessionId: string, 
  countryPrefix: string, 
  session: USSDSession
): Promise<void> {
  try {
    // Log anonymized session data for analytics
    await query(
      `INSERT INTO ussd_sessions (id, session_id, country_prefix, started_at, topics_accessed, language, total_screens)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       ON CONFLICT (session_id) DO UPDATE SET
         topics_accessed = EXCLUDED.topics_accessed,
         total_screens = EXCLUDED.total_screens`,
      [
        session.id,
        sessionId,
        countryPrefix,
        session.startedAt,
        session.topicsAccessed,
        session.language,
        session.currentPage,
      ]
    );
  } catch (error) {
    // Don't fail the request if logging fails
    logger.warn('Failed to log USSD session:', error);
  }
}
