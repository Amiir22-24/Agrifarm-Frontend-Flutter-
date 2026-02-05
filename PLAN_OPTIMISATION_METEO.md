# Plan d'Optimisation de la Section Météo

## Résumé des Modifications

| Action | Fichier | Description |
|--------|---------|-------------|
| **Consolider** | weather_provider.dart | Fusionner `meteo_provider.dart` et `weather_provider.dart` |
| **Créer** | weather_helper.dart | Fonctions utilitaires pour la météo |
| **Créer** | weather_icon_widget.dart | Widget d'icône météo avec OpenWeatherMap |
| **Créer** | weather_details_widget.dart | Widget détaillé pour la météo |
| **Créer** | weather_forecast_widget.dart | Widget de prévisions |
| **Créer** | weather_alert_widget.dart | Widget d'alertes météo |
| **Créer** | weather_forecast.dart | Modèle de prévisions |
| **Mettre à jour** | meteo_service.dart | Utiliser le provider unifié |

## Structure Optimisée

```
lib/
├── models/
│   ├── meteo.dart              # Données météo actuelles (EXISTANT)
│   ├── alert_meteo.dart        # Alerts météo (EXISTANT)
│   └── weather_forecast.dart   # Nouveau: Modèle prévisions
├── providers/
│   ├── weather_provider.dart   # Unifié (NOUVEAU)
│   └── (supprimer meteo_provider.dart)
├── services/
│   ├── meteo_service.dart      # Service météo (EXISTANT)
│   └── api_service.dart        # Service API (EXISTANT)
├── screens/
│   ├── meteo_screen.dart       # Écran principal (EXISTANT)
│   └── home_screen.dart        # Utilise WeatherCard
├── widgets/
│   ├── weather_card.dart       # Carte dashboard (EXISTANT)
│   ├── weather_icon_widget.dart      # Nouveau
│   ├── weather_details_widget.dart   # Nouveau
│   ├── weather_forecast_widget.dart  # Nouveau
│   └── weather_alert_widget.dart     # Nouveau
└── utils/
    ├── weather_helper.dart     # Nouveau
    └── config.dart             # Existant
```

## Détail des Modifications

### 1. weather_forecast.dart (Nouveau)

```dart
class WeatherForecast {
  final String? city;
  final List<DailyForecast> daily;
  final Map<String, dynamic>? rawData;
  
  WeatherForecast({this.city, this.daily = const [], this.rawData});
  
  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      city: json['city'] ?? json['name'],
      daily: json['daily'] != null 
          ? (json['daily'] as List).map((d) => DailyForecast.fromJson(d)).toList()
          : [],
      rawData: json,
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double? tempMin;
  final double? tempMax;
  final String? description;
  final String? icon;
  final int? humidity;
  final double? precipProb;
  
  DailyForecast({
    required this.date,
    this.tempMin,
    this.tempMax,
    this.description,
    this.icon,
    this.humidity,
    this.precipProb,
  });
  
  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      tempMin: json['temp']?['min']?.toDouble(),
      tempMax: json['temp']?['max']?.toDouble(),
      description: json['weather']?[0]?['description'],
      icon: json['weather']?[0]?['icon'],
      humidity: json['humidity'],
      precipProb: json['pop'] != null ? (json['pop'] * 100).toInt() : null,
    );
  }
}
```

### 2. weather_helper.dart (Nouveau)

