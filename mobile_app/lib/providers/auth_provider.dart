import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    loadUserFromPrefs();
  }

  void setUser(Map<String, dynamic> userData) {
    _user = userData;
    notifyListeners();
  }

  // Persistance : Charger l'utilisateur au démarrage
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      _user = json.decode(userData);
      notifyListeners();
    }
  }

  // Connexion
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final data = await _authService.login(email, password);
      _user = data['user'];
      
      // Sauvegarder localement
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(_user));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Inscription
  Future<bool> register({
    required String nom,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _authService.register(
        nom: nom,
        email: email,
        password: password,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String telephone,
    required String wilaya,
    required String nomComplet,
  }) async {
    // Note: This could also be moved to AuthService for consistency
    // Keeping it here for now but updating the local storage after success
    // (Implementation omitted for brevity, but you should update prefs here too)
    return false;
  }
}
