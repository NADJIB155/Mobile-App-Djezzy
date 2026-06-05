const express = require('express');
const router = express.Router();
const { ClerkExpressRequireAuth } = require('@clerk/clerk-sdk-node');
const db = require('../Backend/src/config/db.js');

// 1. VÉRIFICATION DU PROFIL (Route sécurisée)
// Seul un utilisateur connecté peut voir son propre ID Clerk
router.get('/profil', ClerkExpressRequireAuth(), (req, res) => {
    res.json({ 
        message: "Accès autorisé", 
        userId: req.auth.userId // C'est l'ID généré par Clerk (ex: user_2...)
    });
});

// 2. RÉCUPÉRATION DES INFOS (Sécurisée aussi !)
// On vérifie que l'utilisateur est authentifié avant de lui donner les infos de la base
router.get('/:id', ClerkExpressRequireAuth(), async (req, res) => {
    try {
        const { id } = req.params;
        const result = await db.query('SELECT * FROM "Users" WHERE "User_ID" = $1', [id]);
        if (result.rows.length === 0) return res.status(404).json({ error: "Utilisateur non trouvé" });
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// 3. ENREGISTREMENT D'UN NOUVEAU PROFIL (Sécurisé et Optimisé !)
router.post('/register', ClerkExpressRequireAuth(), async (req, res) => {
    try {
        // L'ID vient du token vérifié par Clerk, c'est 100% sécurisé (ex: user_2...)
        const authUserId = req.auth.userId; 
        
        // On ne récupère que les infos métiers du body
        const { nom, role, specialite, wilaya_assignee } = req.body;
        
        const result = await db.query(
            `INSERT INTO "Users" ("User_ID", "Nom", "Role", "Specialite", "Wilaya_Assignee") 
             VALUES ($1, $2, $3, $4, $5) RETURNING *`,
            [authUserId, nom, role, specialite, wilaya_assignee]
        );

        res.status(201).json({
            success: true,
            message: "Technicien enregistré avec succès !",
            user: result.rows[0]
        });
    } catch (err) {
        // Gérer l'erreur si l'utilisateur existe déjà (violation de contrainte UNIQUE)
        if (err.code === '23505') {
            return res.status(400).json({ error: "Ce profil existe déjà dans la base." });
        }
        res.status(500).json({ error: err.message });
    }
});
module.exports = router;