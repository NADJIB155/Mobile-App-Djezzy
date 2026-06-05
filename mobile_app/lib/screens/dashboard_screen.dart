import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bts_provider.dart';
import '../theme/djezzy_theme.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Lance la requête vers /api/stats au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BtsProvider>(context, listen: false).fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<BtsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.stats.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: DjezzyTheme.primaryRed));
          }

          if (provider.errorMessage.isNotEmpty && provider.stats.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: DjezzyTheme.lightText),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => provider.fetchStats(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final stats = provider.stats;
          
          return RefreshIndicator(
            color: DjezzyTheme.primaryRed,
            onRefresh: () => provider.fetchStats(),
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                const Text(
                  'Vue Générale du Réseau',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: DjezzyTheme.darkText),
                ),
                const SizedBox(height: 8),
                const Text(
                  'État des antennes et interventions en temps réel',
                  style: TextStyle(color: DjezzyTheme.lightText),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total BTS',
                        count: stats['total']?.toString() ?? '0',
                        icon: Icons.cell_tower,
                        color: Colors.blue,
                        isSmall: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'BTS EN SERVICE',
                        count: stats['on_air']?.toString() ?? '0',
                        icon: Icons.check_circle,
                        color: Colors.green,
                        isSmall: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'EN PANNE',
                        count: stats['pannes']?.toString() ?? '0',
                        icon: Icons.warning_amber,
                        color: Colors.red,
                        isSmall: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Interventions',
                        count: stats['in_progress']?.toString() ?? '0',
                        icon: Icons.handyman,
                        color: Colors.orange,
                        isSmall: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      drawer: const AppDrawer(),
    );
  }

  Widget _buildStatCard({required String title, required String count, required IconData icon, required Color color, bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: isSmall 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: DjezzyTheme.darkText)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 12, color: DjezzyTheme.lightText)),
            ],
          )
        : Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, color: DjezzyTheme.lightText)),
                    const SizedBox(height: 4),
                    Text(count, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: DjezzyTheme.darkText)),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