```dart
import 'package:flutter/material.dart';

class WeatherHelper {
  // Conversion Kelvin vers Celsius
  static double kelvinToCelsius(double kelvin) => kelvin - 273.15;
  
  // Formater température
  static String formatTemperature(double? temp, {bool useSymbol = true}) {
    if (temp == null) return '--';
    final celsius = temp > 200 ? kelvinToCelsius(temp) : temp;
    return '${celsius.round()}${useSymbol ? '°C' : ''}';
  }
  
  // Obtenir icône selon description
  static IconData getWeatherIcon(String? description) {
    if (description == null) return Icons.wb_sunny;
    final desc = description.toLowerCase();
    if (desc.contains('rain') || desc.contains('pluie')) return Icons.water_drop;
    if (desc.contains('cloud') || desc.contains('nuage')) return Icons.cloud;
    if (desc.contains('clear') || desc.contains('dégagé')) return Icons.wb_sunny;
    if (desc.contains('snow') || desc.contains('neige')) return Icons.ac_unit;
    if (desc.contains('storm') || desc.contains('orage')) return Icons.flash_on;
    if (desc.contains('fog') || desc.contains('brouillard')) return Icons.cloud;
    if (desc.contains('wind') || desc.contains('vent')) return Icons.air;
    return Icons.wb_sunny;
  }
  
  // URL icône OpenWeatherMap
  static String? getIconUrl(String? iconCode) {
    if (iconCode == null) return null;
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
  
  // Message agricole selon météo
  static String getAgriculturalAdvice(Map<String, dynamic> weather) {
    final temp = weather['temperature'] ?? 0;
    final humidity = weather['humidity'] ?? 0;
    final rain = weather['rain_1h'] ?? 0;
    
    if (rain > 5) {
      return '🌧️ Attention aux maladies fongiques. Évitez les traitements.';
    } else if (temp < 5) {
      return '❄️ Risque de gel. Protégez les cultures sensibles.';
    } else if (humidity > 80) {
      return '💧 Humidité élevée - Surveillez les maladies.';
    } else if (temp > 30) {
      return '☀️ Chaleur intense - Arrosez tôt le matin ou le soir.';
    }
    return '✅ Conditions favorables pour les travaux agricoles.';
  }
  
  // Validateur de ville
  static bool isValidCity(String city) {
    final cleanCity = city.trim();
    if (cleanCity.isEmpty) return false;
    if (cleanCity.length < 2) return false;
    return RegExp(r'^[a-zA-ZÀ-ÿ\s\-\.\(\)]+$').hasMatch(cleanCity);
  }
}
```

### 3. weather_icon_widget.dart (Nouveau)

```dart
import 'package:flutter/material.dart';

class WeatherIconWidget extends StatelessWidget {
  final String? iconCode;
  final double size;
  final Color? color;
  
  const WeatherIconWidget({
    super.key,
    this.iconCode,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (iconCode == null) {
      return Icon(Icons.wb_cloudy, size: size, color: color);
    }
    
    final iconUrl = 'https://openweathermap.org/img/wn/$iconCode@2x.png';
    
    return Image.network(
      iconUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.wb_cloudy, size: size, color: color ?? Colors.grey);
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }
}
```

### 4. weather_details_widget.dart (Nouveau)

```dart
import 'package:flutter/material.dart';
import 'weather_icon_widget.dart';
import 'weather_helper.dart';

class WeatherDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> weather;
  final bool showHeader;
  
  const WeatherDetailsWidget({
    super.key,
    required this.weather,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              const Text(
                'Conditions Détaillées',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WeatherHelper.formatTemperature(weather['temperature']),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        weather['description'] ?? 'Aucune description',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ressenti: ${WeatherHelper.formatTemperature(weather['feels_like'])}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                WeatherIconWidget(
                  iconCode: weather['icon'],
                  size: 80,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsGrid() {
    final details = [
      ('Humidité', weather['humidity'], '%', Icons.water_drop),
      ('Vent', weather['wind_speed'], ' km/h', Icons.air),
      ('Pression', weather['pressure'], ' hPa', Icons.compress),
      ('Visibilité', weather['visibility'], ' km', Icons.visibility),
      ('Nuages', weather['clouds'], '%', Icons.cloud),
      ('Précipitations', weather['rain_1h'], ' mm/h', Icons.water_drop),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final (label, value, unit, icon) = details[index];
        return _buildDetailCard(
          icon: icon,
          label: label,
          value: '${value ?? '--'}$unit',
          color: _getColorForIndex(index),
        );
      },
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.blueGrey,
      Colors.purple,
      Colors.orange,
      Colors.grey,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}
```

### 5. weather_forecast_widget.dart (Nouveau)

