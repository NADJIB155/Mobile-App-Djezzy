import 'package:flutter/material.dart';
import '../theme/djezzy_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: DjezzyTheme.darkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: TextStyle(color: DjezzyTheme.darkText, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text('Général', style: TextStyle(color: DjezzyTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          _buildSettingsTile(icon: Icons.language, title: 'Langue', subtitle: 'Français', onTap: () {}),
          _buildSettingsTile(icon: Icons.notifications_active, title: 'Notifications', subtitle: 'Activées', onTap: () {}),
          _buildSettingsTile(icon: Icons.dark_mode, title: 'Mode Sombre', subtitle: 'Désactivé', onTap: () {}),
          
          const SizedBox(height: 32),
          const Text('Sécurité', style: TextStyle(color: DjezzyTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          _buildSettingsTile(icon: Icons.lock_outline, title: 'Changer le mot de passe', onTap: () {}),
          _buildSettingsTile(icon: Icons.security, title: 'Authentification à deux facteurs', subtitle: 'Désactivée', onTap: () {}),
          
          const SizedBox(height: 32),
          const Text('À propos', style: TextStyle(color: DjezzyTheme.primaryRed, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          _buildSettingsTile(icon: Icons.info_outline, title: 'Version de l\'application', subtitle: 'v1.0.0 (Beta)'),
          _buildSettingsTile(icon: Icons.description_outlined, title: 'Conditions d\'utilisation', onTap: () {}),
          _buildSettingsTile(icon: Icons.privacy_tip_outlined, title: 'Politique de confidentialité', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(icon, color: DjezzyTheme.darkText),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: DjezzyTheme.darkText)),
          subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: DjezzyTheme.lightText, fontSize: 12)) : null,
          trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16, color: DjezzyTheme.lightText) : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
