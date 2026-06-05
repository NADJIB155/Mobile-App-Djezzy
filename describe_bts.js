require('dotenv').config();
const db = require('./Backend/src/config/db.js');

async function describeBTS() {
    try {
        const query = `
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_name = 'Table_BTS'
            ORDER BY ordinal_position;
        `;
        const result = await db.query(query);
        console.log("=== COLONNES DE LA TABLE Table_BTS ===");
        result.rows.forEach(row => {
            console.log(`- ${row.column_name} (${row.data_type}, Nullable: ${row.is_nullable})`);
        });
        console.log("======================================");
        process.exit(0);
    } catch (err) {
        console.error("Erreur lors de la description de la table :", err.message);
        process.exit(1);
    }
}

describeBTS();
