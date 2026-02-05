# PLAN : Correction du Middleware SimpleAuth - Eager Loading du Profil

## 📋 PROBLÈME IDENTIFIÉ

### Symptôme
- Erreur 500 lors de l'accès aux données météo
- Le endpoint `/api/user/weather-city` échoue
- `$user->profile` retourne null ou cause des erreurs

### Cause Racine
Le middleware `SimpleAuth` charge l'utilisateur mais ne charge **pas** la relation `profile` via eager loading.

```php
// ❌ Code actuel (problématique)
$user = User::where('api_token', $token)->first();
$request->merge(['auth_user' => $user]);
```

Quand le `MeteoController` accède à `$user->profile`, Eloquent doit faire une requête supplémentaire (lazy loading), ce qui peut échouer si:
- La relation n'est pas définie correctement
- Il y a des problèmes de timing
- Le profil n'existe pas encore

## ✅ SOLUTION

### Modification du Middleware SimpleAuth

**Fichier**: `app/Http/Middleware/SimpleAuth.php`

**Avant**:
```php
// Ajoute l'utilisateur authentifié à la requête
$user = User::where('api_token', $token)->first();
$request->merge(['auth_user' => $user]);
```

**Après**:
```php
// Ajoute l'utilisateur authentifié à la requête
// Charger le profil avec l'utilisateur pour éviter les requêtes supplémentaires
$user = User::with('profile')->where('api_token', $token)->first();
$request->merge(['auth_user' => $user]);
```

### Pourquoi cette correction fonctionne

1. **Eager Loading**: `User::with('profile')` charge la relation `profile` en même temps que l'utilisateur en une seule requête SQL
2. **Évite N+1**: Pas de requête supplémentaire quand on accède à `$user->profile`
3. **Précharge les données**: Le profil est immédiatement disponible dans `$user->profile`
4. **Compatible avec la création**: Si le profil n'existe pas, `$user->profile` retourne `null` proprement

## 🔍 VÉRIFICATIONS NÉCESSAIRES

### 1. Vérifier le modèle User
Le modèle User doit avoir la relation `profile` définie:

```php
// app/Models/User.php
public function profile()
{
    return $this->hasOne(Profile::class);
}
```

### 2. Vérifier le modèle Profile
Le modèle Profile doit avoir la relation inverse:

```php
// app/Models/Profile.php
public function user()
{
    return $this->belongsTo(User::class);
}
```

### 3. Vérifier la création du profil lors de l'inscription
Dans `AuthController::register()`:

```php
$user->profile()->create([
    'name' => $request->name,
    'phone' => $request->phone,
    'address' => $request->address,
    'farm_name' => $request->farm_name,
    'default_weather_city' => $request->default_weather_city,
]);
```

### 4. Vérifier MeteoController
Le controller doit utiliser `$request->auth_user->profile` correctement:

```php
public function getUserWeatherCity(Request $request)
{
    $user = $request->auth_user;
    $profile = $user->profile; // Déjà chargé grâce au middleware
    
    if (!$profile || empty($profile->default_weather_city)) {
        return response()->json([
            'default_weather_city' => null,
            'message' => 'Aucune ville par défaut définie'
        ], 404);
    }
    
    return response()->json([
        'default_weather_city' => $profile->default_weather_city
    ]);
}
```

## 📁 FICHIERS À MODIFIER

| Fichier | Action | Priorité |
|---------|--------|----------|
| `app/Http/Middleware/SimpleAuth.php` | Modifier | 🔴 Haute |
| `app/Models/User.php` | Vérifier | 🟡 Moyenne |
| `app/Models/Profile.php` | Vérifier | 🟡 Moyenne |
| `app/Http/Controllers/AuthController.php` | Vérifier | 🟡 Moyenne |
| `app/Http/Controllers/MeteoController.php` | Vérifier | 🟡 Moyenne |

## 🧪 TESTS À EFFECTUER

### Test 1: Inscription + Weather City
```bash
# 1. S'inscrire avec une ville météo
curl -X POST http://localhost:8000/api/register \
  -H "Content-Type: application/json" \
  -d '{"name": "Test", "email": "test@test.com", "password": "password", "default_weather_city": "Paris"}'

# 2. Récupérer la ville météo
curl -X GET http://localhost:8000/api/user/weather-city \
  -H "Authorization: Bearer <TOKEN>"
```

### Test 2: Vérifier le profil chargé
```php
// Dans une route de test
Route::get('/debug-user', function (Request $request) {
    $user = $request->auth_user;
    return [
        'user_id' => $user->id,
        'has_profile' => $user->profile !== null,
        'profile_data' => $user->profile
    ];
});
```

### Test 3: Weather endpoints
```bash
# Test actuel weather
curl http://localhost:8000/api/meteo/actuelle/Paris

# Test prévisions
curl http://localhost:8000/api/meteo/prevision/Paris
```

## 📝 NOTES

- Cette correction est **minime mais critique** pour le fonctionnement de la météo
- Le eager loading améliore les performances en réduisant le nombre de requêtes SQL
- Si le problème persiste, vérifier les logs Laravel: `storage/logs/laravel.log`
- La ville par défaut doit être persistée dans `profiles.default_weather_city`

## ✅ CHECKLIST DE VALIDATION

- [ ] Middleware SimpleAuth modifié avec `with('profile')`
- [ ] Modèle User vérifié (relation profile)
- [ ] Modèle Profile vérifié (relation user)
- [ ] Inscription crée le profil avec `default_weather_city`
- [ ] Endpoint `/user/weather-city` retourne la ville
- [ ] Test de bout en bout (inscription → météo) fonctionne
- [ ] Pas d'erreurs 500 dans les logs

