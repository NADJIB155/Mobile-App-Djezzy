import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class AuthService {
  final String baseUrl = ApiConstants.baseUrl;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur d\'authentification');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String nom,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nom_complet': nom,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Erreur lors de l\'inscription');
      }
    } catch (e) {
      rethrow;
    }
  }
}
