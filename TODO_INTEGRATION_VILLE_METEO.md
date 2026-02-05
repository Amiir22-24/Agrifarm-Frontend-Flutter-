# TODO - Intégration Ville Météo Utilisateur

## Progression : 1/4 fichiers modifiés

### Fait ✅
- [x] 1. Modifier `lib/providers/user_provider.dart`

### À Faire 🔄
- [ ] 2. Modifier `lib/providers/weather_provider.dart`
- [ ] 3. Modifier `lib/screens/meteo_screen.dart`
- [ ] 4. Modifier `lib/screens/home_screen.dart`

---

## Détail des Tâches

### 1. Modifier UserProvider ✅ TERMINÉ
- [x] Ajouter propriété `_userWeatherCity`
- [x] Ajouter méthode `fetchUserWeatherCity()`
- [x] Ajouter méthode `updateUserWeatherCity(city)`
- [x] Mettre à jour `logout()` pour effacer la ville météo

### 2. Modifier WeatherProvider ⏳ EN COURS
- [ ] Modifier `loadCurrentWeather({String? city, String? userWeatherCity})`
- [ ] Modifier `loadForecast({String? city, String? userWeatherCity})`
- [ ] Ajouter `loadDefaultWeather({String? userWeatherCity})`

### 3. Modifier MeteoScreen ⏳
- [ ] Ajouter `_loadWeatherWithUserCity()`
- [ ] Appeler dans `initState()`
- [ ] Modifier `_loadWeatherData()` pour utiliser userWeatherCity

### 4. Modifier HomeScreen ⏳
- [ ] Appeler `fetchUserWeatherCity()` dans `_loadAllData()`
- [ ] Modifier `_buildWeatherCard()` pour utiliser les vrais données

---

## Notes de Progression

### Date: Fichier 1/4 terminé
- UserProvider modifié avec succès
- Ajout des méthodes pour la gestion de la ville météo
- Suite : WeatherProvider

