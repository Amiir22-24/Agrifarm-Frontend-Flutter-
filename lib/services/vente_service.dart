// ✅ CORRIGÉ - lib/services/vente_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vente.dart';
import '../utils/storage_helper.dart';

class VenteService {

  static const String baseUrl = 'http://localhost:8000/api';
  static const String sanctumUrl = 'http://localhost:8000';
  
  // ✅ Protection CSRF pour Laravel Sanctum
  static Future<void> _initCsrf() async {
    try {
      final client = http.Client();
      final response = await client.get(
        Uri.parse('$sanctumUrl/sanctum/csrf-cookie'),
        headers: {
          'Accept': 'application/json',
          'Origin': 'http://localhost:8000',
          'Referer': 'http://localhost:8000/',
        },
      );
      
      // Extraire le cookie XSRF-TOKEN de la réponse pour le transmettre
      final xsrfToken = response.headers['set-cookie']?.split(';').firstWhere(
        (c) => c.contains('XSRF-TOKEN'), 
        orElse: () => ''
      );
      
      if (xsrfToken != null && xsrfToken.isNotEmpty) {
        print('✅ CSRF cookie récupéré: $xsrfToken');
        // Stocker le token CSRF (partiellement, car HttpOnly)
        // Note: Les cookies HttpOnly ne peuvent pas être lus par JS/Dart
      } else {
        print('✅ CSRF cookie défait');
      }
      
      client.close();
    } catch (e) {
      print('⚠️ Erreur CSRF ventes: $e');
    }
  }
  
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-XSRF-TOKEN': token ?? '', // Token pour Laravel Sanctum
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Backend: GET /ventes?from=&to=&per_page=20
  static Future<Map<String, dynamic>> getVentes({
    String? from,
    String? to,
    int page = 1,
    int perPage = 20,
  }) async {
    // ✅ Initialiser CSRF avant les requêtes authentifiées
    await _initCsrf();
    
    var uri = Uri.parse('$baseUrl/ventes');
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    };
    uri = uri.replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur lors du chargement des ventes (${response.statusCode})');
  }

  static Future<Vente> createVente(Vente vente) async {
    // ✅ Log des headers pour débogage
    final headers = await _getHeaders();
    print('📤 Headers envoyés: $headers');
    
    // ✅ Initialiser CSRF avant les requêtes authentifiées
    await _initCsrf();
    
    final response = await http.post(
      Uri.parse('$baseUrl/ventes'),
      headers: headers,
      body: jsonEncode(vente.toJson()),
    );

    // 📊 Journaliser la réponse pour le débogage
    print('📤 Vente sent: ${jsonEncode(vente.toJson())}');
    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 201) {
      // ✅ CORRIGÉ: Vérifier si le body est null ou vide
      final body = response.body;
      if (body == null || body.isEmpty) {
        throw Exception('Réponse vide du serveur - La vente a peut-être été créée');
      }
      
      try {
        final jsonResponse = jsonDecode(body);
        if (jsonResponse == null) {
          throw Exception('Format de réponse invalide du serveur');
        }
        
        // ✅ CORRIGÉ: Accepter les deux formats de réponse du backend
        // Format 1: {"vente": {...}} (ancien format)
        // Format 2: {"data": {...}} (nouveau format)
        Map<String, dynamic>? venteData;
        if (jsonResponse['vente'] != null) {
          venteData = jsonResponse['vente'] as Map<String, dynamic>;
        } else if (jsonResponse['data'] != null) {
          venteData = jsonResponse['data'] as Map<String, dynamic>;
        } else {
          // Si la réponse contient directement l'objet vente sans clé
          venteData = jsonResponse;
        }
        
        if (venteData == null || venteData.isEmpty) {
          throw Exception('Format de réponse invalide du serveur');
        }
        
        return Vente.fromJson(venteData);
      } catch (e) {
        print('⚠️ Erreur parsing JSON: $e');
        print('📥 Response body: $body');
        throw Exception('Erreur lors du parsing de la réponse du serveur');
      }
    }
    
    // ✅ Gérer les erreurs 422 (Validation) spécifiquement
    if (response.statusCode == 422) {
      try {
        final errorData = jsonDecode(response.body);
        final errors = errorData['errors'] ?? errorData;
        final errorMessage = _formatValidationErrors(errors);
        throw Exception('Validation Error ($response.statusCode): $errorMessage');
      } catch (e) {
        if (e is Exception && e.toString().contains('Validation Error')) {
          rethrow;
        }
        throw Exception('Données invalides - Vérifiez les champs obligatoires ($response.statusCode)');
      }
    }

    // ✅ Gérer les erreurs 401 (Unauthorized)
    if (response.statusCode == 401) {
      // ⚠️ NE PLUS supprimer le token automatiquement
      // L'utilisateur reste connecté mais l'erreur est affichée
      print('⚠️ Erreur 401 - Token potentiellement invalide');
      throw Exception('Erreur d\'authentification (401) - Veuillez vérifier votre session');
    }

    // ✅ Gérer les erreurs 500 (Server Error)
    if (response.statusCode >= 500) {
      throw Exception('Erreur serveur - Veuillez réessayer plus tard ($response.statusCode)');
    }

    throw Exception('Erreur lors de la création de la vente (code: ${response.statusCode})');
  }

  static Future<Vente> updateVente(int id, Vente vente) async {
    final response = await http.put(
      Uri.parse('$baseUrl/ventes/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(vente.toJson()),
    );

    if (response.statusCode == 200) {
      // ✅ CORRIGÉ: Accepter les deux formats de réponse
      final jsonResponse = jsonDecode(response.body);
      Map<String, dynamic> venteData;
      if (jsonResponse['vente'] != null) {
        venteData = jsonResponse['vente'] as Map<String, dynamic>;
      } else if (jsonResponse['data'] != null) {
        venteData = jsonResponse['data'] as Map<String, dynamic>;
      } else {
        venteData = jsonResponse as Map<String, dynamic>;
      }
      return Vente.fromJson(venteData);
    }
    throw Exception('Erreur lors de la modification (code: ${response.statusCode})');
  }

  static Future<void> deleteVente(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ventes/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression (code: ${response.statusCode})');
    }
  }

  // 🔧 Méthode utilitaire pour formater les erreurs de validation
  static String _formatValidationErrors(dynamic errors) {
    if (errors is Map<String, dynamic>) {
      final messages = <String>[];
      errors.forEach((field, errorList) {
        if (errorList is List) {
          messages.add('$field: ${errorList.join(", ")}');
        } else {
          messages.add('$field: $errorList');
        }
      });
      return messages.join(' | ');
    }
    return 'Erreur de validation inconnue';
  }
}
