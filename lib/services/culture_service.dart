// 🔴 PRIORITÉ 1 - lib/services/culture_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/culture.dart';
import '../utils/storage_helper.dart';

class CultureService {

  static const String baseUrl = 'http://localhost:8000/api';
  
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Backend retourne directement un array
  static Future<List<Culture>> getCultures() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cultures'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((json) => Culture.fromJson(json)).toList();
    }
    throw Exception('Erreur cultures');
  }



  static Future<Culture> createCulture(Culture culture) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cultures'),
      headers: await _getHeaders(),
      body: jsonEncode(culture.toJson()),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Le backend peut retourner la culture dans différentes structures
      Map<String, dynamic> cultureData;
      if (responseData['data'] != null) {
        // Structure avec clé 'data'
        cultureData = responseData['data'] as Map<String, dynamic>;
      } else if (responseData['culture'] != null) {
        // Structure avec clé 'culture'
        cultureData = responseData['culture'] as Map<String, dynamic>;
      } else {
        // Structure directe (la culture elle-même)
        cultureData = responseData;
      }
      
      return Culture.fromJson(cultureData);
    }
    throw Exception('Erreur création: ${response.body}');
  }

  static Future<Culture> updateCulture(int id, Culture culture) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cultures/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(culture.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      // Le backend peut retourner la culture dans différentes structures
      if (responseData['culture'] != null) {
        return Culture.fromJson(responseData['culture'] as Map<String, dynamic>);
      } else if (responseData['data'] != null) {
        return Culture.fromJson(responseData['data'] as Map<String, dynamic>);
      } else if (responseData.containsKey('id')) {
        return Culture.fromJson(responseData);
      }
      throw Exception('Structure de réponse inattendue');
    }
    throw Exception('Erreur modification: ${response.body}');
  }

  static Future<void> deleteCulture(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cultures/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur suppression: ${response.body}');
    }
  }

  // Météo pour une culture
  static Future<Map<String, dynamic>> getCultureWeather(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cultures/$id/weather'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur météo culture');
  }
}