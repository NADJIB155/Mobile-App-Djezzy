const express = require('express');
const router = express.Router();
const { ClerkExpressRequireAuth } = require('@clerk/clerk-sdk-node'); // 🛡️ Import indispensable
const db = require('../Backend/src/config/db.js');

// ==========================================
// 1. LECTURE : Récupérer les tâches (PROTÉGÉ)
// ==========================================
router.get('/:userId', ClerkExpressRequireAuth(), async (req, res) => {
    try {
        const { userId } = req.params;
        const query = `
            SELECT t.*, b.bts_x, b.bts_y, b.statut 
            FROM "Tasks" t
            JOIN "Table_BTS" b ON t.bts_id = b.bts_id
            WHERE t."User_ID" = $1
        `;
        const result = await db.query(query, [userId]);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ==========================================
// 2. MISE À JOUR : Clôturer une tâche (PROTÉGÉ)
// ==========================================
router.put('/close', ClerkExpressRequireAuth(), async (req, res) => {
    try {
        const { task_id, bts_id } = req.body;
        
        await db.query('UPDATE "Tasks" SET "Statut_Task" = $1 WHERE "Task_ID" = $2', ['COMPLETED', task_id]);
        await db.query('UPDATE "Table_BTS" SET statut = $1 WHERE bts_id = $2', ['ON AIR', bts_id]);
        
        res.json({ success: true, message: "Intervention terminée avec succès !" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ==========================================
// 3. CRÉATION : Assigner manuellement (PROTÉGÉ)
// ==========================================
router.post('/assign', ClerkExpressRequireAuth(), async (req, res) => {
    try {
        const { bts_id, user_id, titre, description, priorite } = req.body;
        const result = await db.query(
            `INSERT INTO "Tasks" ("bts_id", "User_ID", "Titre", "Description", "Priorite", "Statut_Task")
             VALUES ($1, $2, $3, $4, $5, 'ASSIGNED') RETURNING *`,
            [bts_id, user_id, titre, description, priorite]
        );
        res.status(201).json({ success: true, task: result.rows[0] });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


// ==========================================
//  4. L'ALGORITHME : AUTO-ASSIGNATION (PROTÉGÉ)
// ==========================================
router.post('/auto-assign', ClerkExpressRequireAuth(), async (req, res) => {
    try {
        // ÉTAPE 1 : Chercher 1 antenne en panne
        const btsResult = await db.query(`
            SELECT bts_id FROM "Table_BTS" 
            WHERE statut = 'DELAYED' 
            AND bts_id NOT IN (
                SELECT bts_id FROM "Tasks" WHERE "Statut_Task" IN ('ASSIGNED', 'IN PROGRESS')
            )
            LIMIT 1
        `);
        
        if (btsResult.rows.length === 0) {
            return res.json({ success: false, message: "Aucune nouvelle panne à assigner." });
        }
        const bts_id_panne = btsResult.rows[0].bts_id;

        // ÉTAPE 2 : Load Balancing
        const techResult = await db.query(`
            SELECT "User_ID" FROM "Users" 
            WHERE "Role" = 'TECHNICIAN'
            ORDER BY (
                SELECT COUNT(*) FROM "Tasks" 
                WHERE "User_ID" = "Users"."User_ID" AND "Statut_Task" IN ('ASSIGNED', 'IN PROGRESS')
            ) ASC
            LIMIT 1
        `);
        
        if (techResult.rows.length === 0) {
            return res.json({ success: false, message: "Aucun technicien trouvé." });
        }
        const tech_libre = techResult.rows[0].User_ID;

        // ÉTAPE 3 : Création de la mission
        const insertResult = await db.query(`
            INSERT INTO "Tasks" ("bts_id", "User_ID", "Titre", "Description", "Priorite", "Statut_Task")
            VALUES ($1, $2, 'Intervention IA: Panne Réseau', 'Assignation automatique par équilibrage de charge', 'URGENT', 'ASSIGNED')
            RETURNING *
        `, [bts_id_panne, tech_libre]);

        res.json({ 
            success: true, 
            message: "L'algorithme a fonctionné !", 
            task: insertResult.rows[0] 
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;