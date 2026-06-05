import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/bts_provider.dart';
import '../theme/djezzy_theme.dart';
import '../models/bts.dart';
import '../widgets/app_drawer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    // Appel du backend au chargement de la carte
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BtsProvider>(context, listen: false).fetchBtsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte du Réseau Djezzy', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<BtsProvider>(
        builder: (context, btsProvider, child) {
          if (btsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: DjezzyTheme.primaryRed));
          }

          if (btsProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, color: DjezzyTheme.primaryRed, size: 48),
                  const SizedBox(height: 16),
                  const Text("Impossible de joindre le serveur Node.js", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(btsProvider.errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => btsProvider.fetchBtsList(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // Génération dynamique des icônes sur la carte avec les données Neon / Node.js
          final markers = btsProvider.btsList.map((bts) {
            Color markerColor = bts.statut == 'ON AIR' ? Colors.green : (bts.statut == 'DELAYED' ? Colors.red : Colors.orange);
            
            return Marker(
              width: 50.0,
              height: 50.0,
              // Attention : LatLng prend (Latitude, Longitude) donc (Y, X)
              point: LatLng(bts.btsY, bts.btsX),
              child: GestureDetector(
                onTap: () {
                  _showBtsDetails(context, bts);
                },
                child: Icon(
                  Icons.location_on,
                  color: markerColor,
                  size: 40.0,
                  shadows: const [Shadow(color: Colors.black26, blurRadius: 5)],
                ),
              ),
            );
          }).toList();

          // Centrage dynamique : La carte cible les coordonnées de la première VRAIE antenne de ta base
          double centerLat = 36.7525;
          double centerLng = 3.0419;
          if (btsProvider.btsList.isNotEmpty) {
             centerLat = btsProvider.btsList.first.btsY;
             centerLng = btsProvider.btsList.first.btsX;
          }

          return FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(centerLat, centerLng), 
              initialZoom: 10.0, // Zoom ajusté pour voir tes données
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.djezzy.maintenance',
              ),
              MarkerLayer(
                markers: markers,
              ),
            ],
          );
        },
      ),
      drawer: const AppDrawer(),
    );
  }

  void _showBtsDetails(BuildContext context, Bts bts) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Antenne ${bts.btsId}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: DjezzyTheme.darkText)),
                const SizedBox(height: 24),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(backgroundColor: DjezzyTheme.primaryRed, child: Icon(Icons.router, color: Colors.white)),
                  title: const Text('Technologie'),
                  subtitle: Text(bts.typeAntenne, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: bts.statut == 'ON AIR' ? Colors.green : Colors.red,
                    child: const Icon(Icons.monitor_heart, color: Colors.white),
                  ),
                  title: const Text('Statut actuel'),
                  subtitle: Text(
                    bts.statut, 
                    style: TextStyle(fontWeight: FontWeight.bold, color: bts.statut == 'ON AIR' ? Colors.green : Colors.red)
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(backgroundColor: Colors.blueGrey, child: Icon(Icons.gps_fixed, color: Colors.white)),
                  title: const Text('Coordonnées GPS'),
                  subtitle: Text('Lat: ${bts.btsY.toStringAsFixed(4)} / Long: ${bts.btsX.toStringAsFixed(4)}'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer la vue'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
