-- MamaApp Database Schema
-- PostgreSQL 15+ with TimescaleDB extension for time-series data

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- ============================================
-- CORE TABLES
-- ============================================

-- Regions and Facilities
CREATE TABLE regions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    country_code CHAR(2) NOT NULL,
    parent_region_id UUID REFERENCES regions(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE facilities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    facility_type VARCHAR(50) NOT NULL, -- 'hospital', 'health_center', 'clinic'
    region_id UUID NOT NULL REFERENCES regions(id),
    address TEXT,
    phone VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    operating_hours JSONB,
    capabilities JSONB, -- e.g., {"csection": true, "blood_bank": true}
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Users (Health Workers, Clinicians, Officers)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    full_name VARCHAR(200) NOT NULL,
    role VARCHAR(50) NOT NULL, -- 'health_worker', 'clinician', 'regional_officer', 'national_officer'
    facility_id UUID REFERENCES facilities(id),
    region_id UUID REFERENCES regions(id),
    device_token VARCHAR(255), -- FCM token for push notifications
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Patients (Pregnant Mothers / Teenage Girls)
CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    -- Minimal PII, encrypted at rest
    full_name_encrypted BYTEA NOT NULL,
    phone_hash VARCHAR(64), -- SHA-256 hash for deduplication
    phone_encrypted BYTEA,
    date_of_birth DATE,
    age_at_registration INT,
    region_id UUID REFERENCES regions(id),
    nearest_facility_id UUID REFERENCES facilities(id),
    next_of_kin_phone_encrypted BYTEA,
    assigned_health_worker_id UUID REFERENCES users(id),
    
    -- Obstetric history
    gravida INT DEFAULT 0, -- total pregnancies
    parity INT DEFAULT 0,  -- births after 20 weeks
    prior_stillbirth BOOLEAN DEFAULT FALSE,
    prior_csection BOOLEAN DEFAULT FALSE,
    prior_preeclampsia BOOLEAN DEFAULT FALSE,
    
    -- Medical history
    hiv_positive BOOLEAN DEFAULT FALSE,
    diabetes BOOLEAN DEFAULT FALSE,
    anaemia BOOLEAN DEFAULT FALSE,
    other_conditions JSONB,
    
    -- Current pregnancy
    is_pregnant BOOLEAN DEFAULT FALSE,
    pregnancy_registered_at DATE,
    expected_delivery_date DATE,
    gestational_weeks_at_registration INT,
    multiple_pregnancy BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_patients_region ON patients(region_id);
CREATE INDEX idx_patients_health_worker ON patients(assigned_health_worker_id);
CREATE INDEX idx_patients_pregnant ON patients(is_pregnant) WHERE is_pregnant = TRUE;

-- ============================================
-- MONITORING & VITALS
-- ============================================

-- Monitoring Sessions
CREATE TABLE monitoring_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id),
    health_worker_id UUID REFERENCES users(id),
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    device_id VARCHAR(100), -- which phone/tablet
    synced_at TIMESTAMPTZ, -- NULL until cloud confirms
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Vital Readings (TimescaleDB hypertable for time-series)
CREATE TABLE readings (
    id UUID DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES monitoring_sessions(id),
    patient_id UUID NOT NULL REFERENCES patients(id),
    vital_type VARCHAR(30) NOT NULL, -- 'bp', 'spo2', 'temp', 'fetal_hr', 'fundal_height'
    values_json JSONB NOT NULL, -- e.g., {"systolic": 148, "diastolic": 96}
    recorded_at TIMESTAMPTZ NOT NULL,
    danger_level VARCHAR(20) NOT NULL DEFAULT 'normal', -- 'normal', 'warning', 'danger'
    source VARCHAR(30), -- 'ble_device', 'manual', 'simulated'
    device_name VARCHAR(100),
    synced_at TIMESTAMPTZ,
    PRIMARY KEY (id, recorded_at)
);

