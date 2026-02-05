# TODO - Correction HomeScreen pour Météo

## Étapes de correction

### Étape 1: Modifier `_loadAllData()`
- [ ] Remplacer l'appel à `_loadWeatherData()` par des appels directs à `fetchUserWeatherCity()` et `loadCurrentWeather()`

### Étape 2: Ajouter la méthode `_getTargetCity()`
- [ ] Créer une méthode d'aide pour centraliser la logique de détection de ville
- [ ] Priorité: profile.defaultWeatherCity > userWeatherCity > défaut (Paris)

### Étape 3: Simplifier `_buildWeatherCard()`
- [ ] Utiliser `_getTargetCity()` pour déterminer la ville cible
- [ ] Nettoyer la logique de chargement conditionnel

### Étape 4: Supprimer `_loadWeatherData()`
- [ ] Supprimer la méthode d'aide redondante

## Modifications à appliquer

### Fichier: `lib/screens/home_screen.dart`
- Méthode `_loadAllData()`: Intégrer directement le chargement météo
- Nouvelle méthode `_getTargetCity()`: Centraliser la détection de ville
- Méthode `_buildWeatherCard()`: Utiliser `_getTargetCity()`
- Supprimer la méthode `_loadWeatherData()`

