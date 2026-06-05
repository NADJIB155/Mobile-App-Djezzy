// Importation des modules
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { ClerkExpressRequireAuth } = require('@clerk/clerk-sdk-node');

// Initialisation de l'application
const app = express();
const PORT = process.env.PORT || 3000;
const db = require('./Backend/src/config/db.js');
const commercialRoutes = require('./routes/commercial');
// ==========================================
//  MIDDLEWARES DE SÉCURITÉ (L'ordre est important !)
// ==========================================

// 1. Helmet : Cache les infos du serveur et sécurise les requêtes HTTP
app.use(helmet({
    crossOriginResourcePolicy: false, // Indispensable pour que Flutter Web puisse lire les requêtes
}));

// 2. CORS : Autorise ton application Flutter à communiquer avec cette API
app.use(cors());

// 3. Parser JSON : Permet de lire les données envoyées par Flutter
app.use(express.json());

// 4. Rate Limiter : Bloque le spam et les attaques DDoS
const apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limite chaque IP à 100 requêtes par fenêtre
    message: "Trop de requêtes depuis cette IP, veuillez réessayer plus tard."
});
app.use('/api/', apiLimiter);


// ==========================================
//  ROUTES DE TEST
// ==========================================
app.use('/api', commercialRoutes);
// Route publique (Pas besoin d'être connecté)
app.get('/', (req, res) => {
    res.json({ message: "Serveur Backend Djezzy Opérationnel " });
});

// Route PROTÉGÉE par Clerk (Uniquement pour les techniciens authentifiés)
// Le middleware ClerkExpressRequireAuth() bloque ceux qui n'ont pas de token valide
app.get('/api/technicien/profil', ClerkExpressRequireAuth(), (req, res) => {
    // Si on arrive ici, c'est que Clerk a validé l'utilisateur !
    res.json({ 
        message: "Accès autorisé", 
        userId: req.auth.userId // C'est l'ID unique généré par Clerk
    });
});



// ==========================================
//  ROUTES MÉTIER (API DJEZZY)
// ==========================================

