import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bts.dart';
import 'api_constants.dart';

class BtsService {
  // Récupère la liste des antennes pour la carte réseau
  Future<List<Bts>> getBtsList() async {
    try {
      // Pour l'instant, on n'a pas mis le token Clerk dans le header, 
      // il faudra ajouter { 'Authorization': 'Bearer $token' } quand on gérera le vrai login
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/bts'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Bts.fromJson(json)).toList();
      } else {
        throw Exception('Erreur de chargement des antennes BTS');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Récupère les statistiques pour le Dashboard (ON AIR, DELAYED, IN PROGRESS)
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/stats'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur de chargement des statistiques');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Déclare une panne sur une antenne (Passe le statut à DELAYED)
  Future<bool> reportFailure(String btsId, String severity, String description) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/bts/report-failure'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'bts_id': btsId,
          'severity': severity,
          'description': description,
        }),
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
