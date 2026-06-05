require('dotenv').config();
const db = require('./Backend/src/config/db.js');

async function checkUsers() {
    try {
        const result = await db.query('SELECT column_name, data_type FROM information_schema.columns WHERE table_name = \'Users\'');
        console.log("Colonnes de la table Users :");
        console.table(result.rows);
        process.exit(0);
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}
checkUsers();
