import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchTasks(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // Prévient l'interface graphique de charger l'animation

    try {
      _tasks = await _taskService.getTasks(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Prévient l'UI que les données sont arrivées
    }
  }

  Future<bool> closeIntervention(int taskId, String btsId) async {
    bool success = await _taskService.closeTask(taskId, btsId);
    if (success) {
      // On retire la tâche de la liste locale pour éviter à l'utilisateur de recharger la page
      _tasks.removeWhere((t) => t.taskId == taskId);
      notifyListeners();
    }
    return success;
  }

  Future<bool> triggerAutoAssign(String userId) async {
    bool success = await _taskService.triggerAutoAssign();
    if (success) {
      // Recharger la liste des tâches si une nouvelle tâche a été assignée
      await fetchTasks(userId);
    }
    return success;
  }
}
