// lib/utils/config.dart
// Configuration globale pour l'application AgriFarm

class AppConfig {
  // 🔧 CONFIGURATION MÉTÉO - URLs dynamiques
  static const String baseApiUrl = 'http://localhost:8000/api';
  
  // 🌍 ENVIRONNEMENTS
  static const String environment = 'development'; // development | staging | production
  
  // ⏱️ TIMEOUTS ET RETRY
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration retryDelay = Duration(seconds: 2);
  static const int maxRetryAttempts = 3;
  
  // 🌤️ MÉTÉO CONFIGURATION
  static const String defaultWeatherCity = 'Paris';
  static const Duration weatherCacheDuration = Duration(minutes: 5);
  
  // 📊 VALIDATION
  static const int minCityNameLength = 2;
  static const int maxCityNameLength = 50;
  
  // 🎯 CARACTÈRES AUTORISÉS POUR LES VILLES
  static RegExp get cityNameRegex => RegExp(r'^[a-zA-ZÀ-ÿ\s\-_\.\(\)]+$');
  
  // 📱 INTERFACE
  static const int animationDurationMs = 300;
  static const int listRefreshIntervalMs = 1000;
  
  // 🔧 UTILITAIRES
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  
  // 📍 ENDPOINTS MÉTÉO
  static String get weatherCityEndpoint => '$baseApiUrl/weather/city';
  static String get weatherForecastEndpoint => '$baseApiUrl/weather/forecast';
  static String get currentWeatherEndpoint => '$baseApiUrl/meteo/actuelle';
  static String get weatherHistoryEndpoint => '$baseApiUrl/meteo/historique';
  
  // 🌍 URLS COMPLÈTES POUR MÉTÉO
  static String buildWeatherCityUrl(String encodedCity) {
    return '$weatherCityEndpoint/$encodedCity';
  }
  
  static String buildWeatherForecastUrl(String encodedCity) {
    return '$weatherForecastEndpoint/$encodedCity';
  }
  
  static String buildDefaultWeatherForecastUrl() {
    return '$weatherForecastEndpoint/${Uri.encodeComponent(defaultWeatherCity)}';
  }
}
