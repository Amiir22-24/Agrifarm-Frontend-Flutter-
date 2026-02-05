# TODO - Correction de l'affichage de la météo de la ville de l'utilisateur

## Problèmes identifiés:

1. **home_screen.dart**: Affiche une carte météo statique au lieu d'utiliser `WeatherCard`
2. **weather_card.dart**: Propriété incorrecte pour accéder à la ville de l'utilisateur
3. **profile_service.dart**: URL hardcodée au lieu d'utiliser `AppConfig.baseApiUrl`

## Corrections à faire:

### 1. home_screen.dart
- [ ] Remplacer `_buildWeatherCard()` par une vraie carte météo
- [ ] Charger les données météo dans `_loadAllData()`
- [ ] Importer `WeatherProvider` si nécessaire

### 2. weather_card.dart
- [ ] Corriger `authProvider.user?.defaultWeatherCity` → `authProvider.user?.profile?.defaultWeatherCity`

### 3. profile_service.dart
- [ ] Remplacer URL hardcodée par `AppConfig.baseApiUrl`
- [ ] Ajouter l'import de `config.dart`

