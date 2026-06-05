import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/djezzy_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  const AppDrawer({super.key, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final displayName = user?['nom'] ?? 'Sans Nom';
    final userId = user?['id'] ?? 'ID-XXXX';
    final String initials = displayName.split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join();

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: DjezzyTheme.primaryRed,
                    child: Text(
                      initials,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DjezzyTheme.darkText),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ID: $userId',
                          style: const TextStyle(fontSize: 12, color: DjezzyTheme.lightText, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, color: Colors.green, size: 8),
                              SizedBox(width: 4),
                              Text(
                                'Connected',
                                style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.black12, height: 1),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    isSelected: selectedIndex == 0,
                    onTap: () => _navigateTo(context, '/'),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.map_outlined,
                    title: 'Map View',
                    isSelected: selectedIndex == 1,
                    onTap: () => _navigateTo(context, '/map'),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.check_circle_outline,
                    title: 'My Tasks',
                    trailing: Consumer<TaskProvider>(
                      builder: (context, taskProvider, child) {
                        int taskCount = taskProvider.tasks.length;
                        if (taskCount == 0) return const SizedBox();
                        return Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: DjezzyTheme.primaryRed,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            taskCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      context.pop();
                      context.push('/tasks');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.folder_open,
                    title: 'Forms Center',
                    isSelected: selectedIndex == 2,
                    onTap: () => _navigateTo(context, '/forms'),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Divider(color: Colors.black12),
                  ),
                  const SizedBox(height: 10),
                  _buildDrawerItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'My Profile',
                    isSelected: selectedIndex == 3,
                    onTap: () => _navigateTo(context, '/profile'),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      context.pop();
                      context.push('/settings');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      Provider.of<AuthProvider>(context, listen: false).logout();
                      // Navigation gérée par refreshListenable de GoRouter
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String path) {
    context.pop();
    context.go(path);
  }

  Widget _buildDrawerItem(BuildContext context, {
    required IconData icon, 
    required String title, 
    required VoidCallback onTap, 
    bool isSelected = false,
    Widget? trailing
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: isSelected ? Colors.black.withOpacity(0.04) : Colors.transparent,
        leading: Icon(
          icon, 
          color: isSelected ? DjezzyTheme.primaryRed : DjezzyTheme.darkText,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: DjezzyTheme.darkText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
