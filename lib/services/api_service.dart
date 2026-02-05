// lib/services/api_service.dart - VERSION COMPLÈTE ET COMPATIBLE
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vente.dart';
import '../models/stock.dart';
import '../utils/storage_helper.dart';

class ApiService {

  static const String baseUrl = 'http://localhost:8000/api';
  static const String sanctumUrl = 'http://localhost:8000';
  
  // ✅ Protection CSRF pour Laravel Sanctum (requis pour mobile)
  static Future<void> _initCsrf() async {
    try {
      await http.get(
        Uri.parse('$sanctumUrl/sanctum/csrf-cookie'),
        headers: {
          'Accept': 'application/json',
          'Origin': 'http://localhost:8000',
          'Referer': 'http://localhost:8000/',
        },
      );
      print('✅ CSRF cookie initialisé');
    } catch (e) {
      print('⚠️ Erreur CSRF (non critique): $e');
    }
  }
  
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Origin': 'http://localhost:8000',
      'Referer': 'http://localhost:8000/',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ========== STOCKS ==========
  static Future<Stock> updateStock(int id, Stock stock) async {
    final response = await http.put(
      Uri.parse('$baseUrl/stocks/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(stock.toJson()),
    );

    if (response.statusCode == 200) {
      return Stock.fromJson(jsonDecode(response.body)['stock']);
    }
    throw Exception('Erreur mise à jour stock');
  }

  static Future<void> deleteStock(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/stocks/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur suppression stock');
    }
  }

  // ========== VENTES COMPLÉMENT ==========
  static Future<Vente> updateVente(int id, Vente vente) async {
    final response = await http.put(
      Uri.parse('$baseUrl/ventes/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(vente.toJson()),
    );

    if (response.statusCode == 200) {
      return Vente.fromJson(jsonDecode(response.body)['vente']);
    }
    throw Exception('Erreur mise à jour vente');
  }

  static Future<void> deleteVente(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ventes/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur suppression vente');
    }
  }

