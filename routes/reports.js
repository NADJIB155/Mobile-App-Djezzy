const express = require('express');
const router = express.Router();
const { ClerkExpressRequireAuth } = require('@clerk/clerk-sdk-node'); // 🛡️ Import ajouté
const db = require('../Backend/src/config/db.js');

// SERVICE FORMULAIRE (PROTÉGÉ)
router.post('/submit', ClerkExpressRequireAuth(), async (req, res) => {
    try {
        const { task_id, user_id, type_rapport, donnees_json } = req.body;
        const result = await db.query(
            'INSERT INTO "Reports" ("Task_ID", "User_ID", "Type_Rapport", "Donnees_JSON") VALUES ($1, $2, $3, $4) RETURNING *',
            [task_id, user_id, type_rapport, JSON.stringify(donnees_json)]
        );
        res.status(201).json({ success: true, report: result.rows[0] });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;