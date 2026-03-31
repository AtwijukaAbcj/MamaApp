// Update patient PINs properly
const bcrypt = require('bcryptjs');
const { Pool } = require('pg');

async function updatePatientPins() {
  // Create hash for PIN '1234'
  const pinHash = await bcrypt.hash('1234', 12);
  console.log('Generated hash:', pinHash);
  
  // Connect via docker network
  const pool = new Pool({
    host: 'localhost',
    port: 5432,
    database: 'mamaapp',
    user: 'mama',
    password: 'mamapass'
  });
  
  // Since we can't connect directly, output the SQL
  console.log('\nRun this in psql:');
  console.log(`UPDATE patients SET pin_hash = '${pinHash}' WHERE phone IS NOT NULL;`);
  
  await pool.end();
}

updatePatientPins().catch(console.error);