-- Convert to hypertable for efficient time-series queries
SELECT create_hypertable('readings', 'recorded_at');

CREATE INDEX idx_readings_patient ON readings(patient_id, recorded_at DESC);
CREATE INDEX idx_readings_danger ON readings(danger_level) WHERE danger_level IN ('warning', 'danger');

-- AI Risk Scores
CREATE TABLE risk_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id),
    session_id UUID REFERENCES monitoring_sessions(id),
    risk_score DECIMAL(5, 4) NOT NULL, -- 0.0000 to 1.0000
    risk_tier VARCHAR(20) NOT NULL, -- 'low', 'medium', 'high'
    top_factors JSONB NOT NULL, -- SHAP explanations
    input_features JSONB NOT NULL, -- what went into the model
    missing_features TEXT[], -- which features were NULL
    model_version VARCHAR(50) NOT NULL,
    scored_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_risk_scores_patient ON risk_scores(patient_id, scored_at DESC);
CREATE INDEX idx_risk_scores_high ON risk_scores(risk_tier) WHERE risk_tier = 'high';

-- ============================================
-- REFERRALS
-- ============================================

CREATE TABLE referrals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID NOT NULL REFERENCES users(id), -- health worker
    
    -- Trigger information
    trigger_type VARCHAR(30) NOT NULL, -- 'danger_sign', 'ai_score', 'manual'
    trigger_detail JSONB NOT NULL, -- e.g., {"sign": "bp_high", "value": "160/110"}
    vitals_snapshot JSONB NOT NULL, -- all vitals at moment of referral
    ai_risk_score DECIMAL(5, 4),
    
    -- Destination
    facility_id UUID NOT NULL REFERENCES facilities(id),
    assigned_clinician_id UUID REFERENCES users(id),
    eta_mins INT,
    
    -- Status tracking
    status VARCHAR(30) NOT NULL DEFAULT 'pending',
    -- pending → dispatched → acknowledged → in_transit → arrived → outcome_recorded
    acknowledged_by UUID REFERENCES users(id),
    acknowledged_at TIMESTAMPTZ,
    arrived_at TIMESTAMPTZ,
    
    -- Outcome
    outcome VARCHAR(30), -- 'safe_delivery', 'complication', 'death', 'false_alarm'
    outcome_notes TEXT,
    outcome_recorded_at TIMESTAMPTZ,
    outcome_recorded_by UUID REFERENCES users(id),
    
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_referrals_patient ON referrals(patient_id, created_at DESC);
CREATE INDEX idx_referrals_status ON referrals(status) WHERE status NOT IN ('outcome_recorded');
CREATE INDEX idx_referrals_facility ON referrals(facility_id, created_at DESC);

-- Referral Notifications
CREATE TABLE referral_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referral_id UUID NOT NULL REFERENCES referrals(id),
    channel VARCHAR(20) NOT NULL, -- 'push', 'sms', 'voice', 'dashboard'
    recipient_type VARCHAR(30) NOT NULL, -- 'health_worker', 'clinician', 'next_of_kin', 'facility'
    recipient_ref VARCHAR(255) NOT NULL, -- phone number or device token
    message_content TEXT,
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    failed_at TIMESTAMPTZ,
    error TEXT,
    retry_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_referral ON referral_notifications(referral_id);
CREATE INDEX idx_notifications_pending ON referral_notifications(sent_at) WHERE sent_at IS NULL;

-- ============================================
-- SMS/USSD PREVENTION LAYER
-- ============================================

-- SRH Educational Content
CREATE TABLE srh_content (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    topic VARCHAR(50) NOT NULL, -- 'menstruation', 'pregnancy', 'contraception', 'consent', 'sti'
    language CHAR(2) NOT NULL, -- 'en', 'fr', 'sw', 'ha', 'yo'
    page INT NOT NULL DEFAULT 1, -- for pagination
    channel VARCHAR(10) NOT NULL, -- 'ussd' (182 chars) or 'sms' (160 chars)
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(topic, language, page, channel)
);

