import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/djezzy_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showEditProfileDialog(BuildContext context, Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['nom']);
    final phoneController = TextEditingController(text: user['telephone']);
    final wilayaController = TextEditingController(text: user['wilaya']);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom Complet', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Numéro de Téléphone', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: wilayaController,
                    decoration: const InputDecoration(labelText: 'Wilaya (ex: Alger-Est)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : () async {
                        setModalState(() => isSaving = true);
                        bool success = await Provider.of<AuthProvider>(context, listen: false).updateProfile(
                          telephone: phoneController.text.trim(),
                          wilaya: wilayaController.text.trim(),
                          nomComplet: nameController.text.trim(),
                        );
                        setModalState(() => isSaving = false);
                        
                        if (success) {
                          if (context.mounted) context.pop(); // Close Modal
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profil mis à jour !'), backgroundColor: Colors.green),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Erreur lors de la mise à jour'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: DjezzyTheme.primaryRed),
                      child: isSaving 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Sauvegarder les modifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer le vrai utilisateur connecté
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Center(child: Text("Utilisateur non connecté", style: TextStyle(color: DjezzyTheme.darkText)));
    }

    String roleFormatted = user['role'] == 'TECHNICIAN' ? 'Technicien' : (user['role'] == 'COMMERCIAL' ? 'Commercial' : user['role']);
    String displayName = user['nom'] ?? 'Sans Nom';
    String email = user['email'] ?? 'Non défini';
    String telephone = (user['telephone'] == null || user['telephone'].toString().isEmpty) ? 'Non défini' : user['telephone'];
    String wilaya = (user['wilaya'] == null || user['wilaya'].toString().isEmpty) ? 'Non définie' : user['wilaya'];
    String initials = displayName.split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEEEEE), // Light grey header
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Grey Background Top Half
          Container(
            height: 100,
            color: const Color(0xFFEEEEEE),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Main Profile Card
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 50), // Space for Avatar
                            Text(
                              '$roleFormatted $displayName',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DjezzyTheme.darkText),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'SKILL: ${user['specialite'] ?? 'Fibre Optique'}',
                                style: const TextStyle(color: DjezzyTheme.darkText, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('User ID: ${user['id']}', style: const TextStyle(color: DjezzyTheme.lightText, fontSize: 12)),
                            const SizedBox(height: 24),
                            
                            // Contact Section
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 16),
                                  _buildProfileRow('Phone', telephone),
                                  const Divider(height: 24, color: Color(0xFFEEEEEE)),
                                  _buildProfileRow('Email', email),
                                  const Divider(height: 24, color: Color(0xFFEEEEEE)),
                                  _buildProfileRow('Regional Office:', wilaya, isMultiLineTitle: true),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Edit Profile Button
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE0E0E0),
                                    foregroundColor: DjezzyTheme.darkText,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _showEditProfileDialog(context, user),
                                  child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      // Avatar with fallback
                      Positioned(
                        top: 0,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: DjezzyTheme.primaryRed,
                            child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
    );
  }

  Widget _buildProfileRow(String title, String value, {bool isMultiLineTitle = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isMultiLineTitle ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(color: DjezzyTheme.lightText, fontSize: 14)),
        Text(value, style: const TextStyle(color: DjezzyTheme.darkText, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
