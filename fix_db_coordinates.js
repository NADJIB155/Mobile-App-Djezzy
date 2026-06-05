require('dotenv').config();
const db = require('./Backend/src/config/db.js');

async function fixCoordinates() {
    try {
        console.log("🛠️ Nettoyage des antennes tombées dans la mer...");
        
        // La Baie d'Alger fait une courbe. Tout ce qui est au-dessus de 36.75 à l'Est de 3.03 est dans l'eau.
        // On les redescend de 0.05 degrés vers le Sud (la terre ferme).
        await db.query('UPDATE "Table_BTS" SET bts_y = bts_y - 0.05 WHERE bts_y > 36.75 AND bts_x > 3.03');
        
        // Tout ce qui est très au Nord (> 36.78) est dans l'eau aussi
        await db.query('UPDATE "Table_BTS" SET bts_y = bts_y - 0.06 WHERE bts_y > 36.78');
        
        console.log(" SUCCÈS ! Toutes les antennes ont été ramenées sur la terre ferme !");
        process.exit(0);
    } catch (e) {
        console.error(" Erreur :", e);
        process.exit(1);
    }
}

fixCoordinates();
