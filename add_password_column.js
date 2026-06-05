require('dotenv').config();
const db = require('./Backend/src/config/db.js');

async function updateDatabase() {
    try {
        console.log("🛠️ Ajout de la colonne Mot_De_Passe...");
        await db.query(`ALTER TABLE "Users" ADD COLUMN IF NOT EXISTS "Mot_De_Passe" VARCHAR(255)`);
        
        console.log("🛠️ Mise à jour de TECH-01 avec un mot de passe par défaut...");
        await db.query(`UPDATE "Users" SET "Email" = 'ahmed.b@djezzy.dz', "Mot_De_Passe" = 'djezzy2026' WHERE "User_ID" = 'TECH-01'`);
        
        console.log("✅ Base de données mise à jour avec succès !");
        process.exit(0);
    } catch (e) {
        console.error("❌ Erreur :", e);
        process.exit(1);
    }
}
updateDatabase();
