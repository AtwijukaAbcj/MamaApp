-- Seed test data for MamaApp

-- Get user ID into a temp table
CREATE TEMP TABLE user_ids AS 
SELECT id FROM users WHERE phone = '+256700000000' LIMIT 1;

-- Patient 1: Sarah - low risk
INSERT INTO patients (id, full_name_encrypted, date_of_birth, age_at_registration, region_id, nearest_facility_id, assigned_health_worker_id, gravida, parity, is_pregnant, pregnancy_registered_at, expected_delivery_date, gestational_weeks_at_registration)
SELECT 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Sarah Nakamya'::bytea, '1998-05-15', 27, '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', id, 2, 1, true, '2026-01-15', '2026-05-20', 32 FROM user_ids
ON CONFLICT (id) DO UPDATE SET full_name_encrypted = EXCLUDED.full_name_encrypted;

-- Patient 2: Grace - teenage, medium risk
INSERT INTO patients (id, full_name_encrypted, date_of_birth, age_at_registration, region_id, nearest_facility_id, assigned_health_worker_id, gravida, parity, is_pregnant, pregnancy_registered_at, expected_delivery_date, gestational_weeks_at_registration)
SELECT 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Grace Achieng'::bytea, '2008-09-22', 17, '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', id, 1, 0, true, '2026-01-15', '2026-06-15', 28 FROM user_ids
ON CONFLICT (id) DO UPDATE SET full_name_encrypted = EXCLUDED.full_name_encrypted;

-- Patient 3: Florence - high risk (age + preeclampsia history)
INSERT INTO patients (id, full_name_encrypted, date_of_birth, age_at_registration, region_id, nearest_facility_id, assigned_health_worker_id, gravida, parity, prior_preeclampsia, is_pregnant, pregnancy_registered_at, expected_delivery_date, gestational_weeks_at_registration)
SELECT 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'Florence Namukasa'::bytea, '1990-01-10', 36, '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', id, 5, 4, true, true, '2026-01-15', '2026-04-28', 36 FROM user_ids
ON CONFLICT (id) DO UPDATE SET full_name_encrypted = EXCLUDED.full_name_encrypted;

-- Patient 4: Aisha - low risk
INSERT INTO patients (id, full_name_encrypted, date_of_birth, age_at_registration, region_id, nearest_facility_id, assigned_health_worker_id, gravida, parity, is_pregnant, pregnancy_registered_at, expected_delivery_date, gestational_weeks_at_registration)
SELECT 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'Aisha Nambi'::bytea, '2006-03-08', 20, '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', id, 1, 0, true, '2026-01-15', '2026-07-10', 24 FROM user_ids
ON CONFLICT (id) DO UPDATE SET full_name_encrypted = EXCLUDED.full_name_encrypted;

-- Patient 5: Juliet - medium risk (HIV+)
INSERT INTO patients (id, full_name_encrypted, date_of_birth, age_at_registration, region_id, nearest_facility_id, assigned_health_worker_id, gravida, parity, hiv_positive, is_pregnant, pregnancy_registered_at, expected_delivery_date, gestational_weeks_at_registration)
SELECT 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'Juliet Kyambadde'::bytea, '1995-11-30', 30, '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', id, 3, 2, true, true, '2026-01-15', '2026-04-14', 38 FROM user_ids
ON CONFLICT (id) DO UPDATE SET full_name_encrypted = EXCLUDED.full_name_encrypted;

-- Create monitoring sessions
INSERT INTO monitoring_sessions (id, patient_id, health_worker_id, started_at, ended_at, device_id)
SELECT 'aaaaaaaa-aaaa-aaaa-aaaa-ffffffffffff', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', id, NOW() - INTERVAL '1 hour', NOW(), 'test-iphone' FROM user_ids
ON CONFLICT (id) DO NOTHING;

