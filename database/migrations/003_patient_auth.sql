-- Migration: Add patient authentication
-- Allows patients to log in and self-monitor

-- Add authentication fields to patients table
ALTER TABLE patients ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
ALTER TABLE patients ADD COLUMN IF NOT EXISTS pin_hash VARCHAR(255);
ALTER TABLE patients ADD COLUMN IF NOT EXISTS device_token VARCHAR(255); -- FCM for push notifications
ALTER TABLE patients ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ;
ALTER TABLE patients ADD COLUMN IF NOT EXISTS alert_preferences JSONB DEFAULT '{"sms": true, "push": true, "healthWorker": true}';

-- Index for patient phone lookup
CREATE INDEX IF NOT EXISTS idx_patients_phone ON patients(phone);

-- Patient vitals thresholds (customizable per patient)
CREATE TABLE IF NOT EXISTS patient_thresholds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    vital_type VARCHAR(30) NOT NULL, -- 'bp_systolic', 'bp_diastolic', 'spo2', 'temp', 'fetal_hr'
    warning_min DECIMAL(10, 2),
    warning_max DECIMAL(10, 2),
    danger_min DECIMAL(10, 2),
    danger_max DECIMAL(10, 2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(patient_id, vital_type)
);

-- Alerts sent to patients
CREATE TABLE IF NOT EXISTS patient_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES patients(id),
    reading_id UUID, -- optional link to the reading that triggered it
    alert_type VARCHAR(50) NOT NULL, -- 'danger_vital', 'warning_vital', 'reminder', 'appointment'
    vital_type VARCHAR(30),
    message TEXT NOT NULL,
    severity VARCHAR(20) NOT NULL DEFAULT 'warning', -- 'info', 'warning', 'danger', 'critical'
    sent_via TEXT[], -- ['push', 'sms']
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    read_at TIMESTAMPTZ,
    acknowledged_at TIMESTAMPTZ,
    health_worker_notified BOOLEAN DEFAULT FALSE,
    health_worker_notified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_patient_alerts_patient ON patient_alerts(patient_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_patient_alerts_unread ON patient_alerts(patient_id) WHERE read_at IS NULL;

-- Default thresholds (applied when patient has no custom thresholds)
CREATE TABLE IF NOT EXISTS default_thresholds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vital_type VARCHAR(30) NOT NULL UNIQUE,
    warning_min DECIMAL(10, 2),
    warning_max DECIMAL(10, 2),
    danger_min DECIMAL(10, 2),
    danger_max DECIMAL(10, 2),
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default pregnancy thresholds
INSERT INTO default_thresholds (vital_type, warning_min, warning_max, danger_min, danger_max, description) VALUES
('bp_systolic', NULL, 130, NULL, 140, 'Systolic blood pressure in mmHg'),
('bp_diastolic', NULL, 85, NULL, 90, 'Diastolic blood pressure in mmHg'),
('spo2', 95, NULL, 92, NULL, 'Blood oxygen saturation percentage'),
('temp', 36.0, 37.5, 35.5, 38.0, 'Body temperature in Celsius'),
('fetal_hr', 110, 160, 100, 170, 'Fetal heart rate in BPM'),
('heart_rate', 60, 100, 50, 120, 'Maternal heart rate in BPM')
ON CONFLICT (vital_type) DO UPDATE SET
    warning_min = EXCLUDED.warning_min,
    warning_max = EXCLUDED.warning_max,
    danger_min = EXCLUDED.danger_min,
    danger_max = EXCLUDED.danger_max;
