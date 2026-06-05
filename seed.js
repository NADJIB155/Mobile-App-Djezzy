require('dotenv').config();
const db = require('./Backend/src/config/db.js');

const antennas = [
    { bts_id: 'DZ-ALG-001', bts_x: 36.7525, bts_y: 3.0419, type_antenne: '4G LTE', statut: 'ON AIR' },
    { bts_id: 'DZ-ALG-002', bts_x: 36.7325, bts_y: 3.0619, type_antenne: '5G', statut: 'DELAYED' },
    { bts_id: 'DZ-ALG-003', bts_x: 36.7625, bts_y: 3.0219, type_antenne: 'Fibre', statut: 'IN PROGRESS' }
];

async function seedData() {
    try {
        console.log("Sécurité activée : L'injection et la suppression ont été désactivées pour protéger tes vraies données (DJEZ_...) !");
        console.log("Ferme ce script.");
        process.exit(0);
        for (const antenna of antennas) {
            await db.query(
                `INSERT INTO "Table_BTS" (bts_id, bts_x, bts_y, type_antenne, statut) 
                 VALUES ($1, $2, $3, $4, $5) ON CONFLICT (bts_id) DO NOTHING`,
                [antenna.bts_id, antenna.bts_x, antenna.bts_y, antenna.type_antenne, antenna.statut]
            );
        }
        console.log("3 Antennes injectées avec succès dans la base de données Neon !");
        process.exit(0);
    } catch (err) {
        console.error(" Erreur lors de l'injection :", err.message);
        process.exit(1);
    }
}

seedData();