  // ========== RECHERCHE ==========
  static Future<Map<String, dynamic>> search(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=$query'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur recherche');
  }

  // ========== MÉTHODES UTILITAIRES AJOUTÉES ==========

  // 🔍 Méthode utilitaire pour les requêtes GET génériques
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur GET: ${response.statusCode}');
  }

  // ➕ Méthode utilitaire pour les requêtes POST génériques
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur POST: ${response.statusCode}');
  }

  // ✏️ Méthode utilitaire pour les requêtes PUT génériques
  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur PUT: ${response.statusCode}');
  }

  // 🗑️ Méthode utilitaire pour les requêtes DELETE génériques
  static Future<void> deleteGeneric(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erreur DELETE: ${response.statusCode}');
    }
  }

  // 🌍 Méthode utilitaire pour la géolocalisation
  static Future<Map<String, double>> getCurrentLocation() async {
    return {
      'lat': 6.1725, // Lomé par défaut
      'lon': 1.2314,
    };
  }

  // 📊 Méthode utilitaire pour les statistiques du dashboard
  static Future<Map<String, dynamic>> getDashboardStats() async {
    return get('/dashboard/stats');
  }

  // 🔍 Recherche globale dans l'application
  static Future<Map<String, dynamic>> globalSearch(String query) async {
    return get('/search?q=$query');
  }

  // 📈 Méthodes d'analytics et rapports
  static Future<Map<String, dynamic>> getAnalytics({
    required String periode,
    String? from,
    String? to,
  }) async {
    var params = 'periode=$periode';
    if (from != null) params += '&from=$from';
    if (to != null) params += '&to=$to';
    
    return get('/analytics?$params');
  }

  // 🔔 Gestion des notifications push (Firebase)
  static Future<void> registerDeviceToken(String token) async {
    try {
      await post('/notifications/register-device', {'device_token': token});
    } catch (e) {
      // Ignorer les erreurs de registration pour éviter les boucles
    }
  }

  // 📱 Gestion de la synchronisation des données offline
  static Future<Map<String, dynamic>> syncOfflineData(Map<String, dynamic> data) async {
    return post('/sync', data);
  }

  // 🔒 Gestion du token et authentification
  static Future<void> refreshToken() async {
    // Méthode pour rafraîchir le token d'authentification
    // Peut être appelée lors de l'expiration du token
  }

  // ⚙️ Configuration de l'application
  static Future<Map<String, dynamic>> getAppConfig() async {
    return get('/config');
  }

  // 📝 Logs et debugging
  static Future<void> logError(Map<String, dynamic> errorData) async {
    try {
      await post('/logs/error', errorData);
    } catch (e) {
      // Ignorer les erreurs de log pour éviter les boucles
    }
  }


  // 🌐 Vérification de la connectivité réseau
  static Future<bool> checkConnection() async {
    try {
      await get('/health');
      return true;
    } catch (e) {
      return false;
    }
  }

  // 🟢 SYNCHRONISÉ avec backend - Route de santé de l'API
  static Future<Map<String, dynamic>> checkHealth() async {
    final response = await http.get(
      Uri.parse('$baseUrl/health'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('API non disponible: ${response.statusCode}');
  }

  // ========== MÉTHODES DE COMPATIBILITÉ ==========
  // ⚠️ Ces méthodes sont conservées pour la compatibilité avec l'ancien code

  // Pour Stock - méthodes compatibles avec les providers existants
  static Future<List<Stock>> getStocks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/stocks'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((json) => Stock.fromJson(json)).toList();
    }
    throw Exception('Erreur stocks');
  }

  static Future<Stock> createStock(Stock stock) async {
    final response = await http.post(
      Uri.parse('$baseUrl/stocks'),
      headers: await _getHeaders(),
      body: jsonEncode(stock.toJson()),
    );

    if (response.statusCode == 201) {
      return Stock.fromJson(jsonDecode(response.body)['stock']);
    } else if (response.statusCode == 422) {
      // 🔧 CORRECTION 422 : Message d'erreur détaillé pour les erreurs de validation
      try {
        final errorData = jsonDecode(response.body);
        final errors = errorData['errors'] ?? errorData;
        final errorMessage = _formatValidationErrors(errors);
        throw Exception('VALIDATION_ERROR: $errorMessage');
      } catch (e) {
        throw Exception('Données invalides - Veuillez vérifier les informations saisies');
      }
    }
    throw Exception('Erreur création stock: ${response.statusCode}');
  }

  // Pour Vente - méthodes compatibles avec les providers existants
  static Future<Map<String, dynamic>> getVentes({String? from, String? to, int page = 1, int perPage = 20}) async {
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
    throw Exception('Erreur ventes');
  }

  static Future<Vente> createVente(Vente vente) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ventes'),
      headers: await _getHeaders(),
      body: jsonEncode(vente.toJson()),
    );

    if (response.statusCode == 201) {
      return Vente.fromJson(jsonDecode(response.body)['vente']);
    }
    throw Exception('Erreur création');
  }

  // ========== AUTHENTIFICATION ==========
  static Future<Map<String, dynamic>> login(String email, String password) async {
    // ✅ Initialiser CSRF avant login (requis pour Laravel Sanctum)
    await _initCsrf();
    
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: await _getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('EMAIL_PASSWORD_INVALID');
    }
    throw Exception('Erreur connexion');
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    // ✅ Initialiser CSRF avant registration (requis pour Laravel Sanctum)
    await _initCsrf();
    
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: await _getHeaders(),
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur inscription');
  }

  static Future<void> logout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur déconnexion');
    }
  }

  // ========== PROFIL UTILISATEUR ==========
  static Future<Map<String, dynamic>> getUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur profil');
  }

  static Future<Map<String, dynamic>> updateUser(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/update'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur mise à jour profil');
  }

  static Future<void> updateWeatherCity(String city) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/weather-city'),
      headers: await _getHeaders(),
      body: jsonEncode({'default_weather_city': city}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur mise à jour ville météo');
    }
  }

  // ========== CHANGEMENT DE MOT DE PASSE ==========
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

  // 🔧 CORRECTION 422 : Méthode utilitaire pour formater les erreurs de validation
  static String _formatValidationErrors(dynamic errors) {
    if (errors is Map<String, dynamic>) {
      final messages = <String>[];
      errors.forEach((field, errorMessages) {
        if (errorMessages is List) {
          messages.addAll(errorMessages.map((msg) => '$field: $msg'));
        } else {
          messages.add('$field: $errorMessages');
        }
      });
      return messages.join(', ');
    }
    return 'Erreur de validation inconnue';
  }
}