// ==========================================
//  SERVICE PROFIL & SIDEBAR
// ==========================================
app.get('/api/user/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await db.query('SELECT * FROM "Users" WHERE "User_ID" = $1', [id]);
        if (result.rows.length === 0) return res.status(404).json({ error: "Utilisateur non trouvé" });
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ==========================================
//  SERVICE TÂCHES (ASSIGNED INTERVENTIONS)
// ==========================================
app.get('/api/tasks/:userId', async (req, res) => {
    try {
        const { userId } = req.params;
        // Jointure pour avoir les infos de la BTS en même temps que la tâche
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
//  SERVICE STATS (POUR LE DASHBOARD)
// ==========================================
app.get('/api/stats', async (req, res) => {
    try {
        const query = `
            SELECT 
                COUNT(*) FILTER (WHERE statut = 'ON AIR') as on_air,
                COUNT(*) FILTER (WHERE statut = 'DELAYED') as pannes,
                COUNT(*) FILTER (WHERE statut = 'IN PROGRESS') as in_progress,
                COUNT(*) as total,
                COUNT(*) FILTER (WHERE type_antenne = 'Macro') as macro
            FROM "Table_BTS"
        `;
        const result = await db.query(query);
        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// ==========================================
//  LOGIQUE MÉTIER : CLÔTURE D'INTERVENTION
// ==========================================
app.put('/api/tasks/close', async (req, res) => {
    const { task_id, bts_id } = req.body;

    if (!task_id || !bts_id) {
        return res.status(400).json({ error: "task_id et bts_id sont requis." });
    }

    try {
        // 1. Clôturer la tâche (Passe le statut à COMPLETED)
        await db.query('UPDATE "Tasks" SET "Statut_Task" = $1 WHERE "Task_ID" = $2', ['COMPLETED', task_id]);
        
        // 2. Mettre l'antenne associée en ON AIR
        await db.query('UPDATE "Table_BTS" SET statut = $1 WHERE bts_id = $2', ['ON AIR', bts_id]);
        
        res.json({ success: true, message: "Intervention clôturée avec succès, antenne de retour ON AIR." });
    } catch (e) {
        console.error('[ERREUR] Clôture :', e);
        res.status(500).json({ error: "Erreur lors de la clôture", details: e.message });
    }
});

// ==========================================
//  L'ALGORITHME : AUTO-ASSIGNATION (IA) & LOAD BALANCING
// ==========================================
app.post('/api/tasks/auto-assign', async (req, res) => {
    try {
        console.log('\n======================================');
        console.log('  Démarrage de l\'algorithme d\'équilibrage de charge...');
        
        // ÉTAPE 1 : Chercher 1 antenne en panne (DELAYED) non assignée
        const btsResult = await db.query(`
            SELECT bts_id, type_antenne FROM "Table_BTS" 
            WHERE statut = 'DELAYED' 
            AND bts_id NOT IN (
                SELECT bts_id FROM "Tasks" WHERE "Statut_Task" IN ('ASSIGNED', 'IN PROGRESS')
            )
            LIMIT 1
        `);
        
        if (btsResult.rows.length === 0) {
            console.log('  Aucune panne critique en attente dans le réseau.');
            return res.json({ success: false, message: "Aucune nouvelle panne à assigner." });
        }
        const bts_id_panne = btsResult.rows[0].bts_id;
        const type_panne = btsResult.rows[0].type_antenne;
        console.log(`  Panne identifiée sur l'antenne : ${bts_id_panne} (Type: ${type_panne})`);

        // ÉTAPE 2 : Load Balancing (Récupérer la charge de travail de TOUS les techniciens)
        console.log('  Analyse de la charge de travail des techniciens (Load Balancing)...');
        const techResult = await db.query(`
            SELECT "User_ID", "Nom_Complet", (
                SELECT COUNT(*) FROM "Tasks" 
                WHERE "User_ID" = "Users"."User_ID" AND "Statut_Task" IN ('ASSIGNED', 'IN PROGRESS')
            ) as charge_actuelle
            FROM "Users" 
            WHERE "Role" = 'TECHNICIAN'
            ORDER BY charge_actuelle ASC
        `);
        
        if (techResult.rows.length === 0) {
            console.log('[ IA AFFECTATION]  Aucun technicien disponible dans la base.');
            return res.json({ success: false, message: "Aucun technicien disponible trouvé." });
        }

        // Affichage du tableau de bord de la charge dans la console Node.js
        console.table(techResult.rows.map(t => ({ Technicien: t.Nom_Complet, ID: t.User_ID, Tâches_En_Cours: t.charge_actuelle })));

        // Sélectionner le meilleur candidat (celui en haut de la liste triée)
        const bestCandidate = techResult.rows[0];
        console.log(`[ IA AFFECTATION]  Choix optimal : ${bestCandidate.Nom_Complet} (ID: ${bestCandidate.User_ID}) avec seulement ${bestCandidate.charge_actuelle} tâche(s).`);

        // ÉTAPE 3 : Création de la mission
        const titreDynamique = `Panne Réseau – BTS ${bts_id_panne} (CRITIQUE)`;
        const insertResult = await db.query(`
            INSERT INTO "Tasks" ("bts_id", "User_ID", "Titre", "Description", "Priorite", "Statut_Task")
            VALUES ($1, $2, $3, 'Assignation IA : Optimisation de la charge de travail', 'URGENT', 'ASSIGNED')
            RETURNING *
        `, [bts_id_panne, bestCandidate.User_ID, titreDynamique]);

        console.log(`[ IA AFFECTATION]  Mission "${titreDynamique}" officiellement assignée !`);
        console.log('======================================\n');

        res.json({ 
            success: true, 
            message: `Panne assignée par l'IA à ${bestCandidate.Nom_Complet} (Charge la plus faible).`, 
            task: insertResult.rows[0] 
        });

    } catch (err) {
        console.error('[ IA AFFECTATION ERREUR]', err.message);
        res.status(500).json({ error: err.message });
    }
});

// ==========================================
//  SERVICE AUTHENTIFICATION (REGISTER & LOGIN)
// ==========================================

// 1. Inscription (Register)
app.post('/api/register', async (req, res) => {
    const { nom_complet, email, password, role } = req.body;
    
    if (!nom_complet || !email || !password || !role) {
        return res.status(400).json({ success: false, error: "Tous les champs sont requis." });
    }

    try {
        // Vérifier si l'email existe déjà
        const checkEmail = await db.query('SELECT * FROM "Users" WHERE "Email" = $1', [email]);
        if (checkEmail.rows.length > 0) {
            return res.status(400).json({ success: false, error: "Cet email est déjà utilisé." });
        }

        // Générer un User_ID unique
        const userId = 'USR-' + Math.floor(Math.random() * 10000);

        // Insérer le nouvel utilisateur
        const query = `
            INSERT INTO "Users" ("User_ID", "Nom_Complet", "Email", "Mot_De_Passe", "Role", "Date_Inscription")
            VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *
        `;
        const result = await db.query(query, [userId, nom_complet, email, password, role]);
        const newUser = result.rows[0];

        res.json({ 
            success: true, 
            message: "Inscription réussie !",
            user: { id: newUser.User_ID, nom: newUser.Nom_Complet, role: newUser.Role } 
        });
    } catch (e) {
        res.status(500).json({ success: false, error: "Erreur serveur", details: e.message });
    }
});

// 2. Connexion (Login)
app.post('/api/login', async (req, res) => {
    const { email, password } = req.body;
    
    if (!email || !password) {
        return res.status(400).json({ success: false, error: "L'email et le mot de passe sont requis." });
    }

    try {
        const result = await db.query('SELECT * FROM "Users" WHERE "Email" = $1 AND "Mot_De_Passe" = $2', [email, password]);
        
        if (result.rows.length === 0) {
            return res.status(401).json({ success: false, error: "Identifiants incorrects." });
        }

        const user = result.rows[0];
        res.json({ 
            success: true, 
            token: "jwt-token-" + user.User_ID, 
            user: { 
                id: user.User_ID, 
                nom: user.Nom_Complet, 
                role: user.Role,
                email: user.Email,
                telephone: user.Telephone || '',
                wilaya: user.Wilaya_Assignee || '',
                specialite: user.Specialite || 'Général',
                photoUrl: user.Photo_URL || ''
            } 
        });

    } catch (e) {
        res.status(500).json({ success: false, error: "Erreur serveur", details: e.message });
    }
});

// 3. Mise à jour du Profil
app.put('/api/users/update', async (req, res) => {
    const { user_id, telephone, wilaya, nom_complet } = req.body;

    if (!user_id) return res.status(400).json({ success: false, error: "L'ID utilisateur est requis." });

    try {
        const query = `
            UPDATE "Users" 
            SET "Telephone" = $1, "Wilaya_Assignee" = $2, "Nom_Complet" = $3
            WHERE "User_ID" = $4
            RETURNING *
        `;
        const result = await db.query(query, [telephone, wilaya, nom_complet, user_id]);
        
        if (result.rows.length === 0) return res.status(404).json({ success: false, error: "Utilisateur non trouvé" });

        const user = result.rows[0];
        res.json({ 
            success: true, 
            user: {
                id: user.User_ID, 
                nom: user.Nom_Complet, 
                role: user.Role,
                email: user.Email,
                telephone: user.Telephone,
                wilaya: user.Wilaya_Assignee,
                specialite: user.Specialite,
                photoUrl: user.Photo_URL
            } 
        });
    } catch (e) {
        res.status(500).json({ success: false, error: "Erreur serveur", details: e.message });
    }
});

// Route GET : Récupérer les antennes pour l'application mobile
app.get('/api/bts', async (req, res) => {
    try {
        // On demande à la base Neon de nous envoyer les antennes
        // Attention : on met "Table_BTS" entre guillemets pour respecter la majuscule !
        const result = await db.query('SELECT * FROM "Table_BTS" LIMIT 100');
        
        // On envoie le résultat formaté en JSON (prêt pour Flutter)
        res.status(200).json(result.rows);
    } catch (error) {
        console.error('[ERREUR API] Impossible de récupérer les BTS :', error.message);
        res.status(500).json({ erreur: "Erreur serveur interne" });
    }
});

// Route POST : Insérer une nouvelle antenne BTS (utile pour ton PFE)
app.post('/api/bts', async (req, res) => {
    try {
        const { bts_id, bts_x, bts_y, type_antenne, statut } = req.body;

        // Validation des champs requis
        if (!bts_id || bts_x === undefined || bts_y === undefined || !type_antenne || !statut) {
            return res.status(400).json({ 
                success: false, 
                erreur: "Tous les champs (bts_id, bts_x, bts_y, type_antenne, statut) sont requis." 
            });
        }

        const query = `
            INSERT INTO "Table_BTS" (bts_id, bts_x, bts_y, type_antenne, statut) 
            VALUES ($1, $2, $3, $4, $5) 
            RETURNING *
        `;
        const result = await db.query(query, [bts_id, bts_x, bts_y, type_antenne, statut]);
        
        res.status(201).json({ 
            success: true, 
            message: "Antenne BTS insérée avec succès !", 
            data: result.rows[0] 
        });
    } catch (error) {
        console.error('[ERREUR API] Impossible d\'insérer la BTS :', error.message);
        
        // Gérer le cas où le bts_id existe déjà (Violation de contrainte unique)
        if (error.code === '23505') {
            return res.status(400).json({ 
                success: false, 
                erreur: `L'antenne avec le bts_id '${req.body.bts_id}' existe déjà.` 
            });
        }
        res.status(500).json({ success: false, erreur: "Erreur serveur interne" });
    }
});


// Route PUT : Déclarer une panne sur une antenne (Report Failure)
app.put('/api/bts/report-failure', async (req, res) => {
    try {
        const { bts_id, severity, description } = req.body;

        if (!bts_id) {
            return res.status(400).json({ success: false, erreur: "L'identifiant de la BTS est requis." });
        }

        // Mettre à jour le statut de l'antenne en 'DELAYED' (en panne)
        const query = `
            UPDATE "Table_BTS" 
            SET statut = 'DELAYED' 
            WHERE bts_id = $1 
            RETURNING *
        `;
        const result = await db.query(query, [bts_id]);
        
        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, erreur: "Antenne non trouvée dans la base." });
        }

        console.log(`[ ALARME NOC] Nouvelle panne signalée sur la BTS ${bts_id} (Sévérité: ${severity || 'Non précisée'})`);

        res.status(200).json({ 
            success: true, 
            message: "Panne déclarée avec succès, la BTS est maintenant en statut DELAYED.", 
            data: result.rows[0] 
        });
    } catch (error) {
        console.error('[ERREUR API] Impossible de déclarer la panne :', error.message);
        res.status(500).json({ success: false, erreur: "Erreur serveur interne" });
    }
});


// ==========================================
//  DÉMARRAGE DU SERVEUR
// ==========================================
app.listen(PORT, () => {
    console.log(`[SERVEUR] Démarré avec succès sur le port ${PORT}`);
    console.log(`[SÉCURITÉ] Helmet, CORS et Rate Limit activés.`);
});