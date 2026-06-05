const express = require('express');
const router = express.Router();
const { ClerkExpressRequireAuth } = require('@clerk/clerk-sdk-node'); // 🛡️ Import ajouté
const db = require('../Backend/src/config/db.js');

// SERVICE STATS DASHBOARD (PROTÉGÉ)
router.get('/stats', ClerkExpressRequireAuth(), async (req, res) => {
    try {
        const query = `
            SELECT 
                COUNT(*) FILTER (WHERE statut = 'ON AIR') as on_air,
                COUNT(*) FILTER (WHERE statut = 'DELAYED') as pannes,
                COUNT(*) FILTER (WHERE statut = 'IN PROGRESS') as in_progress
            FROM "Table_BTS"
        `;
        const result = await db.query(query);
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// SERVICE LISTE DES ANTENNES (PROTÉGÉ)
router.get('/', ClerkExpressRequireAuth(), async (req, res) => {
    try {
        const result = await db.query('SELECT * FROM "Table_BTS" LIMIT 100');
        res.status(200).json(result.rows);
    } catch (error) {
        res.status(500).json({ erreur: "Erreur serveur interne" });
    }
});

module.exports = router;