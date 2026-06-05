const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('[DATABASE] ❌ Erreur de connexion à Neon :', err.message);
  } else {
    console.log('[DATABASE] 🌐 Connecté avec succès à PostgreSQL (Neon.tech) !');
  }
});

module.exports = pool;