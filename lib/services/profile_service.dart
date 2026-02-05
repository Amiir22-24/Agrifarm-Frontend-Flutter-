// lib/services/profile_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/storage_helper.dart';
import '../utils/config.dart';

class ProfileService {

  // 🔧 CORRECTION : Utiliser la configuration centralisée
  static String get baseUrl => AppConfig.baseApiUrl;
  
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Backend: GET /user
  static Future<User> getUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception('Erreur profil');
  }

  // Backend: PUT /user/update
  static Future<User> updateUser(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/update'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final user = User.fromJson(jsonDecode(response.body)['user']);
      await StorageHelper.saveUser(user.toJson());
      return user;
    }
    throw Exception('Erreur mise à jour');
  }


  // Backend: PUT /user/weather-city
  static Future<void> updateWeatherCity(String city) async {
    await http.put(
      Uri.parse('$baseUrl/user/weather-city'),
      headers: await _getHeaders(),
      body: jsonEncode({'default_weather_city': city}),
    );
  }

  // Backend: GET /user/weather-city
  static Future<String> getWeatherCity() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/weather-city'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['default_weather_city'] ?? '';
    }
    throw Exception('Erreur récupération ville météo');
  }

  // Backend: DELETE /user/delete
  static Future<void> deleteUser() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/user/delete'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur suppression profil');
    }
  }

  // Backend: PUT /user/change-password
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/change-password'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 422) {
      // Erreur de validation - extraire le message
      try {
        final errorData = jsonDecode(response.body);
        final errors = errorData['errors'] ?? errorData;
        if (errors is Map<String, dynamic>) {
          final messages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              messages.addAll(value.map((e) => '$key: $e'));
            } else {
              messages.add('$key: $value');
            }
          });
          throw Exception(messages.join(', '));
        }
        throw Exception('Données invalides');
      } catch (e) {
        if (e.toString().startsWith('Exception:')) rethrow;
        throw Exception('Le mot de passe actuel est incorrect');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Mot de passe actuel incorrect');
    }
    throw Exception('Erreur lors du changement de mot de passe');
  }
}
