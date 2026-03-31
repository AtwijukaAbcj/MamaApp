// Seed test data for MamaApp
const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'mamaapp',
  user: 'mama',
  password: 'mamapass'
});

async function seed() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    // 1. Create region
    const regionResult = await client.query(`
      INSERT INTO regions (id, name, country_code)
      VALUES ('11111111-1111-1111-1111-111111111111', 'Central Region', 'UG')
      ON CONFLICT (id) DO NOTHING
      RETURNING id;
    `);
    const regionId = '11111111-1111-1111-1111-111111111111';
    console.log('✓ Region created');
    
    // 2. Create facility
    await client.query(`
      INSERT INTO facilities (id, name, facility_type, region_id, address, phone, latitude, longitude)
      VALUES (
        '22222222-2222-2222-2222-222222222222',
        'Mulago National Referral Hospital',
        'hospital',
        $1,
        'Mulago Hill, Kampala',
        '+256414541884',
        0.3476,
        32.5825
      )
      ON CONFLICT (id) DO NOTHING;
    `, [regionId]);
    console.log('✓ Facility created');
    
    const facilityId = '22222222-2222-2222-2222-222222222222';
    
    // 3. Update test user with facility
    await client.query(`
      UPDATE users SET facility_id = $1, region_id = $2
      WHERE phone = '+256700000000';
    `, [facilityId, regionId]);
    console.log('✓ Updated test user');
    
    // Get user ID
    const userResult = await client.query(`
      SELECT id FROM users WHERE phone = '+256700000000';
    `);
    const userId = userResult.rows[0]?.id;
    
    // 4. Create test patients
    const patients = [
      {
        id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        name: 'Sarah Nakamya',
        dob: '1998-05-15',
        age: 27,
        gravida: 2,
        parity: 1,
        weeks: 32,
        edd: '2026-05-20',
        riskLevel: 'low'
      },
      {
        id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        name: 'Grace Achieng',
        dob: '2008-09-22',
        age: 17,
        gravida: 1,
        parity: 0,
        weeks: 28,
        edd: '2026-06-15',
        riskLevel: 'medium' // teenage pregnancy
      },
      {
        id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        name: 'Florence Namukasa',
        dob: '1990-01-10',
        age: 36,
        gravida: 5,
        parity: 4,
        weeks: 36,
        edd: '2026-04-28',
        riskLevel: 'high', // advanced maternal age, multiparous
        priorPreeclampsia: true
      },
      {
        id: 'dddddddd-dddd-dddd-dddd-dddddddddddd',
        name: 'Aisha Nambi',
        dob: '2006-03-08',
        age: 20,
        gravida: 1,
        parity: 0,
        weeks: 24,
        edd: '2026-07-10',
        riskLevel: 'low'
      },
      {
        id: 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
        name: 'Juliet Kyambadde',
        dob: '1995-11-30',
        age: 30,
        gravida: 3,
        parity: 2,
        weeks: 38,
        edd: '2026-04-14',
        riskLevel: 'medium',
        hiv: true
      }
    ];
    
    for (const p of patients) {
      // Simple encryption (in production, use proper AES)
      const encryptedName = Buffer.from(p.name, 'utf8');
      
      await client.query(`
        INSERT INTO patients (
          id, full_name_encrypted, date_of_birth, age_at_registration,
          region_id, nearest_facility_id, assigned_health_worker_id,
          gravida, parity, prior_preeclampsia, hiv_positive,
          is_pregnant, pregnancy_registered_at, expected_delivery_date,
          gestational_weeks_at_registration
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
        ON CONFLICT (id) DO UPDATE SET
          full_name_encrypted = $2,
          expected_delivery_date = $14;
      `, [
        p.id,
        encryptedName,
        p.dob,
        p.age,
        regionId,
        facilityId,
        userId,
        p.gravida,
        p.parity,
        p.priorPreeclampsia || false,
        p.hiv || false,
        true, // is_pregnant
        '2026-01-15',
        p.edd,
        p.weeks
      ]);
    }
    console.log('✓ 5 patients created');
    
    // 5. Create monitoring sessions and readings
    const now = new Date();
    
    for (const p of patients) {
      // Create session
      const sessionId = p.id.replace(/a/g, 'f').replace(/b/g, 'f').replace(/c/g, 'f').replace(/d/g, 'f').replace(/e/g, 'f');
      
      await client.query(`
        INSERT INTO monitoring_sessions (id, patient_id, health_worker_id, started_at, ended_at, device_id)
        VALUES ($1, $2, $3, $4, $5, 'test-iphone-13')
        ON CONFLICT (id) DO NOTHING;
      `, [sessionId, p.id, userId, new Date(now - 3600000), now]);
      
      // Add vital readings
      const vitals = generateVitals(p.riskLevel);
      
      for (const v of vitals) {
        await client.query(`
          INSERT INTO readings (session_id, patient_id, vital_type, values_json, recorded_at, danger_level, source)
          VALUES ($1, $2, $3, $4, $5, $6, 'manual')
          ON CONFLICT DO NOTHING;
        `, [sessionId, p.id, v.type, JSON.stringify(v.values), new Date(now - Math.random() * 3600000), v.danger]);
      }
    }
    console.log('✓ Monitoring sessions and readings created');
    
    // 6. Add risk scores
    for (const p of patients) {
      const score = p.riskLevel === 'high' ? 0.78 : p.riskLevel === 'medium' ? 0.45 : 0.15;
      
      await client.query(`
        INSERT INTO risk_scores (patient_id, risk_score, risk_tier, top_factors, input_features, model_version)
        VALUES ($1, $2, $3, $4, $5, 'v1.0.0')
        ON CONFLICT DO NOTHING;
      `, [
        p.id,
        score,
        p.riskLevel,
        JSON.stringify(getTopFactors(p)),
        JSON.stringify({ age: p.age, gravida: p.gravida, parity: p.parity }),
      ]);
    }
    console.log('✓ Risk scores created');
    
    await client.query('COMMIT');
    console.log('\n✅ Test data seeded successfully!');
    console.log('\nTest patients:');
    patients.forEach(p => {
      console.log(`  - ${p.name} (${p.age}yo, ${p.weeks} weeks, ${p.riskLevel} risk)`);
    });
    
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error seeding data:', err);
  } finally {
    client.release();
    await pool.end();
  }
}

