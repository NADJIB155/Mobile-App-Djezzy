// Fichier : middlewares/role.js

const verifierRole = (rolesAutorises) => {
    return (req, res, next) => {
        // Simulation pour Postman (A changer plus tard quand Clerk sera réactivé)
        const userRole = req.body.role_utilisateur;

        if (!userRole || !rolesAutorises.includes(userRole)) {
            return res.status(403).json({
                success: false,
                error: `Accès refusé ! Action réservée aux profils : ${rolesAutorises.join(' ou ')}.`
            });
        }
        next();
    };
};

module.exports = verifierRole;