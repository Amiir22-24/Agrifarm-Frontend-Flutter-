// lib/providers/weather_provider.dart
// Provider météorologique unifié - Consolidé

import 'package:flutter/material.dart';
import '../services/meteo_service.dart';
import '../models/meteo.dart';
import '../models/alert_meteo.dart';
import '../models/weather_forecast.dart';
import '../utils/weather_helper.dart';

// Réexporter pour compatibilité
export '../utils/weather_helper.dart' show WorkConditionsEvaluation;

class WeatherProvider with ChangeNotifier {
  // ========== ÉTAT ==========
  Map<String, dynamic>? _currentWeather;
  Map<String, dynamic>? _forecast;
  WeatherForecast? _weatherForecast;
  List<Meteo> _meteoHistory = [];
  List<AlertMeteo> _alerts = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  String _currentCity = 'Paris';

  // ========== CONSTRUCTEUR ==========
  WeatherProvider() {
    _initialize();
  }

  void _initialize() {
    // Pas d'appel API automatique pour éviter les erreurs au démarrage
    _currentWeather = null;
    _forecast = null;
    _weatherForecast = null;
    _alerts = [];
    _isLoading = false;
    _error = null;
  }

  // ========== GETTERS ==========
  Map<String, dynamic>? get currentWeather => _currentWeather;
  Map<String, dynamic>? get forecast => _forecast;
  WeatherForecast? get weatherForecast => _weatherForecast;
  List<Meteo> get meteoHistory => _meteoHistory;
  List<AlertMeteo> get alerts => _alerts;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  String get currentCity => _currentCity;

  // Données dérivées
  double? get temperature => _currentWeather?['temperature']?.toDouble();
  int? get humidity => _currentWeather?['humidity'];
  String? get description => _currentWeather?['description'];
  String? get icon => _currentWeather?['icon'];
  String? get city => _currentWeather?['city'] ?? _currentWeather?['ville'];

  // Données formatées
  String get temperatureFormatted =>
      _currentWeather != null ? '${(_currentWeather!['temperature'] ?? 0).round()}°C' : '--°C';

  String get humidityFormatted =>
      _currentWeather != null ? '${_currentWeather!['humidity'] ?? 0}%' : '--%';

  String get weatherDescription =>
      _currentWeather?['description'] ?? 'Données météo indisponibles';

  String get windSpeedFormatted =>
      _currentWeather != null ? '${_currentWeather!['wind_speed'] ?? 0} km/h' : '-- km/h';

  bool get hasWeatherData => _currentWeather != null;
  bool get hasForecast => _forecast != null && _forecast!.isNotEmpty;
  bool get hasWeatherForecast => _weatherForecast != null && _weatherForecast!.daily.isNotEmpty;
  bool get hasAlerts => _alerts.any((a) => a.isActive);
  bool get isEmpty => !hasWeatherData && !hasForecast;

  // Évaluation des conditions de travail
  WorkConditionsEvaluation get workConditions {
    if (_currentWeather == null) {
      return WorkConditionsEvaluation(
        score: 0,
        isGood: false,
        isAcceptable: false,
        reasons: ['Aucune donnée météo'],
      );
    }
    return WeatherHelper.evaluateWorkConditions(_currentWeather!);
  }

  // Conseil agricole
  String get agriculturalAdvice {
    if (_currentWeather == null) return 'Aucune donnée disponible';
    return WeatherHelper.getAgriculturalAdvice(_currentWeather!);
  }

  // ========== MÉTHODES DE CHARGEMENT ==========

  /// Charger la météo avec la ville de l'utilisateur ou par défaut
  Future<void> loadWeather({String? userWeatherCity}) async {
    final targetCity = userWeatherCity ?? _currentCity;

    if (!WeatherHelper.isValidCity(targetCity)) {
      _setError('Nom de ville invalide: ${targetCity.isEmpty ? "vide" : "caractères invalides"}');
      return;
    }

    await _loadCurrentWeather(targetCity);
  }

