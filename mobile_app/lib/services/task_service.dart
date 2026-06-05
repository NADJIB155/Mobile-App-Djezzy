import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'api_constants.dart';

class TaskService {
  // Récupère les pannes assignées au technicien
  Future<List<Task>> getTasks(String userId) async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/tasks/$userId'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Erreur de chargement des pannes');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Clôture une intervention (Met à jour la tâche en COMPLETED et la BTS en ON AIR)
  Future<bool> closeTask(int taskId, String btsId) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/tasks/close'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'task_id': taskId,
          'bts_id': btsId,
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

  // Déclenche l'algorithme d'auto-assignation
  Future<bool> triggerAutoAssign() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/tasks/auto-assign'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