INSERT INTO monitoring_sessions (id, patient_id, health_worker_id, started_at, ended_at, device_id)
SELECT 'bbbbbbbb-bbbb-bbbb-bbbb-ffffffffffff', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', id, NOW() - INTERVAL '2 hours', NOW() - INTERVAL '1 hour', 'test-iphone' FROM user_ids
ON CONFLICT (id) DO NOTHING;

INSERT INTO monitoring_sessions (id, patient_id, health_worker_id, started_at, ended_at, device_id)
SELECT 'cccccccc-cccc-cccc-cccc-ffffffffffff', 'cccccccc-cccc-cccc-cccc-cccccccccccc', id, NOW() - INTERVAL '30 minutes', NOW(), 'test-iphone' FROM user_ids
ON CONFLICT (id) DO NOTHING;

INSERT INTO monitoring_sessions (id, patient_id, health_worker_id, started_at, ended_at, device_id)
SELECT 'dddddddd-dddd-dddd-dddd-ffffffffffff', 'dddddddd-dddd-dddd-dddd-dddddddddddd', id, NOW() - INTERVAL '3 hours', NOW() - INTERVAL '2 hours', 'test-iphone' FROM user_ids
ON CONFLICT (id) DO NOTHING;

INSERT INTO monitoring_sessions (id, patient_id, health_worker_id, started_at, ended_at, device_id)
SELECT 'eeeeeeee-eeee-eeee-eeee-ffffffffffff', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', id, NOW() - INTERVAL '4 hours', NOW() - INTERVAL '3 hours', 'test-iphone' FROM user_ids
ON CONFLICT (id) DO NOTHING;

-- Vital readings for Sarah (low risk - normal vitals)
INSERT INTO readings (session_id, patient_id, vital_type, values_json, recorded_at, danger_level, source) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-ffffffffffff', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bp', '{"systolic": 118, "diastolic": 75, "heartRate": 72}', NOW() - INTERVAL '45 minutes', 'normal', 'manual'),
('aaaaaaaa-aaaa-aaaa-aaaa-ffffffffffff', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'spo2', '{"spo2": 98, "heartRate": 74}', NOW() - INTERVAL '40 minutes', 'normal', 'manual'),
('aaaaaaaa-aaaa-aaaa-aaaa-ffffffffffff', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'temp', '{"temperature": 36.7}', NOW() - INTERVAL '35 minutes', 'normal', 'manual'),
('aaaaaaaa-aaaa-aaaa-aaaa-ffffffffffff', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'fetal_hr', '{"heartRate": 142}', NOW() - INTERVAL '30 minutes', 'normal', 'manual');

-- Vital readings for Grace (teenage - medium risk, slightly elevated BP)
INSERT INTO readings (session_id, patient_id, vital_type, values_json, recorded_at, danger_level, source) VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-ffffffffffff', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'bp', '{"systolic": 138, "diastolic": 88, "heartRate": 82}', NOW() - INTERVAL '90 minutes', 'warning', 'manual'),
('bbbbbbbb-bbbb-bbbb-bbbb-ffffffffffff', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'spo2', '{"spo2": 97, "heartRate": 80}', NOW() - INTERVAL '85 minutes', 'normal', 'manual'),
('bbbbbbbb-bbbb-bbbb-bbbb-ffffffffffff', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'temp', '{"temperature": 36.9}', NOW() - INTERVAL '80 minutes', 'normal', 'manual'),
('bbbbbbbb-bbbb-bbbb-bbbb-ffffffffffff', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'fetal_hr', '{"heartRate": 156}', NOW() - INTERVAL '75 minutes', 'normal', 'manual');

