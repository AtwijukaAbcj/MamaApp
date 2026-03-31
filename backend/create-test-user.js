const bcrypt = require('bcryptjs');
const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'mamaapp',
  user: 'mama',
  password: 'mama_secret_password',
});

async function createTestUser() {
  const hash = await bcrypt.hash('1234', 10);
  console.log('Generated hash:', hash);
  
  await pool.query(`
    INSERT INTO users (id, phone, password_hash, full_name, role, region_id, is_active)
    VALUES (
      'b0000000-0000-0000-0000-000000000001',
      '+256700000000',
      $1,
      'Test Health Worker',
      'health_worker',
      'a0000000-0000-0000-0000-000000000001',
      true
    )
    ON CONFLICT (phone) DO UPDATE SET password_hash = $1
  `, [hash]);
  
  console.log('Test user created!');
  console.log('Phone: +256700000000');
  console.log('PIN: 1234');
  
  await pool.end();
}

createTestUser().catch(console.error);
