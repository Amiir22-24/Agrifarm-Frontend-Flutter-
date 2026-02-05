# Plan : Intégration de la Ville Météo Utilisateur dans Flutter

## 📋 Problème Identifié

L'application Flutter n'utilise pas la ville météo sauvegardée par l'utilisateur lors de l'inscription. La ville devrait être récupérée depuis `/api/user/weather-city` et utilisée comme valeur par défaut pour les requêtes météo.

## 📊 Informations Gathered

### Fichiers Analysés :

1. **profile_service.dart** (✅ Correct)
   - `getWeatherCity()` existe et utilise `/api/user/weather-city`
   - `updateWeatherCity()` utilise `/api/user/weather-city`

2. **user_provider.dart** (❌ Manque méthode)
   - Pas de méthode pour récupérer la ville météo de l'utilisateur
   - `_user` ne contient pas l'info `default_weather_city`

3. **weather_provider.dart** (❌ Non intégré)
   - Utilise `currentCity = 'Paris'` par défaut
   - Ne appelle jamais `/api/user/weather-city`

4. **meteo_screen.dart** (❌ Non intégré)
   - Ne passe pas la ville utilisateur au WeatherProvider
   - Ne récupère pas la ville depuis le backend

5. **home_screen.dart** (❌ Non intégré)
   - N'intègre pas la météo avec la ville de l'utilisateur
   - La carte météo est statique

## ✅ Plan de Correction

### Fichier 1 : `lib/providers/user_provider.dart`

**Objectif** : Ajouter une méthode pour récupérer la ville météo de l'utilisateur

**Modifications** :
```dart
// Ajouter après les propriétés existantes
String? _userWeatherCity;
String? get userWeatherCity => _userWeatherCity;

// Ajouter méthode pour charger la ville météo
Future<void> fetchUserWeatherCity() async {
  try {
    final city = await ProfileService.getWeatherCity();
    _userWeatherCity = city;
    notifyListeners();
  } catch (e) {
    _userWeatherCity = null;
  }
}

// Ajouter méthode pour mettre à jour la ville météo
Future<bool> updateUserWeatherCity(String city) async {
  try {
    await ProfileService.updateWeatherCity(city);
    _userWeatherCity = city;
    notifyListeners();
    return true;
  } catch (e) {
    _error = e.toString();
    notifyListeners();
    return false;
  }
}
```

### Fichier 2 : `lib/providers/weather_provider.dart`

**Objectif** : Modifier pour accepter et utiliser la ville de l'utilisateur

**Modifications** :
```dart
// Modifier loadCurrentWeather pour accepter userWeatherCity
Future<void> loadCurrentWeather({String? city, String? userWeatherCity}) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    // Utiliser la ville de l'utilisateur si fournie, sinon la ville configurée
    final targetCity = city ?? userWeatherCity ?? _currentCity;
    
    if (targetCity != _currentCity) {
      _currentCity = targetCity;
    }

    if (city != null || userWeatherCity != null) {
      _currentWeather = await MeteoService.getWeatherByCity(targetCity);
    } else {
      _currentWeather = await MeteoService.getCurrentWeather();
    }
  } catch (e) {
    _error = _formatWeatherError(e.toString());
    _currentWeather = null;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

// Modifier loadForecast de la même manière
Future<void> loadForecast({String? city, String? userWeatherCity}) async {
  // Même logique que loadCurrentWeather
}

// Ajouter méthode pour charger la météo avec la ville utilisateur
Future<void> loadDefaultWeather({String? userWeatherCity}) async {
  try {
    await loadCurrentWeather(userWeatherCity: userWeatherCity);
    await loadForecast(userWeatherCity: userWeatherCity);
  } catch (e) {
    _error = e.toString();
  }
}
```

### Fichier 3 : `lib/screens/meteo_screen.dart`

**Objectif** : Charger la ville de l'utilisateur au démarrage

**Modifications** :
```dart
class _MeteoScreenState extends State<MeteoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeatherWithUserCity();
    });
  }

  Future<void> _loadWeatherWithUserCity() async {
    // Récupérer la ville de l'utilisateur
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Si pas de ville sauvegardée, la charger depuis le backend
    if (userProvider.userWeatherCity == null) {
      await userProvider.fetchUserWeatherCity();
    }
    
    // Charger la météo avec la ville de l'utilisateur
    if (mounted) {
      Provider.of<WeatherProvider>(context, listen: false).loadDefaultWeather(
        userWeatherCity: userProvider.userWeatherCity,
      );
    }
  }

  // Modifier _loadWeatherData pour utiliser la ville utilisateur
  void _loadWeatherData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Provider.of<WeatherProvider>(context, listen: false).loadDefaultWeather(
      userWeatherCity: userProvider.userWeatherCity,
    );
  }
}
```