-- Vital readings for Florence (HIGH RISK - dangerous BP, preeclampsia signs)
INSERT INTO readings (session_id, patient_id, vital_type, values_json, recorded_at, danger_level, source) VALUES
('cccccccc-cccc-cccc-cccc-ffffffffffff', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'bp', '{"systolic": 165, "diastolic": 108, "heartRate": 92}', NOW() - INTERVAL '20 minutes', 'danger', 'manual'),
('cccccccc-cccc-cccc-cccc-ffffffffffff', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'spo2', '{"spo2": 93, "heartRate": 94}', NOW() - INTERVAL '15 minutes', 'danger', 'manual'),
('cccccccc-cccc-cccc-cccc-ffffffffffff', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'temp', '{"temperature": 37.2}', NOW() - INTERVAL '10 minutes', 'normal', 'manual'),
('cccccccc-cccc-cccc-cccc-ffffffffffff', 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'fetal_hr', '{"heartRate": 108}', NOW() - INTERVAL '5 minutes', 'danger', 'manual');

-- Vital readings for Aisha (low risk - normal)
INSERT INTO readings (session_id, patient_id, vital_type, values_json, recorded_at, danger_level, source) VALUES
('dddddddd-dddd-dddd-dddd-ffffffffffff', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'bp', '{"systolic": 112, "diastolic": 72, "heartRate": 68}', NOW() - INTERVAL '150 minutes', 'normal', 'manual'),
('dddddddd-dddd-dddd-dddd-ffffffffffff', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'spo2', '{"spo2": 99, "heartRate": 70}', NOW() - INTERVAL '145 minutes', 'normal', 'manual'),
('dddddddd-dddd-dddd-dddd-ffffffffffff', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'temp', '{"temperature": 36.5}', NOW() - INTERVAL '140 minutes', 'normal', 'manual'),
('dddddddd-dddd-dddd-dddd-ffffffffffff', 'dddddddd-dddd-dddd-dddd-dddddddddddd', 'fetal_hr', '{"heartRate": 138}', NOW() - INTERVAL '135 minutes', 'normal', 'manual');

-- Vital readings for Juliet (HIV+, medium risk - slight fever)
INSERT INTO readings (session_id, patient_id, vital_type, values_json, recorded_at, danger_level, source) VALUES
('eeeeeeee-eeee-eeee-eeee-ffffffffffff', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'bp', '{"systolic": 125, "diastolic": 82, "heartRate": 78}', NOW() - INTERVAL '200 minutes', 'normal', 'manual'),
('eeeeeeee-eeee-eeee-eeee-ffffffffffff', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'spo2', '{"spo2": 96, "heartRate": 80}', NOW() - INTERVAL '195 minutes', 'normal', 'manual'),
('eeeeeeee-eeee-eeee-eeee-ffffffffffff', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'temp', '{"temperature": 37.8}', NOW() - INTERVAL '190 minutes', 'warning', 'manual'),
('eeeeeeee-eeee-eeee-eeee-ffffffffffff', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'fetal_hr', '{"heartRate": 148}', NOW() - INTERVAL '185 minutes', 'normal', 'manual');

-- Risk scores
INSERT INTO risk_scores (patient_id, risk_score, risk_tier, top_factors, input_features, model_version) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 0.12, 'low', '[{"factor": "No significant risk factors", "impact": 0}]', '{"age": 27, "gravida": 2}', 'v1.0.0'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 0.45, 'medium', '[{"factor": "Teenage pregnancy", "impact": 0.12}, {"factor": "Elevated BP", "impact": 0.10}]', '{"age": 17, "gravida": 1}', 'v1.0.0'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 0.82, 'high', '[{"factor": "Prior preeclampsia", "impact": 0.25}, {"factor": "Advanced maternal age", "impact": 0.15}, {"factor": "Grand multipara", "impact": 0.12}, {"factor": "Dangerous BP reading", "impact": 0.20}]', '{"age": 36, "gravida": 5}', 'v1.0.0'),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 0.15, 'low', '[{"factor": "No significant risk factors", "impact": 0}]', '{"age": 20, "gravida": 1}', 'v1.0.0'),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 0.48, 'medium', '[{"factor": "HIV positive", "impact": 0.15}, {"factor": "Fever detected", "impact": 0.08}]', '{"age": 30, "gravida": 3}', 'v1.0.0');

DROP TABLE user_ids;
