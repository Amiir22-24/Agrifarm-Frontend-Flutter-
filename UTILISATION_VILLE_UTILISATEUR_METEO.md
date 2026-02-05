# 🏠 Utilisation de la Ville Utilisateur en Météo

## ✅ Réponse à votre question

**OUI**, la ville enregistrée lors de l'inscription **est bien récupérée** et utilisée par la section météo !

## 🔧 Comment ça fonctionne

### 1. **Enregistrement de l'utilisateur**
Lors de l'inscription (`register_screen.dart`), l'utilisateur peut définir sa ville météo par défaut :
```dart
// Champ dans le formulaire d'inscription
TextFormField(
  controller: _defaultWeatherCityController,
  decoration: const InputDecoration(
    labelText: 'Ville pour la météo',
    hintText: 'Ex: Paris, Lyon, Marseille...',
  ),
),

// Sauvegardé en base avec la clé 'default_weather_city'
'default_weather_city': _defaultWeatherCityController.text.trim(),
```

### 2. **Stockage dans le profil utilisateur**
La ville est stockée dans le `UserProfile` avec le champ `defaultWeatherCity` :
```dart
class UserProfile {
  final String defaultWeatherCity; // Ville météo par défaut
  
  UserProfile({
    required this.defaultWeatherCity,
    // ... autres champs
  });
  
  // Getter pour récupérer facilement la ville
  String? get defaultWeatherCity => this.defaultWeatherCity;
}
```

### 3. **Récupération dans WeatherProvider**
Le `WeatherProvider` a été modifié pour accepter la ville utilisateur :
```dart
// Méthode mise à jour qui accepte la ville utilisateur
Future<void> loadCurrentWeather({String? city, String? userWeatherCity}) async {
  // Priorité : ville spécifique > ville utilisateur > ville par défaut
  final targetCity = city ?? userWeatherCity ?? _currentCity;
  
  if (city != null || userWeatherCity != null) {
    _currentWeather = await MeteoService.getWeatherByCity(targetCity);
  } else {
    _currentWeather = await MeteoService.getCurrentWeather();
  }
}
```

### 4. **Utilisation dans WeatherCard**
Le `WeatherCard` récupère automatiquement la ville de l'utilisateur :
```dart
void _loadWeatherWithUserCity() {
  final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  // 🔧 UTILISATEUR : Récupérer la ville de l'utilisateur depuis son profil
  final userWeatherCity = authProvider.user?.defaultWeatherCity;
  
  if (userWeatherCity != null && userWeatherCity.isNotEmpty) {
    // Utiliser la ville de l'utilisateur
    weatherProvider.loadCurrentWeather(userWeatherCity: userWeatherCity);
  } else {
    // Utiliser la ville par défaut du provider
    weatherProvider.loadCurrentWeather();
  }
}
```

## 🔄 Flux de données

```
Inscription → defaultWeatherCity → UserProfile → WeatherCard → WeatherProvider → MeteoService
```

1. **Inscription** : Utilisateur saisit sa ville météo
2. **Base de données** : Ville stockée avec clé `default_weather_city`
3. **Modèle User** : `UserProfile` avec `defaultWeatherCity`
4. **Widget WeatherCard** : Récupère la ville via `AuthProvider`
5. **Provider** : Utilise la ville pour les appels API
6. **Service** : Appelle l'API météo avec la bonne ville

## 🏆 Priorités des villes

1. **Ville spécifique** (si l'utilisateur change manuellement)
2. **Ville de l'utilisateur** (lors de l'inscription)
3. **Ville par défaut** ('Paris' si pas d'utilisateur)

## ✅ Vérification

Pour vérifier que ça fonctionne :

1. **Inscription** : Saisir une ville (ex: "Lyon")
2. **Connexion** : Se connecter avec ce compte
3. **Météo** : Vérifier que la météo affiche la ville saisie
4. **Profil** : Vérifier que `profile_screen.dart` affiche la bonne ville

## 🔧 Points techniques

- **Fallback intelligent** : Si pas de ville utilisateur, utilise 'Paris' par défaut
- **Validation** : La ville utilisateur est validée comme les autres villes
- **Mise à jour** : Si l'utilisateur modifie sa ville dans le profil, elle sera utilisée automatiquement
- **Cache** : La ville est mise en cache pour éviter les requêtes redondantes

## 🎯 Résultat

✅ **La ville enregistrée lors de l'inscription est récupérée et utilisée par la section météo !**
