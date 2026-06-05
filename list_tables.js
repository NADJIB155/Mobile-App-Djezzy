require('dotenv').config();
const db = require('./Backend/src/config/db.js');

async function listTables() {
    try {
        const query = `
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
            ORDER BY table_name;
        `;
        const result = await db.query(query);
        console.log("=== TABLES DISPONIBLES DANS VOTRE BASE DE DONNÉES ===");
        result.rows.forEach(row => {
            console.log(`- ${row.table_name}`);
        });
        console.log("====================================================");
        process.exit(0);
    } catch (err) {
        console.error("Erreur lors de la récupération des tables :", err.message);
        process.exit(1);
    }
}

listTables();
