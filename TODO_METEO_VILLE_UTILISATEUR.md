# TODO - Correction Météo Ville Utilisateur

## Objectif
Faire en sorte que la météo de la ville de l'utilisateur s'affiche correctement sur l'écran d'accueil.

## Problèmes identifiés
1. La ville météo de l'utilisateur n'est jamais chargée au démarrage
2. Le WeatherProvider n'est pas initialisé avec la bonne ville
3. La logique de récupération de la ville dans le widget est incomplète

## Corrections à effectuer

### 1. home_screen.dart - Charger la ville météo et les données au démarrage
- [ ] Ajouter `fetchUserWeatherCity()` dans `_loadAllData()`
- [ ] Ajouter `loadCurrentWeather()` dans `_loadAllData()`
- [ ] Améliorer la logique de détection de la ville dans `_buildWeatherCard()`

### 2. user_provider.dart - Corriger fetchUserWeatherCity()
- [ ] Utiliser d'abord la ville du profil utilisateur si disponible
- [ ] Fallback vers l'endpoint API si pas de profil

### 3. Tests de vérification
- [ ] Vérifier que la ville est chargée au démarrage
- [ ] Vérifier que la météo s'affiche avec la bonne ville

## Notes
- L'URL API reste `localhost:8000/api` comme demandé

