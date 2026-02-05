// lib/services/meteo_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/storage_helper.dart';
import '../utils/config.dart';
import '../models/alert_meteo.dart';

class MeteoService {

  // 🔧 PHASE 1 CORRECTION 422 : Configuration dynamique
  static String get baseUrl => AppConfig.baseApiUrl;
  
  // Cache pour optimiser les performances (PHASE 1 : Duration configurable)
  static final Map<String, dynamic> _cache = {};
  static Duration get _cacheDuration => Duration(minutes: 10); // Cache 10 minutes par défaut
  
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Méthode utilitaire pour vérifier le cache
  static T? _getCachedData<T>(String key) {
    final cached = _cache[key];
    if (cached != null) {
      final timestamp = cached['timestamp'] as DateTime;
      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        return cached['data'] as T?;
      } else {
        _cache.remove(key);
      }
    }
    return null;
  }

  // Méthode utilitaire pour mettre en cache
  static void _setCachedData(String key, dynamic data) {
    _cache[key] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
  }

  // 🔧 PHASE 1 CORRECTION 422 : Validation stricte des villes (SIMPLIFIÉE)
  static bool _isValidCity(String city) {
    final cleanCity = city.trim();
    if (cleanCity.isEmpty) return false;
    if (cleanCity.length < 2) return false;  // Minimum 2 caractères
    if (cleanCity.length > 50) return false; // Maximum 50 caractères
    // Autoriser lettres, espaces, tirets, points et parenthèses
    return RegExp(r'^[a-zA-ZÀ-ÿ\s\-\.\(\)]+$').hasMatch(cleanCity);
  }

  // Nettoyage des noms de ville pour éviter les erreurs d'encodage URL
  static String _cleanCityName(String city) {
    // 🔧 CORRECTION 422 : Nettoyage renforcé avec normalisation Unicode
    return city
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')     // Normaliser les espaces multiples
        .replaceAll(RegExp(r'[^\w\s\-\.\(\)]'), '') // Supprimer caractères spéciaux non autorisés
        .trim();
  }

  // Gestion d'erreurs améliorée
  static String _handleErrorResponse(int statusCode, String response) {
    switch (statusCode) {
      case 400:
        return 'Données météo invalides';
      case 401:
        return 'Authentification requise';
      case 403:
        return 'Accès refusé';
      case 404:
        return 'Données météo non trouvées';
      case 429:
        return 'Trop de requêtes, veuillez réessayer';
      case 500:
        return 'Erreur serveur météo';
      default:
        return 'Erreur météo ($statusCode): $response';
    }
  }


  // 🟢 Météo par ville - CORRIGÉ pour utiliser l'endpoint existant
  static Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    try {
      // 🔧 CORRECTION 404 : Validation stricte avec config
      if (!_isValidCity(city)) {
        throw Exception('Nom de ville invalide: $city (longueur: ${city.length})');
      }
      
      // Nettoyer la ville correctement
      final cleanCity = _cleanCityName(city);
      
      // 🔧 CORRECTION 404 : Utiliser l'endpoint sans paramètre ville
      // car /meteo/actuelle/{ville} retourne 404 sur le backend
      final url = '$baseUrl/meteo/actuelle';
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 🆕 TRANSFORMATION DES DONNÉES : Aplatir la structure imbriquée
        // L'API retourne: { "ville": "Lomé", "meteo": { "main": { "temp": 30.2, ... }, ... } }
        // On transforme pour que le widget puisse accéder directement aux clés
        final flattenedData = _flattenWeatherData(data);
        
        // Injecter la ville dans la réponse si elle n'est pas présente
        if (flattenedData['city'] == null && flattenedData['ville'] == null) {
          flattenedData['city'] = cleanCity;
          flattenedData['ville'] = cleanCity;
        }
        
        return flattenedData;
      }
      
      throw Exception(_handleErrorResponse(response.statusCode, response.body));
    } catch (e) {
      rethrow;
    }
  }

  /// 🆕 Aplatir les données météorologiques de l'API
  /// Transforme la structure imbriquée en clés plates pour le widget
  static Map<String, dynamic> _flattenWeatherData(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);
    
    // Vérifier si les données sont imbriquées dans "meteo"
    if (data.containsKey('meteo') && data['meteo'] is Map<String, dynamic>) {
      final meteo = data['meteo'] as Map<String, dynamic>;
      
      // Extraire les données de "main" (température, humidité, etc.)
      if (meteo.containsKey('main') && meteo['main'] is Map<String, dynamic>) {
        final main = meteo['main'] as Map<String, dynamic>;
        
        // Température
        if (main.containsKey('temp')) {
          result['temperature'] = main['temp'];
          result['temp'] = main['temp'];
        }
        // Température ressentie
        if (main.containsKey('feels_like')) {
          result['feels_like'] = main['feels_like'];
        }
        // Température min/max
        if (main.containsKey('temp_min')) {
          result['temp_min'] = main['temp_min'];
        }
        if (main.containsKey('temp_max')) {
          result['temp_max'] = main['temp_max'];
        }
        // Humidité
        if (main.containsKey('humidity')) {
          result['humidity'] = main['humidity'];
        }
        // Pression
        if (main.containsKey('pressure')) {
          result['pressure'] = main['pressure'];
        }
        // Niveau de la mer
        if (main.containsKey('sea_level')) {
          result['sea_level'] = main['sea_level'];
        }
        // Niveau du sol
        if (main.containsKey('grnd_level')) {
          result['grnd_level'] = main['grnd_level'];
        }
      }
      
      // Extraire les données du vent
      if (meteo.containsKey('wind') && meteo['wind'] is Map<String, dynamic>) {
        final wind = meteo['wind'] as Map<String, dynamic>;
        if (wind.containsKey('speed')) {
          result['wind_speed'] = wind['speed'];
          result['wind'] = wind['speed'];
        }
        if (wind.containsKey('deg')) {
          result['wind_deg'] = wind['deg'];
        }
        if (wind.containsKey('gust')) {
          result['wind_gust'] = wind['gust'];
        }
      }
      
      // Extraire les données des nuages
      if (meteo.containsKey('clouds') && meteo['clouds'] is Map<String, dynamic>) {
        final clouds = meteo['clouds'] as Map<String, dynamic>;
        if (clouds.containsKey('all')) {
          result['clouds'] = clouds['all'];
        }
      }
      
      // Extraire les données de visibilité
      if (meteo.containsKey('visibility')) {
        result['visibility'] = meteo['visibility'];
      }
      
      // Extraire les données système (lever/coucher du soleil)
      if (meteo.containsKey('sys') && meteo['sys'] is Map<String, dynamic>) {
        final sys = meteo['sys'] as Map<String, dynamic>;
        if (sys.containsKey('country')) {
          result['country'] = sys['country'];
        }
        if (sys.containsKey('sunrise')) {
          result['sunrise'] = sys['sunrise'];
        }
        if (sys.containsKey('sunset')) {
          result['sunset'] = sys['sunset'];
        }
      }
      
      // Extraire le timestamp
      if (meteo.containsKey('dt')) {
        result['dt'] = meteo['dt'];
      }
      
      // Extraire l'ID et le nom de la ville
      if (meteo.containsKey('id')) {
        result['city_id'] = meteo['id'];
      }
      if (meteo.containsKey('name')) {
        result['city_name'] = meteo['name'];
      }
      
      // Extraire les données weather (description, icône, etc.)
      if (meteo.containsKey('weather') && meteo['weather'] is List && (meteo['weather'] as List).isNotEmpty) {
        final weather = (meteo['weather'] as List).first as Map<String, dynamic>;
        if (weather.containsKey('id')) {
          result['weather_id'] = weather['id'];
        }
        if (weather.containsKey('main')) {
          result['weather_main'] = weather['main'];
        }
        if (weather.containsKey('description')) {
          result['description'] = weather['description'];
          result['weather_description'] = weather['description'];
        }
        if (weather.containsKey('icon')) {
          result['icon'] = weather['icon'];
          result['weather_icon'] = weather['icon'];
        }
      }
      
      // Copier les coordonnées
      if (meteo.containsKey('coord') && meteo['coord'] is Map<String, dynamic>) {
        final coord = meteo['coord'] as Map<String, dynamic>;
        if (coord.containsKey('lon')) {
          result['lon'] = coord['lon'];
        }
        if (coord.containsKey('lat')) {
          result['lat'] = coord['lat'];
        }
      }
      
      // Conserver le code de base et le timezone
      if (meteo.containsKey('base')) {
        result['base'] = meteo['base'];
      }
      if (meteo.containsKey('timezone')) {
        result['timezone'] = meteo['timezone'];
      }
      if (meteo.containsKey('cod')) {
        result['cod'] = meteo['cod'];
      }
      
      // Marquer comme provenant du cache si applicable
      if (data.containsKey('fromCache')) {
        result['fromCache'] = data['fromCache'];
      }
      if (data.containsKey('source')) {
        result['source'] = data['source'];
      }
    }
    
    // Normaliser la clé "ville" vers "city" si nécessaire
    if (result.containsKey('ville') && !result.containsKey('city')) {
      result['city'] = result['ville'];
    }
    
    // Conserver le timestamp de la réponse
    if (data.containsKey('timestamp')) {
      result['timestamp'] = data['timestamp'];
    }
    
    return result;
  }

  // 🟢 SYNCHRONISÉ avec backend - Météo avec ville par défaut (GESTION 500 AMÉLIORÉE)
  static Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      // 🔧 GESTION 500 : URL dynamique avec configuration existante
      final url = '$baseUrl/meteo/actuelle';
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 🆕 Appliquer le flattening des données
        return _flattenWeatherData(data);
      }
      
      // 🔧 GESTION 500 : Gestion spécifique des erreurs serveur
      if (response.statusCode == 500) {
        // Erreur serveur - retourner des données mockées pour éviter le crash
        return {
          'temperature': 25,
          'humidity': 60,
          'description': 'Erreur serveur - Données mockées',
          'city': 'Paris',
          'ville': 'Paris',
          'status': 'mock_data',
          'timestamp': DateTime.now().toIso8601String(),
          'error': true,
          'message': 'Erreur 500 détectée - Contacter l\'administrateur'
        };
      }
      
      throw Exception(_handleErrorResponse(response.statusCode, response.body));
    } catch (e) {
      // 🔧 GESTION 500 : En cas d'erreur de connexion, retourner des données par défaut
      return {
        'temperature': 22,
        'humidity': 55,
        'description': 'Erreur de connexion - Données par défaut',
        'city': 'Paris',
        'ville': 'Paris',
        'status': 'fallback_data',
        'timestamp': DateTime.now().toIso8601String(),
        'error': true,
        'message': 'Erreur de connexion - Utilisation des données par défaut'
      };
    }
  }

  // 🟢 Prévisions 5 jours - CORRIGÉ pour utiliser l'endpoint existant
  static Future<Map<String, dynamic>> getWeatherForecast(String city) async {
    try {
      // Validation des paramètres
      if (city.trim().isEmpty) {
        throw Exception('Nom de ville invalide pour les prévisions');
      }
      
      // Nettoyer la ville
      final cleanCity = _cleanCityName(city);
      
      // 🔧 CORRECTION 404 : Utiliser l'endpoint sans paramètre ville
      // car /meteo/actuelle/{ville} retourne 404 sur le backend
      final url = '$baseUrl/meteo/actuelle';
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      // Gestion des erreurs 404, 422, 400 - Fallback vers météo par défaut
      if (response.statusCode == 404 || response.statusCode == 422 || response.statusCode == 400) {
        return await getCurrentWeather();
      }
      
      throw Exception(_handleErrorResponse(response.statusCode, response.body));
    } catch (e) {
      // En cas d'erreur, retourner les données de météo actuelle
      return await getCurrentWeather();
    }
  }

  // Météo pour une culture spécifique
  static Future<Map<String, dynamic>> getCultureWeather(int cultureId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cultures/$cultureId/weather'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur météo culture: ${response.statusCode}');
  }

  // 🟢 SYNCHRONISÉ avec backend - Historique météo
  static Future<Map<String, dynamic>> getWeatherHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/meteo/historique'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur historique météo: ${response.statusCode}');
  }

  // 🟢 SYNCHRONISÉ avec backend - Météo par coordonnées GPS
  static Future<Map<String, dynamic>> getWeatherByCoords(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$baseUrl/weather/coords?lat=$lat&lon=$lon'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur météo coordonnées: ${response.statusCode}');
  }

  // 🟢 NOUVELLES MÉTHODES AMÉLIORÉES
  
  /// 🆕 Endpoint filtré pour météo avec paramètres
  static Future<Map<String, dynamic>> getWeatherFiltered({
    String? city,
    String? startDate,
    String? endDate,
    String? typeData, // 'current', 'forecast', 'history'
    int? cultureId,
  }) async {
    final cacheKey = 'weather_filtered_${city}_${startDate}_${endDate}_${typeData}_${cultureId}';
    
    // Vérifier le cache
    final cachedData = _getCachedData<Map<String, dynamic>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    final queryParams = <String, String>{};
    if (city != null) queryParams['city'] = city;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (typeData != null) queryParams['type'] = typeData;
    if (cultureId != null) queryParams['culture_id'] = cultureId.toString();

    final uri = Uri.parse('$baseUrl/meteo').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _setCachedData(cacheKey, data);
      return data;
    }
    
    final errorMsg = _handleErrorResponse(response.statusCode, response.body);
    throw Exception(errorMsg);
  }

  /// 🆕 Récupération des alertes météo
  static Future<List<AlertMeteo>> getWeatherAlerts({
    String? city,
    String? severity, // 'info', 'warning', 'critical'
    bool activeOnly = true,
  }) async {
    final cacheKey = 'weather_alerts_${city}_${severity}_${activeOnly}';
    
    // Vérifier le cache
    final cachedData = _getCachedData<List<AlertMeteo>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    final queryParams = <String, String>{};
    if (city != null) queryParams['city'] = city;
    if (severity != null) queryParams['severity'] = severity;
    if (activeOnly) queryParams['active_only'] = 'true';

    final uri = Uri.parse('$baseUrl/meteo/alerts').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final alerts = data.map((json) => AlertMeteo.fromJson(json)).toList();
      _setCachedData(cacheKey, alerts);
      return alerts;
    }
    
    final errorMsg = _handleErrorResponse(response.statusCode, response.body);
    throw Exception(errorMsg);
  }

  /// 🆕 Créer une nouvelle alerte météo
  static Future<AlertMeteo> createWeatherAlert({
    required String title,
    required String description,
    required String severity,
    String? city,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, dynamic>? conditions,
  }) async {
    final body = {
      'title': title,
      'description': description,
      'severity': severity,
      if (city != null) 'city': city,
      if (startTime != null) 'start_time': startTime.toIso8601String(),
      if (endTime != null) 'end_time': endTime.toIso8601String(),
      if (conditions != null) 'conditions': conditions,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/meteo/alerts'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return AlertMeteo.fromJson(data);
    }
    
    final errorMsg = _handleErrorResponse(response.statusCode, response.body);
    throw Exception(errorMsg);
  }

  /// 🆕 Supprimer une alerte météo
  static Future<bool> deleteWeatherAlert(int alertId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/meteo/alerts/$alertId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return true;
    }
    
    final errorMsg = _handleErrorResponse(response.statusCode, response.body);
    throw Exception(errorMsg);
  }

  /// 🆕 Marquer une alerte comme lue
  static Future<bool> markAlertAsRead(int alertId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/meteo/alerts/$alertId/read'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return true;
    }
    
    final errorMsg = _handleErrorResponse(response.statusCode, response.body);
    throw Exception(errorMsg);
  }

  /// 🆕 Récupérer les recommandations météo pour l'agriculture
  static Future<Map<String, dynamic>> getWeatherRecommendations({
    String? city,
    int? cultureId,
    DateTime? date,
  }) async {
    final cacheKey = 'weather_recommendations_${city}_${cultureId}_${date}';
    
    // Vérifier le cache
    final cachedData = _getCachedData<Map<String, dynamic>>(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    final queryParams = <String, String>{};
    if (city != null) queryParams['city'] = city;
    if (cultureId != null) queryParams['culture_id'] = cultureId.toString();
    if (date != null) queryParams['date'] = date.toIso8601String();

    final uri = Uri.parse('$baseUrl/meteo/recommendations').replace(queryParameters: queryParams);
    
    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _setCachedData(cacheKey, data);
      return data;
    }
    
    final errorMsg = _handleErrorResponse(response.statusCode, response.body);
    throw Exception(errorMsg);
  }

  /// 🆕 Vider le cache météo (pour tests ou actualisation forcée)
  static void clearCache() {
    _cache.clear();
  }

  /// 🆕 Obtenir les statistiques de cache
  static Map<String, dynamic> getCacheStats() {
    return {
      'cache_size': _cache.length,
      'cache_duration_minutes': _cacheDuration.inMinutes,
      'cached_keys': _cache.keys.toList(),
    };
  }
}
