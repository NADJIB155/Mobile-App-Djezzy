require('dotenv').config();
const db = require('./Backend/src/config/db.js');

async function createTables() {
    try {
        console.log("Connexion à la base de données...");

        // 1. Table Sales
        console.log("Création de la table '3-Sales_Table_PFE_V2'...");
        await db.query(`
            CREATE TABLE IF NOT EXISTS "3-Sales_Table_PFE_V2" (
                id SERIAL PRIMARY KEY,
                "Date_Activation" DATE,
                "Date_Vente" DATE,
                "Line_Type" VARCHAR(100),
                "MSISDN" VARCHAR(50),
                "PDV_Subno" VARCHAR(100),
                "Sales_Type" VARCHAR(100)
            );
        `);

        // 2. Table POS
        console.log("Création de la table '1-POS_Table_Rempli_Final'...");
        await db.query(`
            CREATE TABLE IF NOT EXISTS "1-POS_Table_Rempli_Final" (
                id SERIAL PRIMARY KEY,
                "Auxiliary_SIM_No" VARCHAR(100),
                "Auxiliary_SIM_Status" VARCHAR(100),
                "BTS X" NUMERIC,
                "BTS Y" NUMERIC,
                "Cle_Geo" VARCHAR(100),
                "Code_PDV" VARCHAR(100),
                "Commune" VARCHAR(150),
                "Etat_PDV" VARCHAR(100),
                "POS_Org_Type" VARCHAR(150),
                "Region" VARCHAR(100),
                "SIM_Parnter_Status" VARCHAR(100),
                "Wilaya_Propre" VARCHAR(100)
            );
        `);

        // 3. Table Refill
        console.log("Création de la table '2-Reffil_Table_PFE_V2'...");
        await db.query(`
            CREATE TABLE IF NOT EXISTS "2-Reffil_Table_PFE_V2" (
                id SERIAL PRIMARY KEY,
                "CITY" VARCHAR(100),
                "Code_PDV" VARCHAR(100),
                "MSISDN" VARCHAR(50),
                "MSISDN_SRC" VARCHAR(50),
                "PRVC" VARCHAR(100),
                "Refill_AMNT" NUMERIC,
                "Refill_Date" TIMESTAMP,
                "RFL_ACNT" VARCHAR(100),
                "RFL_CHNL" VARCHAR(100),
                "RFL_PRP" VARCHAR(100),
                "RFL_SRC" VARCHAR(100),
                "RFL_TYPE" VARCHAR(100)
            );
        `);

        console.log("🟢 Toutes les tables manquantes ont été créées avec succès !");
        process.exit(0);
    } catch (err) {
        console.error("❌ Erreur lors de la création des tables :", err.message);
        process.exit(1);
    }
}

createTables();
