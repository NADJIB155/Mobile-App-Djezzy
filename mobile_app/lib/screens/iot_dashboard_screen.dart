import 'package:flutter/material.dart';
import '../theme/djezzy_theme.dart';

class IotDashboardScreen extends StatelessWidget {
  const IotDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Télémétrie IoT & Prédictions', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Supervision des Antennes (En temps réel)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DjezzyTheme.darkText)),
            const SizedBox(height: 16),
            
            // Alerte Prédictive
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Alerte de Maintenance Prédictive', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('BTS DJEZ_4B5D0C1D - Secteur 2', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Anomalie détectée : La température de la batterie auxiliaire augmente anormalement depuis 48h. Risque de coupure dans < 3 jours.', style: TextStyle(fontSize: 13, color: DjezzyTheme.lightText)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Intervention Préventive générée !'), backgroundColor: Colors.green));
                      },
                      icon: const Icon(Icons.add_task, color: Colors.white, size: 18),
                      label: const Text('Générer un ticket préventif', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('Indicateurs Clés (KPIs IoT)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DjezzyTheme.darkText)),
            const SizedBox(height: 16),
            
            // Jauges
            Row(
              children: [
                Expanded(child: _buildKpiCard('Temp. Cabine', '38°C', Icons.thermostat, Colors.orange, 0.8)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard('Charge Batterie', '42%', Icons.battery_charging_full, Colors.red, 0.4)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildKpiCard('Tension (V)', '48.2V', Icons.electric_bolt, Colors.green, 0.9)),
                const SizedBox(width: 16),
                Expanded(child: _buildKpiCard('Qualité Signal', '95%', Icons.signal_cellular_alt, Colors.green, 0.95)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: DjezzyTheme.darkText)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}
