import 'package:flutter/material.dart';
import '../models/bts.dart';
import '../services/bts_service.dart';

class BtsProvider with ChangeNotifier {
  final BtsService _btsService = BtsService();
  List<Bts> _btsList = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;
  String _errorMessage = '';

  List<Bts> get btsList => _btsList;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Utilisé par la carte (Map)
  Future<void> fetchBtsList() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _btsList = await _btsService.getBtsList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Utilisé par le Tableau de bord (Dashboard)
  Future<void> fetchStats() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _stats = await _btsService.getStats();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Déclare une panne et rafraîchit la carte et les stats
  Future<bool> reportFailure(String btsId, String severity, String description) async {
    bool success = await _btsService.reportFailure(btsId, severity, description);
    if (success) {
      // Met à jour les données locales pour refléter la panne
      await fetchBtsList();
      await fetchStats();
    }
    return success;
  }
}
