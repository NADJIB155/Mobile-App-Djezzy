import 'package:flutter/material.dart';
import '../theme/djezzy_theme.dart';
import '../widgets/app_drawer.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<Map<String, dynamic>> _inventory = [
    {
      'name': 'Câble Fibre Optique 10m',
      'category': 'Câblage',
      'inVehicle': 2,
      'inDepot': 150,
      'icon': Icons.cable
    },
    {
      'name': 'Redresseur 48V',
      'category': 'Énergie',
      'inVehicle': 0,
      'inDepot': 12,
      'icon': Icons.battery_charging_full
    },
    {
      'name': 'Carte RRU 4G',
      'category': 'Transmission',
      'inVehicle': 1,
      'inDepot': 5,
      'icon': Icons.router
    },
    {
      'name': 'Module SFP+',
      'category': 'Transmission',
      'inVehicle': 5,
      'inDepot': 45,
      'icon': Icons.settings_input_component
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Logistique & Stocks', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Inventaire Pièces Détachées', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: DjezzyTheme.darkText)),
                const SizedBox(height: 8),
                const Text('Consultez votre stock véhicule et réservez des pièces au dépôt central.', style: TextStyle(color: DjezzyTheme.lightText)),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher une pièce, un code Barre...',
                    prefixIcon: const Icon(Icons.search, color: DjezzyTheme.lightText),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _inventory.length,
              itemBuilder: (context, index) {
                final item = _inventory[index];
                final bool needsOrder = item['inVehicle'] == 0;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: needsOrder ? Colors.red.withOpacity(0.3) : Colors.black12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: DjezzyTheme.primaryRed.withOpacity(0.1),
                            child: Icon(item['icon'], color: DjezzyTheme.primaryRed),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: DjezzyTheme.darkText)),
                                Text(item['category'], style: const TextStyle(fontSize: 12, color: DjezzyTheme.lightText)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStockIndicator('Stock Véhicule', item['inVehicle'], needsOrder ? Colors.red : Colors.green),
                          _buildStockIndicator('Stock Dépôt', item['inDepot'], Colors.blue),
                        ],
                      ),
                      if (needsOrder) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Demande de ${item['name']} envoyée au dépôt !'), backgroundColor: Colors.green));
                            },
                            icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                            label: const Text('Commander au dépôt', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(backgroundColor: DjezzyTheme.primaryRed),
                          ),
                        ),
                      ]
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockIndicator(String label, int qty, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: DjezzyTheme.lightText)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.inventory_2, size: 14, color: color),
            const SizedBox(width: 4),
            Text('$qty Unité(s)', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        )
      ],
    );
  }
}