### Fichier 4 : `lib/screens/home_screen.dart`

**Objectif** : Intégrer la météo avec la ville de l'utilisateur dans le tableau de bord

**Modifications** :
```dart
// Dans HomeContent, modifier _loadAllData
void _loadAllData() {
  // Charger les données de tous les providers
  Provider.of<CulturesProvider>(context, listen: false).fetchCultures();
  Provider.of<VentesProvider>(context, listen: false).fetchVentes();
  Provider.of<StockProvider>(context, listen: false).fetchStocks();
  Provider.of<RecolteProvider>(context, listen: false).fetchRecoltes();
  Provider.of<NotificationsProvider>(context, listen: false).fetchNotifications();
  
  // Charger la ville météo de l'utilisateur
  Provider.of<UserProvider>(context, listen: false).fetchUserWeatherCity();
}

// Modifier _buildWeatherCard pour afficher des données réelles
Widget _buildWeatherCard() {
  return Consumer2<WeatherProvider, UserProvider>(
    builder: (context, weatherProvider, userProvider, _) {
      // Utiliser la ville de l'utilisateur ou la ville actuelle
      final targetCity = userProvider.userWeatherCity ?? weatherProvider.currentCity;
      
      return Card(
        // ... existing card UI
        child: InkWell(
          onTap: () => _navigateToScreen(4),
          child: /* ... */,
        ),
      );
    },
  );
}
```

## 📁 Fichiers à Modifier

| Fichier | Action | Priorité |
|---------|--------|----------|
| `lib/providers/user_provider.dart` | Ajouter méthodes ville météo | 🔴 Haute |
| `lib/providers/weather_provider.dart` | Modifier pour accepter userWeatherCity | 🔴 Haute |
| `lib/screens/meteo_screen.dart` | Charger ville utilisateur | 🔴 Haute |
| `lib/screens/home_screen.dart` | Intégrer météo utilisateur | 🟡 Moyenne |

## 🔧 Étapes d'Implémentation

### Étape 1 : Modifier UserProvider
1. Ajouter propriété `_userWeatherCity`
2. Ajouter méthode `fetchUserWeatherCity()`
3. Ajouter méthode `updateUserWeatherCity()`

### Étape 2 : Modifier WeatherProvider
1. Modifier `loadCurrentWeather()` pour accepter `userWeatherCity`
2. Modifier `loadForecast()` pour accepter `userWeatherCity`
3. Ajouter méthode `loadDefaultWeather()`

### Étape 3 : Modifier MeteoScreen
1. Ajouter `_loadWeatherWithUserCity()`
2. Appeler cette méthode dans `initState()`
3. Modifier `_loadWeatherData()` pour utiliser la ville utilisateur

### Étape 4 : Modifier HomeScreen
1. Appeler `fetchUserWeatherCity()` dans `_loadAllData()`
2. Modifier `_buildWeatherCard()` pour utiliser les vrais données

## 🧪 Tests à Effectuer

### Test 1 : Vérifier la récupération de la ville
```dart
// Dans le code
final userProvider = Provider.of<UserProvider>(context, listen: false);
print('Ville utilisateur: ${userProvider.userWeatherCity}');
```

### Test 2 : Vérifier le chargement de la météo
- Ouvrir l'écran MeteoScreen
- Vérifier que la ville affichée correspond à celle sauvegardée
- Vérifier que les données météo se chargent correctement

### Test 3 : Vérifier le dashboard
- Ouvrir l'écran d'accueil
- Cliquer sur la carte météo
- Vérifier que la navigation fonctionne

## ✅ Résultat Attendu

1. L'application récupère la ville météo sauvegardée lors de l'inscription
2. La météo utilise cette ville comme valeur par défaut
3. Si aucune ville n'est sauvegardée, utilise "Paris" comme fallback
4. L'utilisateur peut changer la ville dans son profil
5. La météo se met à jour automatiquement après changement

## 📝 Notes

- La méthode `ProfileService.getWeatherCity()` existe déjà et fonctionne
- Le backend retourne `{"default_weather_city": "Lomé"}` correctement
- L'intégration doit être fluide et transparente pour l'utilisateur

