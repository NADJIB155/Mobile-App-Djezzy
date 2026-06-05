import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/djezzy_theme.dart';
import '../models/task.dart';
import 'post_intervention_review_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null && user['id'] != null) {
        Provider.of<TaskProvider>(context, listen: false).fetchTasks(user['id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer dynamiquement l'ID de l'utilisateur connecté
    final String currentUserId = Provider.of<AuthProvider>(context).user?['id'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: DjezzyTheme.darkText, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          children: [
            Text('Assigned Interventions', style: TextStyle(color: DjezzyTheme.darkText, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('(My Tasks)', style: TextStyle(color: DjezzyTheme.lightText, fontSize: 12)),
          ],
        ),
        centerTitle: true,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: DjezzyTheme.primaryRed));
          }

          if (provider.tasks.isEmpty) {
            return const Center(
              child: Text('Aucune intervention assignée.', style: TextStyle(color: DjezzyTheme.lightText)),
            );
          }

          return RefreshIndicator(
            color: DjezzyTheme.primaryRed,
            onRefresh: () => provider.fetchTasks(currentUserId),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: provider.tasks.length,
              itemBuilder: (context, index) {
                return _buildTaskCard(context, provider.tasks[index], provider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (currentUserId.isEmpty) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lancement de l\'algorithme IA...')));
          bool success = await Provider.of<TaskProvider>(context, listen: false).triggerAutoAssign(currentUserId);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Succès : Nouvelle panne assignée !'), backgroundColor: Colors.green));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucune panne en attente.'), backgroundColor: Colors.orange));
          }
        },
        backgroundColor: DjezzyTheme.primaryRed,
        icon: const Icon(Icons.smart_toy, color: Colors.white),
        label: const Text('Auto-Assign (IA)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task, TaskProvider provider) {
    // Styling status badge based on priority/status
    Color badgeColor = Colors.grey;
    String badgeText = "DELAYED";
    
    if (task.priorite == 'HAUTE') {
      badgeColor = DjezzyTheme.primaryRed;
      badgeText = "URGENT";
    } else if (task.priorite == 'MOYENNE' || task.statutTask == 'IN PROGRESS') {
      badgeColor = Colors.orange;
      badgeText = "IN PROGRESS";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.titre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: DjezzyTheme.darkText),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('BTS Code:', task.btsId),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoRow('Wilaya:', 'ALGER'),
                    const Text('16/05/2026', style: TextStyle(color: DjezzyTheme.darkText, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Failure:', style: TextStyle(color: DjezzyTheme.lightText, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  task.description,
                  style: const TextStyle(color: DjezzyTheme.darkText, fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // View Details Button (Bottom Grey Area)
          GestureDetector(
            onTap: () => context.push('/task-review', extra: task),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
              ),
              child: const Center(
                child: Text(
                  'Clôturer / Soumettre Rapport',
                  style: TextStyle(color: DjezzyTheme.darkText, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label ',
          style: const TextStyle(color: DjezzyTheme.lightText, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(color: DjezzyTheme.darkText, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