```dart
import 'package:flutter/material.dart';
import 'weather_icon_widget.dart';
import 'weather_helper.dart';
import '../models/weather_forecast.dart';

class WeatherForecastWidget extends StatelessWidget {
  final WeatherForecast forecast;
  
  const WeatherForecastWidget({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    if (forecast.daily.isEmpty) {
      return _buildEmptyState();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Prévisions 5 Jours',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (forecast.city != null)
                  Text(
                    forecast.city!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.daily.length,
                itemBuilder: (context, index) {
                  return _buildForecastDay(forecast.daily[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastDay(DailyForecast day) {
    final dayName = _getDayName(day.date);
    
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          WeatherIconWidget(
            iconCode: day.icon,
            size: 40,
          ),
          const SizedBox(height: 8),
          if (day.tempMax != null)
            Text(
              '${day.tempMax!.round()}°',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (day.tempMin != null)
            Text(
              '${day.tempMin!.round()}°',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          const SizedBox(height: 4),
          if (day.description != null)
            Text(
              day.description!,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Prévisions non disponibles',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    if (date.day == now.day) return 'Aujourd\'hui';
    if (date.day == tomorrow.day) return 'Demain';
    
    final frenchDays = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dim'];
    return frenchDays[date.weekday - 1];
  }
}
```

### 6. weather_alert_widget.dart (Nouveau)

```dart
import 'package:flutter/material.dart';
import '../models/alert_meteo.dart';

class WeatherAlertWidget extends StatelessWidget {
  final List<AlertMeteo> alerts;
  
  const WeatherAlertWidget({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alertes Météo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...alerts.map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  Widget _buildAlertCard(AlertMeteo alert) {
    final bgColor = _getAlertBackgroundColor(alert.niveau);
    final borderColor = _getAlertBorderColor(alert.niveau);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert.icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      alert.typeDisplay,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    _buildBadge(alert.niveau),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  alert.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      alert.duree,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String niveau) {
    final color = _getAlertBorderColor(niveau);
    final text = niveau == 'info' ? 'Info' 
        : niveau == 'warning' ? 'Attention' 
        : 'Critique';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getAlertBackgroundColor(String niveau) {
    switch (niveau) {
      case 'info': return Colors.blue[400]!.withOpacity(0.9);
      case 'warning': return Colors.orange[400]!.withOpacity(0.9);
      case 'critical': return Colors.red[400]!.withOpacity(0.9);
      default: return Colors.grey[400]!.withOpacity(0.9);
    }
  }

  Color _getAlertBorderColor(String niveau) {
    switch (niveau) {
      case 'info': return Colors.blue[600]!;
      case 'warning': return Colors.orange[600]!;
      case 'critical': return Colors.red[600]!;
      default: return Colors.grey[600]!;
    }
  }
}
```

### 7. weather_provider.dart (Unifié - Version Finale)

Le nouveau provider unifie les fonctionnalités de `meteo_provider.dart` et `weather_provider.dart` avec :
- Gestion de la météo actuelle
- Gestion des prévisions
- Gestion des alertes
- Support de la ville utilisateur
- Gestion d'erreurs améliorée
- Cache des données

## Ordre de Priorité des Modifications

1. **Créer weather_forecast.dart** - Modèle de données
2. **Créer weather_helper.dart** - Utilitaires
3. **Créer weather_icon_widget.dart** - Widget icône
4. **Créer weather_details_widget.dart** - Widget détails
5. **Créer weather_forecast_widget.dart** - Widget prévisions
6. **Créer weather_alert_widget.dart** - Widget alertes
7. **Mettre à jour weather_provider.dart** - Consolider
8. **Supprimer meteo_provider.dart** - Nettoyer
9. **Mettre à jour meteo_screen.dart** - Utiliser nouveaux widgets
10. **Mettre à jour home_screen.dart** - Utiliser widgets optimisés

## Tests Recommandés

- [ ] Affichage des données météo actuelles
- [ ] Affichage des prévisions 5 jours
- [ ] Affichage des alertes météo
- [ ] Changement de ville
- [ ] Gestion des erreurs (422, 404, 500)
- [ ] Intégration avec le dashboard (home_screen.dart)
- [ ] Responsive design sur différentes tailles d'écran

---

**Créé le:** $(date +%Y-%m-%d)
**Statut:** En attente d'implémentation

