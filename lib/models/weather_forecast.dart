// lib/models/weather_forecast.dart
// Modèle de données pour les prévisions météo

class WeatherForecast {
  final String? city;
  final List<DailyForecast> daily;
  final Map<String, dynamic>? rawData;

  WeatherForecast({
    this.city,
    this.daily = const [],
    this.rawData,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      city: json['city'] ?? json['name'],
      daily: json['daily'] != null
          ? (json['daily'] as List)
              .map((d) => DailyForecast.fromJson(d))
              .toList()
          : _parseDailyFromList(json),
      rawData: json,
    );
  }

  // Parser alternatif pour les réponses API au format liste
  static List<DailyForecast> _parseDailyFromList(Map<String, dynamic> json) {
    if (json['list'] != null) {
      return (json['list'] as List)
          .map((item) => DailyForecast.fromJson(item))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      if (city != null) 'city': city,
      'daily': daily.map((d) => d.toJson()).toList(),
      if (rawData != null) 'raw_data': rawData,
    };
  }

  // Obtenir les prévisions pour les N prochains jours
  List<DailyForecast> getNextDays(int count) {
    return daily.take(count).toList();
  }

  // Obtenir la température maximale moyenne
  double? getAverageMaxTemp() {
    if (daily.isEmpty) return null;
    final temps = daily.where((d) => d.tempMax != null).map((d) => d.tempMax!);
    if (temps.isEmpty) return null;
    return temps.reduce((a, b) => a + b) / temps.length;
  }

  // Obtenir la température minimale moyenne
  double? getAverageMinTemp() {
    if (daily.isEmpty) return null;
    final temps = daily.where((d) => d.tempMin != null).map((d) => d.tempMin!);
    if (temps.isEmpty) return null;
    return temps.reduce((a, b) => a + b) / temps.length;
  }

  // Vérifier s'il y a de la pluie dans les prévisions
  bool hasRainInForecast() {
    return daily.any((d) => (d.precipProb ?? 0) > 0 || d.description?.toLowerCase().contains('rain') == true);
  }

  // Nombre de jours avec pluie
  int getRainyDaysCount() {
    return daily.where((d) => (d.precipProb ?? 0) > 0).length;
  }
}

class DailyForecast {
  final DateTime date;
  final double? tempMin;
  final double? tempMax;
  final double? tempMorn;
  final double? tempDay;
  final double? tempEve;
  final double? tempNight;
  final String? description;
  final String? mainWeather;
  final String? icon;
  final int? humidity;
  final double? precipProb;
  final double? windSpeed;
  final int? pressure;

  DailyForecast({
    required this.date,
    this.tempMin,
    this.tempMax,
    this.tempMorn,
    this.tempDay,
    this.tempEve,
    this.tempNight,
    this.description,
    this.mainWeather,
    this.icon,
    this.humidity,
    this.precipProb,
    this.windSpeed,
    this.pressure,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      tempMin: json['temp']?['min']?.toDouble() ?? json['temp_min']?.toDouble(),
      tempMax: json['temp']?['max']?.toDouble() ?? json['temp_max']?.toDouble(),
      tempMorn: json['temp']?['morn']?.toDouble(),
      tempDay: json['temp']?['day']?.toDouble(),
      tempEve: json['temp']?['eve']?.toDouble(),
      tempNight: json['temp']?['night']?.toDouble(),
      description: json['weather']?[0]?['description'] ?? json['description'],
      mainWeather: json['weather']?[0]?['main'] ?? json['main'],
      icon: json['weather']?[0]?['icon'] ?? json['icon'],
      humidity: json['humidity'],
      precipProb: json['pop'] != null ? (json['pop'] * 100).toInt() : json['precip_prob'],
      windSpeed: json['wind_speed']?.toDouble() ?? json['wind']?['speed']?.toDouble(),
      pressure: json['pressure'] ?? json['main']?['pressure'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': date.millisecondsSinceEpoch ~/ 1000,
      'temp': {
        if (tempMin != null) 'min': tempMin,
        if (tempMax != null) 'max': tempMax,
        if (tempMorn != null) 'morn': tempMorn,
        if (tempDay != null) 'day': tempDay,
        if (tempEve != null) 'eve': tempEve,
        if (tempNight != null) 'night': tempNight,
      },
      'weather': [
        {
          if (description != null) 'description': description,
          if (mainWeather != null) 'main': mainWeather,
          if (icon != null) 'icon': icon,
        }
      ],
      if (humidity != null) 'humidity': humidity,
      if (precipProb != null) 'pop': precipProb! / 100,
      if (windSpeed != null) 'wind_speed': windSpeed,
      if (pressure != null) 'pressure': pressure,
    };
  }

  // Température moyenne de la journée
  double? get averageTemp {
    final temps = [tempMorn, tempDay, tempEve, tempNight].where((t) => t != null).map((t) => t!);
    if (temps.isEmpty) return null;
    return temps.reduce((a, b) => a + b) / temps.length;
  }

  // Amplitude thermique (différence entre max et min)
  double? get thermalAmplitude {
    if (tempMin == null || tempMax == null) return null;
    return tempMax! - tempMin!;
  }

  // Est-ce une journée pluvieuse ?
  bool get isRainy {
    return (precipProb ?? 0) > 30 || description?.toLowerCase().contains('rain') == true;
  }

  // Est-ce une journée ensoleillée ?
  bool get isSunny {
    return (precipProb ?? 0) < 20 && 
           (description?.toLowerCase().contains('clear') == true || 
            description?.toLowerCase().contains('sunny') == true);
  }
}

// Modèle pour les données horaires (utile pour les graphiques)
class HourlyForecast {
  final DateTime time;
  final double? temperature;
  final String? description;
  final String? icon;
  final double? precipProb;
  final double? windSpeed;

  HourlyForecast({
    required this.time,
    this.temperature,
    this.description,
    this.icon,
    this.precipProb,
    this.windSpeed,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      temperature: json['temp']?.toDouble(),
      description: json['weather']?[0]?['description'],
      icon: json['weather']?[0]?['icon'],
      precipProb: json['pop'] != null ? json['pop'] * 100 : null,
      windSpeed: json['wind_speed']?.toDouble(),
    );
  }
}