function generateVitals(riskLevel) {
  const vitals = [];
  
  // Blood pressure
  let systolic, diastolic, bpDanger;
  if (riskLevel === 'high') {
    systolic = 155 + Math.floor(Math.random() * 20);
    diastolic = 100 + Math.floor(Math.random() * 10);
    bpDanger = 'danger';
  } else if (riskLevel === 'medium') {
    systolic = 135 + Math.floor(Math.random() * 15);
    diastolic = 85 + Math.floor(Math.random() * 10);
    bpDanger = 'warning';
  } else {
    systolic = 110 + Math.floor(Math.random() * 20);
    diastolic = 70 + Math.floor(Math.random() * 10);
    bpDanger = 'normal';
  }
  vitals.push({
    type: 'bp',
    values: { systolic, diastolic, heartRate: 70 + Math.floor(Math.random() * 20) },
    danger: bpDanger
  });
  
  // SpO2
  let spo2, spo2Danger;
  if (riskLevel === 'high') {
    spo2 = 90 + Math.floor(Math.random() * 4);
    spo2Danger = 'danger';
  } else {
    spo2 = 96 + Math.floor(Math.random() * 4);
    spo2Danger = 'normal';
  }
  vitals.push({
    type: 'spo2',
    values: { spo2, heartRate: 72 + Math.floor(Math.random() * 15) },
    danger: spo2Danger
  });
  
  // Temperature
  const temp = 36.5 + Math.random() * 1.0;
  vitals.push({
    type: 'temp',
    values: { temperature: Math.round(temp * 10) / 10 },
    danger: temp > 37.5 ? 'warning' : 'normal'
  });
  
  // Fetal heart rate
  let fhr, fhrDanger;
  if (riskLevel === 'high') {
    fhr = Math.random() > 0.5 ? 100 + Math.floor(Math.random() * 10) : 170 + Math.floor(Math.random() * 10);
    fhrDanger = 'danger';
  } else {
    fhr = 120 + Math.floor(Math.random() * 40);
    fhrDanger = 'normal';
  }
  vitals.push({
    type: 'fetal_hr',
    values: { heartRate: fhr },
    danger: fhrDanger
  });
  
  return vitals;
}

function getTopFactors(patient) {
  const factors = [];
  if (patient.age >= 35) factors.push({ factor: 'Advanced maternal age', impact: 0.15 });
  if (patient.age < 18) factors.push({ factor: 'Teenage pregnancy', impact: 0.12 });
  if (patient.priorPreeclampsia) factors.push({ factor: 'Prior preeclampsia', impact: 0.25 });
  if (patient.hiv) factors.push({ factor: 'HIV positive', impact: 0.10 });
  if (patient.gravida >= 4) factors.push({ factor: 'Grand multipara', impact: 0.08 });
  if (factors.length === 0) factors.push({ factor: 'No significant risk factors', impact: 0 });
  return factors;
}

seed();
