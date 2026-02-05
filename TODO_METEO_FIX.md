# TODO - Correction Affichage Météo Utilisateur

## Problème
L'API retourne les données météorologiques avec une structure imbriquée (`meteo.temperature`, `meteo.humidity`), mais le widget attend des clés plates.

## Réponse API attendue
```json
{
    "ville": "Lomé",
    "meteo": {
        "coord": {...},
        "weather": [...],
        "main": {
            "temp": 30.2,
            "feels_like": 34.09,
            "humidity": 64,
            ...
        },
        ...
    }
}
```

## Tâches

### 1. Modifier meteo_service.dart
- [x] Ajouter une méthode `_flattenWeatherData()` pour transformer les données imbriquées
- [ ] Appliquer la transformation dans `getWeatherByCity()`

### 2. Modifier weather_provider.dart  
- [ ] Ajouter une méthode `_transformWeatherData()` pour normaliser les clés
- [ ] Utiliser les clés normalisées dans les getters

### 3. Modifier home_screen.dart
- [ ] Corriger `_buildWeatherCard()` pour utiliser les bons chemins de clés
- [ ] Gérer les clés `city`/`ville`, `temperature`/`temp`, etc.

### 4. Modifier weather_card.dart
- [ ] Adapter aux clés normalisées depuis le provider

## Clés à normaliser
| Clé API | Clé attendue |
|---------|-------------|
| `ville` | `city` |
| `meteo.main.temp` | `temperature` |
| `meteo.main.humidity` | `humidity` |
| `meteo.weather[0].description` | `description` |
| `meteo.weather[0].icon` | `icon` |
| `meteo.wind.speed` | `wind_speed` |

