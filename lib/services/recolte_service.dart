// lib/services/recolte_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/recolte.dart';
import '../utils/storage_helper.dart';

class RecolteService {

  // ✅ CORRECTION: Détecter automatiquement l'IP correcte selon la plateforme
  // Sur Android émulateur: 10.0.2.2 = localhost de la machine hôte
  // Sur iOS simulator: localhost
  // Sur web/Flutter: utilise l'IP de la machine ou localhost
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else {
      return 'http://10.0.2.2:8000/api';
    }
  }
  
  // ✅ CORRECTION: Méthode pour récupérer l'user_id actuel
  static Future<int?> getCurrentUserId() async {
    final userData = await StorageHelper.getUser();
    return userData?['id'];
  }
  
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Liste de toutes les récoltes (globale - pour admin)
  static Future<List<Recolte>> getRecoltes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/recoltes'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // ✅ CORRECTION: Le backend retourne une structure paginée avec "data"
      if (data is Map<String, dynamic> && data['data'] != null) {
        // Format paginé: {data: [...], current_page: 1, ...}
        final List<dynamic> dataList = data['data'] as List<dynamic>;
        return dataList.map((json) => Recolte.fromJson(json as Map<String, dynamic>)).toList();
      } else if (data is List) {
        // Format liste directe
        return data.map((json) => Recolte.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      return [];
    }
    throw Exception('Erreur liste récoltes: ${response.statusCode}');
  }

  // ✅ NOUVEAU: Récoltes de l'utilisateur connecté uniquement
  static Future<List<Recolte>> getMyRecoltes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/recoltes'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Le backend peut retourner directement une liste ou un objet avec 'data'
      if (data is Map<String, dynamic> && data['data'] != null) {
        final List<dynamic> dataList = data['data'] as List<dynamic>;
        return dataList.map((json) => Recolte.fromJson(json as Map<String, dynamic>)).toList();
      } else if (data is List) {
        return data.map((json) => Recolte.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    }
    throw Exception('Erreur liste récoltes: ${response.statusCode}');
  }

  // Détail d'une récolte
  static Future<Recolte> getRecolte(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recoltes/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Recolte.fromJson(jsonDecode(response.body));
    }
    throw Exception('Erreur détail récolte: ${response.statusCode}');
  }

  // Créer une récolte
  static Future<Recolte> createRecolte(Recolte recolte) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recoltes'),
      headers: await _getHeaders(),
      body: jsonEncode(recolte.toJson()),
    );

    // Debug: afficher la réponse complète
    debugPrint('=== DEBUG RECOLTE CREATE ===');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');
    debugPrint('===========================');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // Le backend peut retourner dans 'recolte', 'data', ou directement
      final recolteData = data['recolte'] ?? data['data'] ?? data;
      if (recolteData == null) {
        throw Exception('Réponse vide du serveur');
      }
      return Recolte.fromJson(recolteData);
    }
    
    // Parser l'erreur 422 pour avoir plus de détails
    try {
      final errorData = jsonDecode(response.body);
      final message = errorData['message'] ?? 'Erreur de validation';
      final errors = errorData['errors'] ?? {};
      String detailedMessage = message;
      errors.forEach((key, value) {
        detailedMessage += '\n$key: $value';
      });
      throw Exception(detailedMessage);
    } catch (e) {
      if (e.toString().contains('Erreur de validation')) {
        rethrow;
      }
      throw Exception('Erreur création récolte: ${response.statusCode}');
    }
  }

  // Mettre à jour une récolte
  static Future<Recolte> updateRecolte(int id, Recolte recolte) async {
    final response = await http.put(
      Uri.parse('$baseUrl/recoltes/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(recolte.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Recolte.fromJson(data['data']);
    }
    throw Exception('Erreur mise à jour récolte: ${response.statusCode}');
  }

  // Supprimer une récolte
  static Future<void> deleteRecolte(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/recoltes/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur suppression récolte: ${response.statusCode}');
    }
  }

  // Récoltes par culture
  static Future<List<Recolte>> getRecoltesByCulture(int cultureId) async {
    final allRecoltes = await getRecoltes();
    return allRecoltes.where((r) => r.cultureId == cultureId).toList();
  }

  // Statistiques des récoltes
  static Future<Map<String, dynamic>> getRecolteStats() async {
    final recoltes = await getRecoltes();
    
    double totalQuantite = 0;
    int excellentes = 0;
    int bonnes = 0;
    int moyennes = 0;

    for (var recolte in recoltes) {
      totalQuantite += recolte.quantite;
      switch (recolte.qualite.toLowerCase()) {
        case 'excellente':
          excellentes++;
          break;
        case 'bonne':
          bonnes++;
          break;
        case 'moyenne':
          moyennes++;
          break;
      }
    }

    return {
      'total': recoltes.length,
      'totalQuantite': totalQuantite,
      'excellentes': excellentes,
      'bonnes': bonnes,
      'moyennes': moyennes,
    };
  }
}