  /// Charger la météo actuelle
  Future<void> _loadCurrentWeather(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentWeather = await MeteoService.getWeatherByCity(city);
      _currentCity = city;
      _error = null;
    } catch (e) {
      _handleError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger les prévisions
  Future<void> loadForecast({String? city, String? userWeatherCity}) async {
    final targetCity = city ?? userWeatherCity ?? _currentCity;

    if (!WeatherHelper.isValidCity(targetCity)) {
      _setError('Nom de ville invalide pour les prévisions');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final forecastData = await MeteoService.getWeatherForecast(targetCity);
      _forecast = forecastData;
      _weatherForecast = WeatherForecast.fromJson(forecastData);
      _error = null;
    } catch (e) {
      _handleError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger l'historique météo
  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final historyData = await MeteoService.getWeatherHistory();
      if (historyData['history'] != null) {
        _meteoHistory = (historyData['history'] as List)
            .map((json) => Meteo.fromJson(json))
            .toList();
      }
    } catch (e) {
      _handleError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger les alertes météo
  Future<void> loadAlerts({String? city}) async {
    try {
      // NOTE: L'endpoint /meteo/alerts peut ne pas être implémenté sur le backend
      // On utilise un try-catch pour éviter de faire planter l'application
      final alertsData = await MeteoService.getWeatherAlerts(city: city ?? _currentCity);
      _alerts = alertsData;
      notifyListeners();
    } catch (e) {
      // Les erreurs d'alertes ne sont pas critiques
      // Onsilence l'erreur car l'endpoint /meteo/alerts n'existe peut-être pas
      _alerts = []; // Liste vide comme fallback
      notifyListeners();
    }
  }

  /// Charger toutes les données météo
  Future<void> loadAllData({String? city, String? userWeatherCity}) async {
    final targetCity = city ?? userWeatherCity ?? _currentCity;

    await Future.wait([
      loadWeather(userWeatherCity: targetCity),
      loadForecast(city: targetCity, userWeatherCity: targetCity),
      loadAlerts(city: targetCity),
    ]);
  }

  /// Actualiser toutes les données
  Future<void> refresh({String? city, String? userWeatherCity}) async {
    _isRefreshing = true;
    notifyListeners();

    try {
      await loadAllData(city: city, userWeatherCity: userWeatherCity);
      MeteoService.clearCache();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Changer de ville
  Future<void> changeCity(String newCity) async {
    final cleanCity = WeatherHelper.cleanCityName(newCity);

    if (cleanCity.isEmpty || cleanCity == _currentCity) return;
    if (!WeatherHelper.isValidCity(cleanCity)) {
      _setError('Nom de ville invalide');
      return;
    }

    await refresh(city: cleanCity);
  }

  /// Définir la ville par défaut
  void setDefaultCity(String city) {
    if (city.isNotEmpty && city != _currentCity) {
      _currentCity = city;
      notifyListeners();
    }
  }

  // ========== GESTION DES ERREURS ==========

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _handleError(String error) {
    _error = _formatWeatherError(error);

    // En cas d'erreur critique, essayer de fournir des données par défaut
    if (_currentWeather == null) {
      _currentWeather = _getDefaultWeatherData();
    }
  }

  String _formatWeatherError(String error) {
    if (error.contains('422')) {
      return 'Données météo invalides. Vérifiez le nom de la ville.';
    } else if (error.contains('400')) {
      return 'Requête météo invalide.';
    } else if (error.contains('404')) {
      return 'Ville non trouvée.';
    } else if (error.contains('401')) {
      return 'Authentification requise pour la météo.';
    } else if (error.contains('500')) {
      return 'Erreur serveur météo. Réessayez plus tard.';
    } else if (error.contains('timeout') || error.contains('SocketException')) {
      return 'Connexion perdue. Vérifiez votre réseau.';
    }

    return 'Impossible de charger les données météo.';
  }

  Map<String, dynamic> _getDefaultWeatherData() {
    return {
      'temperature': 22,
      'humidity': 55,
      'description': 'Données par défaut',
      'city': _currentCity,
      'status': 'fallback_data',
      'timestamp': DateTime.now().toIso8601String(),
      'error': true,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ========== RESET ==========

  void reset() {
    _currentWeather = null;
    _forecast = null;
    _weatherForecast = null;
    _meteoHistory = [];
    _alerts = [];
    _error = null;
    _currentCity = 'Paris';
    notifyListeners();
  }

  // ========== VALIDATION ==========

  bool isValidCity(String city) {
    return WeatherHelper.isValidCity(city);
  }

  // ========== CACHE ==========

  Map<String, dynamic> getCacheStats() {
    return MeteoService.getCacheStats();
  }

  void clearCache() {
    MeteoService.clearCache();
  }

  // ========== MÉTHODES DE COMPATIBILITÉ ==========

  /// Alias pour loadWeather - Compatibilité avec l'ancien code
  Future<void> loadCurrentWeather({String? city, String? userWeatherCity}) async {
    final targetCity = city ?? userWeatherCity ?? _currentCity;
    await loadWeather(userWeatherCity: targetCity);
  }

  /// Charger la météo par défaut - Compatibilité avec l'ancien code
  Future<void> loadDefaultWeather({String? userWeatherCity}) async {
    await loadAllData(userWeatherCity: userWeatherCity);
  }
}

