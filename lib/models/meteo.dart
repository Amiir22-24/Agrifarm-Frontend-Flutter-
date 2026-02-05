// lib/models/meteo.dart
class Meteo {
  final int? id;
  final int? userId;
  final double? lat;
  final double? lon;
  final DateTime date;
  final double? temperature;
  final int? humidite;
  final bool? pluie;
  final String? description;
  final double? windSpeed;
  final Map<String, dynamic>? rawData;

  Meteo({
    this.id,
    this.userId,
    this.lat,
    this.lon,
    required this.date,
    this.temperature,
    this.humidite,
    this.pluie,
    this.description,
    this.windSpeed,
    this.rawData,
  });

  factory Meteo.fromJson(Map<String, dynamic> json) {
    return Meteo(
      id: json['id'],
      userId: json['user_id'],
      lat: json['lat']?.toDouble(),
      lon: json['lon']?.toDouble(),
      date: DateTime.parse(json['date']),
      temperature: json['temperature']?.toDouble(),
      humidite: json['humidite'],
      pluie: json['pluie'] == 1 || json['pluie'] == true,
      description: json['description'],
      windSpeed: json['wind_speed']?.toDouble(),
      rawData: json['raw_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      'date': date.toIso8601String(),
      if (temperature != null) 'temperature': temperature,
      if (humidite != null) 'humidite': humidite,
      if (pluie != null) 'pluie': pluie,
      if (description != null) 'description': description,
      if (windSpeed != null) 'wind_speed': windSpeed,
    };
  }

  String get tempCelsius {
    if (temperature == null) return '--';
    // Si la température est en Kelvin (> 200), convertir
    if (temperature! > 200) {
      return (temperature! - 273.15).toStringAsFixed(1);
    }
    return temperature!.toStringAsFixed(1);
  }

  String get weatherIcon {
    if (description == null) return '☀️';
    final desc = description!.toLowerCase();
    if (desc.contains('rain') || desc.contains('pluie')) return '🌧️';
    if (desc.contains('cloud') || desc.contains('nuage')) return '☁️';
    if (desc.contains('clear') || desc.contains('dégagé')) return '☀️';
    if (desc.contains('snow') || desc.contains('neige')) return '❄️';
    if (desc.contains('storm') || desc.contains('orage')) return '⛈️';
    return '🌤️';
  }
}