-- USSD Sessions (anonymous - only country code prefix stored)
CREATE TABLE ussd_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id VARCHAR(100) NOT NULL, -- provider's session ID
    country_prefix VARCHAR(5) NOT NULL, -- e.g., '+234' for Nigeria
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    topics_accessed TEXT[], -- which topics were viewed
    language CHAR(2),
    total_screens INT DEFAULT 0
);

CREATE INDEX idx_ussd_sessions_date ON ussd_sessions(started_at);

-- SMS Campaigns
CREATE TABLE sms_campaigns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    topic VARCHAR(50) NOT NULL,
    language CHAR(2) NOT NULL,
    total_messages INT NOT NULL, -- e.g., 12 for a 12-week series
    interval_days INT NOT NULL DEFAULT 7, -- days between messages
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- SMS Subscriptions (phone hashed for anonymity)
CREATE TABLE sms_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_hash VARCHAR(64) NOT NULL, -- SHA-256 of phone number
    phone_encrypted BYTEA NOT NULL, -- encrypted phone for sending
    campaign_id UUID NOT NULL REFERENCES sms_campaigns(id),
    current_message INT DEFAULT 1,
    subscribed_at TIMESTAMPTZ DEFAULT NOW(),
    last_sent_at TIMESTAMPTZ,
    unsubscribed_at TIMESTAMPTZ,
    UNIQUE(phone_hash, campaign_id)
);

CREATE INDEX idx_sms_subs_active ON sms_subscriptions(campaign_id, current_message) 
    WHERE unsubscribed_at IS NULL;

-- ============================================
-- DASHBOARD & ANALYTICS
-- ============================================

-- Pre-aggregated daily metrics (materialized view for performance)
CREATE TABLE daily_metrics (
    date DATE NOT NULL,
    region_id UUID NOT NULL REFERENCES regions(id),
    patients_monitored INT DEFAULT 0,
    danger_events INT DEFAULT 0,
    warnings_issued INT DEFAULT 0,
    referrals_created INT DEFAULT 0,
    referrals_completed INT DEFAULT 0,
    safe_deliveries INT DEFAULT 0,
    complications INT DEFAULT 0,
    deaths INT DEFAULT 0,
    avg_risk_score DECIMAL(5, 4),
    ussd_sessions INT DEFAULT 0,
    sms_sent INT DEFAULT 0,
    PRIMARY KEY (date, region_id)
);

CREATE INDEX idx_daily_metrics_date ON daily_metrics(date DESC);

-- Audit Log
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_log_user ON audit_log(user_id, created_at DESC);
CREATE INDEX idx_audit_log_entity ON audit_log(entity_type, entity_id);

-- ============================================
-- SYNC & OFFLINE SUPPORT
-- ============================================

-- Outbox table for offline-first sync pattern
CREATE TABLE sync_outbox (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_id VARCHAR(100) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    operation VARCHAR(20) NOT NULL, -- 'insert', 'update', 'delete'
    payload_json JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    synced_at TIMESTAMPTZ,
    error TEXT,
    retry_count INT DEFAULT 0
);

CREATE INDEX idx_outbox_pending ON sync_outbox(device_id, created_at) WHERE synced_at IS NULL;

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_patients_updated_at
    BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_facilities_updated_at
    BEFORE UPDATE ON facilities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tr_referrals_updated_at
    BEFORE UPDATE ON referrals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Function to calculate gestational weeks
CREATE OR REPLACE FUNCTION calculate_gestational_weeks(
    registration_date DATE,
    weeks_at_registration INT,
    target_date DATE DEFAULT CURRENT_DATE
)
RETURNS INT AS $$
BEGIN
    RETURN weeks_at_registration + EXTRACT(WEEK FROM (target_date - registration_date))::INT;
END;
$$ LANGUAGE plpgsql;
