// lib/utils/weather_helper.dart
// Fonctions utilitaires pour la gestion de la météo

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherHelper {
  // ========== CONVERSION DE TEMPÉRATURE ==========

  /// Convertir Kelvin vers Celsius
  static double kelvinToCelsius(double kelvin) => kelvin - 273.15;

  /// Convertir Celsius vers Fahrenheit
  static double celsiusToFahrenheit(double celsius) => (celsius * 9 / 5) + 32;

  /// Formater la température avec symbole
  static String formatTemperature(
    double? temp, {
    bool useSymbol = true,
    bool useFahrenheit = false,
    int decimals = 0,
  }) {
    if (temp == null) return '--';
    
    double displayTemp;
    if (temp > 200) {
      // Probablement en Kelvin
      displayTemp = kelvinToCelsius(temp);
    } else {
      displayTemp = temp;
    }

    if (useFahrenheit) {
      displayTemp = celsiusToFahrenheit(displayTemp);
    }

    final formatted = decimals == 0 
        ? displayTemp.round().toString()
        : displayTemp.toStringAsFixed(decimals);
    
    return '$formatted${useSymbol ? '°C' : ''}';
  }

  /// Obtenir la température ressentie formatée
  static String formatFeelsLike(double? temp) {
    if (temp == null) return '--';
    return '${formatTemperature(temp)} (ressenti)';
  }

  // ========== ICÔNES ET CONDITIONS MÉTÉO ==========

  /// Obtenir l'icône Flutter selon la description
  static IconData getWeatherIcon(String? description) {
    if (description == null) return Icons.wb_sunny;
    
    final desc = description.toLowerCase();
    
    if (desc.contains('rain') || desc.contains('pluie') || desc.contains('pluvial')) {
      return Icons.water_drop;
    }
    if (desc.contains('drizzle') || desc.contains('bruine')) {
      return Icons.grain;
    }
    if (desc.contains('cloud') || desc.contains('nuage') || desc.contains('couvert')) {
      return Icons.cloud;
    }
    if (desc.contains('clear') || desc.contains('dégagé') || desc.contains('ensoleillé')) {
      return Icons.wb_sunny;
    }
    if (desc.contains('snow') || desc.contains('neige')) {
      return Icons.ac_unit;
    }
    if (desc.contains('storm') || desc.contains('orage') || desc.contains('thunder')) {
      return Icons.flash_on;
    }
    if (desc.contains('fog') || desc.contains('brouillard') || desc.contains('brume')) {
      return Icons.cloud;
    }
    if (desc.contains('wind') || desc.contains('vent')) {
      return Icons.air;
    }
    if (desc.contains('hail') || desc.contains('grêle')) {
      return Icons.ac_unit;
    }
    
    return Icons.wb_sunny;
  }

  /// Obtenir l'URL de l'icône OpenWeatherMap
  static String? getIconUrl(String? iconCode, {double size = 2}) {
    if (iconCode == null) return null;
    final sizeStr = size == 1 ? '' : '@${size}x';
    return 'https://openweathermap.org/img/wn/$iconCode$sizeStr.png';
  }

  /// Obtenir l'emoji unicode selon la description
  static String getWeatherEmoji(String? description) {
    if (description == null) return '☀️';
    
    final desc = description.toLowerCase();
    
    if (desc.contains('rain') || desc.contains('pluie')) return '🌧️';
    if (desc.contains('drizzle') || desc.contains('bruine')) return '🌦️';
    if (desc.contains('cloud') || desc.contains('nuage')) return '☁️';
    if (desc.contains('clear') || desc.contains('dégagé')) return '☀️';
    if (desc.contains('snow') || desc.contains('neige')) return '❄️';
    if (desc.contains('storm') || desc.contains('orage')) return '⛈️';
    if (desc.contains('fog') || desc.contains('brouillard')) return '🌫️';
    if (desc.contains('wind') || desc.contains('vent')) return '💨';
    
    return '🌤️';
  }

  // ========== CONSEILS AGRICOLES ==========

  /// Obtenir un conseil agricole selon les conditions météo
  static String getAgriculturalAdvice(Map<String, dynamic> weather) {
    final temp = weather['temperature'] ?? 0;
    final humidity = weather['humidity'] ?? 0;
    final rain = weather['rain_1h'] ?? weather['rain'] ?? 0;
    final windSpeed = weather['wind_speed'] ?? 0;
    final description = (weather['description'] ?? '').toLowerCase();

    // Conseils par condition
    if (rain > 10) {
      return '🌧️ Forte pluie attendue. Évitez les traitements phytosanitaires. Surveillez le drainage des parcelles.';
    } else if (rain > 5 || description.contains('pluie')) {
      return '🌦️ Précipitations modérées. Attendez avant d\'irriguer. Conditions défavorables pour les traitements.';
    } else if (temp < 0) {
      return '❄️ Gelées détectées. Protégez les cultures sensibles au froid. Envisagez le chauffage d\'appoint.';
    } else if (temp < 5) {
      return '🥶 Température basse. Ralentissement de la croissance. Surveillez les cultures fragiles.';
    } else if (temp > 35) {
      return '🔥 Canicule! Arrosez tôt le matin ou en fin de journée. Ombrez les jeunes plants.';
    } else if (temp > 30) {
      return '☀️ Chaleur intense. Maintenez l\'irrigation. Favorisez les travaux tôt le matin.';
    } else if (humidity > 85) {
      return '💧 Humidité très élevée (>85%). Risque accru de maladies fongiques. Surveillez attentivement.';
    } else if (humidity > 70) {
      return '💦 Humidité élevée. Conditions propices aux maladies. Évitez les blessures sur les plantes.';
    } else if (windSpeed > 40) {
      return '💨 Vent fort (>40 km/h). Attendez pour les pulvérisations. Fixez les structures.';
    } else if (windSpeed > 25) {
      return '🌬️ Vent modéré (>25 km/h). Prudence avec les traitements. Le vent peut dériver les produits.';
    }

    // Conseils généraux par température
    if (temp >= 15 && temp <= 25 && humidity >= 40 && humidity <= 70) {
      return '✅ Conditions idéales pour la plupart des travaux agricoles et les traitements.';
    } else if (temp >= 20 && temp <= 28) {
      return '🌱 Conditions favorables à la croissance. Bonne période pour les semis et transplantations.';
    }

    return '✅ Conditions généralement acceptables pour les travaux agricoles.';
  }

  /// Obtenir une couleur selon la qualité des conditions agricoles
  static Color getAgriculturalConditionColor(Map<String, dynamic> weather) {
    final temp = weather['temperature'] ?? 20;
    final humidity = weather['humidity'] ?? 50;
    final rain = weather['rain_1h'] ?? 0;

    // Conditions défavorables
    if (rain > 10 || temp < 0 || temp > 35 || humidity > 90) {
      return Colors.red;
    }
    
    // Conditions moyennes
    if (rain > 5 || temp < 10 || temp > 30 || humidity > 75 || humidity < 30) {
      return Colors.orange;
    }
    
    // Conditions favorables
    return Colors.green;
  }

  // ========== VALIDATION ==========

  /// Valider le nom d'une ville
  static bool isValidCity(String city) {
    final cleanCity = city.trim();
    if (cleanCity.isEmpty) return false;
    if (cleanCity.length < 2) return false;
    if (cleanCity.length > 50) return false;
    // Autoriser lettres, espaces, tirets, points et parenthèses
    return RegExp(r'^[a-zA-ZÀ-ÿ\s\-\.\(\)]+$').hasMatch(cleanCity);
  }

  /// Nettoyer le nom d'une ville
  static String cleanCityName(String city) {
    return city
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s\-\.\(\)]'), '')
        .trim();
  }

  // ========== FORMATAGE DE DATE ==========

  /// Formater une date pour l'affichage
  static String formatDate(DateTime? date, {String pattern = 'dd/MM'}) {
    if (date == null) return '--';
    return DateFormat(pattern, 'fr_FR').format(date);
  }

  /// Obtenir le nom du jour
  static String getDayName(DateTime date, {bool short = true}) {
    final frenchDays = short 
        ? ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim']
        : ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return frenchDays[date.weekday - 1];
  }

  /// Vérifier si c'est aujourd'hui
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Vérifier si c'est demain
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  /// Formater une heure
  static String formatHour(DateTime? date) {
    if (date == null) return '--';
    return DateFormat('HH:mm', 'fr_FR').format(date);
  }

  // ========== UNITÉS ==========

  /// Formater la vitesse du vent
  static String formatWindSpeed(double? speedKmh) {
    if (speedKmh == null) return '-- km/h';
    return '${speedKmh.toStringAsFixed(1)} km/h';
  }

  /// Formater l'humidité
  static String formatHumidity(int? humidity) {
    if (humidity == null) return '--%';
    return '$humidity%';
  }

  /// Formater la pression
  static String formatPressure(int? pressure) {
    if (pressure == null) return '-- hPa';
    return '$pressure hPa';
  }

  /// Formater la visibilité
  static String formatVisibility(int? visibilityMeters) {
    if (visibilityMeters == null) return '-- km';
    final km = visibilityMeters / 1000;
    if (km >= 10) return '>10 km';
    return '${km.toStringAsFixed(1)} km';
  }

  /// Formater les précipitations
  static String formatPrecipitation(double? mm) {
    if (mm == null || mm == 0) return '0 mm';
    return '${mm.toStringAsFixed(1)} mm';
  }

  // ========== ÉVALUATION DES CONDITIONS ==========

  /// Évaluer si les conditions sont bonnes pour les travaux agricoles
  static WorkConditionsEvaluation evaluateWorkConditions(Map<String, dynamic> weather) {
    final temp = weather['temperature'] ?? 20;
    final humidity = weather['humidity'] ?? 50;
    final windSpeed = weather['wind_speed'] ?? 0;
    final rain = weather['rain_1h'] ?? 0;
    final description = (weather['description'] ?? '').toLowerCase();

    int score = 100;
    final reasons = <String>[];

    // Température
    if (temp < 5) {
      score -= 30;
      reasons.add('Température trop basse');
    } else if (temp < 10) {
      score -= 15;
      reasons.add('Température fraîche');
    } else if (temp > 35) {
      score -= 30;
      reasons.add('Chaleur extrême');
    } else if (temp > 30) {
      score -= 15;
      reasons.add('Chaleur élevée');
    }

    // Humidité
    if (humidity > 85) {
      score -= 20;
      reasons.add('Humidité trop élevée');
    } else if (humidity > 75) {
      score -= 10;
      reasons.add('Humidité élevée');
    } else if (humidity < 30) {
      score -= 15;
      reasons.add('Humidité trop basse');
    }

    // Vent
    if (windSpeed > 40) {
      score -= 25;
      reasons.add('Vent trop fort');
    } else if (windSpeed > 25) {
      score -= 10;
      reasons.add('Vent modéré');
    }

    // Pluie
    if (rain > 5 || description.contains('rain')) {
      score -= 30;
      reasons.add('Pluie en cours');
    } else if (rain > 0) {
      score -= 15;
      reasons.add('Pluie légère');
    }

    return WorkConditionsEvaluation(
      score: score.clamp(0, 100),
      isGood: score >= 70,
      isAcceptable: score >= 40,
      reasons: reasons,
    );
  }

  // ========== COULEURS ==========

  /// Obtenir une couleur selon le niveau d'alerte
  static Color getAlertColor(String niveau) {
    switch (niveau) {
      case 'info': return Colors.blue;
      case 'warning': return Colors.orange;
      case 'critical': return Colors.red;
      default: return Colors.grey;
    }
  }

  /// Obtenir une couleur selon la température
  static Color getTempColor(double temp) {
    if (temp < 5) return Colors.blue[700]!;
    if (temp < 15) return Colors.blue;
    if (temp < 25) return Colors.green;
    if (temp < 30) return Colors.orange;
    return Colors.red;
  }

  /// Obtenir une couleur selon l'humidité
  static Color getHumidityColor(int humidity) {
    if (humidity < 30) return Colors.orange;
    if (humidity > 80) return Colors.blue[700]!;
    return Colors.blue;
  }
}

/// Classe d'évaluation des conditions de travail
class WorkConditionsEvaluation {
  final int score;
  final bool isGood;
  final bool isAcceptable;
  final List<String> reasons;

  WorkConditionsEvaluation({
    required this.score,
    required this.isGood,
    required this.isAcceptable,
    required this.reasons,
  });

  String get summary {
    if (isGood) return 'Conditions favorables';
    if (isAcceptable) return 'Conditions acceptables avec precautions';
    return 'Conditions défavorables';
  }
}

