// Fichier : routes/commercial.js
const express = require('express');
const router = express.Router();
const db = require('../Backend/src/config/db.js'); // Vérifie que ce chemin correspond bien à ta structure
const verifierRole = require('../middlewares/role'); // On importe notre vigile

// 💰 1. INSERTION : SALES
router.post('/sales', verifierRole(['Commercial', 'Admin']), async (req, res) => {
    try {
        const { Date_Activation, Date_Vente, Line_Type, MSISDN, PDV_Subno, Sales_Type } = req.body;
        const query = `INSERT INTO "3-Sales_Table_PFE_V2" ("Date_Activation", "Date_Vente", "Line_Type", "MSISDN", "PDV_Subno", "Sales_Type") VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`;
        const result = await db.query(query, [Date_Activation, Date_Vente, Line_Type, MSISDN, PDV_Subno, Sales_Type]);
        res.status(201).json({ success: true, data: result.rows[0] });
    } catch (err) { res.status(500).json({ success: false, error: err.message }); }
});

// 🏪 2. INSERTION : POS
router.post('/pos', verifierRole(['Commercial', 'Admin']), async (req, res) => {
    try {
        const { Auxiliary_SIM_No, Auxiliary_SIM_Status, bts_x, bts_y, Cle_Geo, Code_PDV, Commune, Etat_PDV, POS_Org_Type, Region, SIM_Parnter_Status, Wilaya_Propre } = req.body;
        const query = `INSERT INTO "1-POS_Table_Rempli_Final" ("Auxiliary_SIM_No", "Auxiliary_SIM_Status", "BTS X", "BTS Y", "Cle_Geo", "Code_PDV", "Commune", "Etat_PDV", "POS_Org_Type", "Region", "SIM_Parnter_Status", "Wilaya_Propre") VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING *`;
        const result = await db.query(query, [Auxiliary_SIM_No, Auxiliary_SIM_Status, bts_x, bts_y, Cle_Geo, Code_PDV, Commune, Etat_PDV, POS_Org_Type, Region, SIM_Parnter_Status, Wilaya_Propre]);
        res.status(201).json({ success: true, data: result.rows[0] });
    } catch (err) { res.status(500).json({ success: false, error: err.message }); }
});

// 💳 3. INSERTION : REFILL
router.post('/refill', verifierRole(['Commercial', 'Admin']), async (req, res) => {
    try {
        const { CITY, Code_PDV, MSISDN, MSISDN_SRC, PRVC, Refill_AMNT, Refill_Date, RFL_ACNT, RFL_CHNL, RFL_PRP, RFL_SRC, RFL_TYPE } = req.body;
        const query = `INSERT INTO "2-Reffil_Table_PFE_V2" ("CITY", "Code_PDV", "MSISDN", "MSISDN_SRC", "PRVC", "Refill_AMNT", "Refill_Date", "RFL_ACNT", "RFL_CHNL", "RFL_PRP", "RFL_SRC", "RFL_TYPE") VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING *`;
        const result = await db.query(query, [CITY, Code_PDV, MSISDN, MSISDN_SRC, PRVC, Refill_AMNT, Refill_Date, RFL_ACNT, RFL_CHNL, RFL_PRP, RFL_SRC, RFL_TYPE]);
        res.status(201).json({ success: true, data: result.rows[0] });
    } catch (err) { res.status(500).json({ success: false, error: err.message }); }
});

// Tu peux ajouter /activations, /packages, /customers ici sur le même modèle...

module.exports = router; // Très important !