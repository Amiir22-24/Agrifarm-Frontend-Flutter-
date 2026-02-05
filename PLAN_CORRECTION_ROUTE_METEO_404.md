# 📋 Plan de Diagnostic et Correction - Route Météo 404

## 📊 Résumé de la Situation

| Test | Résultat |
|------|----------|
| Ville sauvegardée dans `profiles.default_weather_city` | ✅ OUI |
| Endpoint `/api/user/weather-city` | ✅ 200 OK |
| Endpoint `/api/meteo/actuelle/Paris` | ❌ 404 - Route non trouvée |

## 🔍 Analyse du Problème

### Routes Backend (selon `php artisan route:list`)

```bash
GET|HEAD  api/meteo/actuelle  ................... MeteoController@getCurrentWeather
GET|HEAD  api/meteo/historique  ................. MeteoController@getWeatherHistory
```

**⚠️ PROBLÈME IDENTIFIÉ:** La route `/api/meteo/actuelle/{ville}` avec paramètre dynamique **N'APPARAÎT PAS** dans la liste des routes !

### Routes Attendues vs Réelles

| Route Attendue | Route Réelle | Status |
|----------------|--------------|--------|
| `GET /api/meteo/actuelle/{ville}` | ❌ Manquante | 🔴 404 |
| `GET /api/meteo/actuelle` | ✅ Existante | 🟢 200 |

## 🎯 Causes Probables du 404

### 1. **Route non enregistrée correctement**
La route avec paramètre `{ville}` n'est pas définie dans `routes/api.php`

### 2. **Conflit de routes**
Deux routes similaires :
- `/meteo/actuelle` (sans paramètre)
- `/meteo/actuelle/{ville}` (avec paramètre)

La première peut intercepter la seconde.

### 3. **Middleware `simple.auth` bloquant**
Le middleware pourrait bloquer l'accès si mal configuré.

### 4. **Cache des routes**
Les routes peuvent être en cache et non rafraîchies.

## 📝 Plan de Correction

### Phase 1: Diagnostic Backend

#### 1.1 Vérifier le fichier `routes/api.php`

```php
// Structure attendue
Route::middleware('simple.auth')->group(function () {
    // Météo actuelle sans paramètre
    Route::get('/meteo/actuelle', [MeteoController::class, 'getCurrentWeather']);
    
    // Météo actuelle AVEC paramètre ville - MANQUANTE !
    Route::get('/meteo/actuelle/{ville}', [MeteoController::class, 'show']);
});
```

#### 1.2 Vérifier le MeteoController

```php
// Méthode show() doit exister
public function show(Request $request, ?string $ville = null): JsonResponse
{
    // Log pour debug
    \Log::info('MeteoController@show called', ['ville' => $ville]);
    
    // Si une ville est spécifiée
    if ($ville) {
        $meteoData = $this->getWeatherForCity($ville);
    } else {
        // Ville par défaut
        $meteoData = $this->getWeatherForCity('Paris');
    }
    
    return response()->json($meteoData);
}
```

### Phase 2: Commandes de Diagnostic

```bash
# 1. Nettoyer le cache des routes
php artisan route:clear

# 2. Lister les routes avec filtre météo
php artisan route:list | findstr meteo

# 3. Vérifier les logs
tail -n 50 storage/logs/laravel.log

# 4. Tester la route directement
curl -v http://localhost:8000/api/meteo/actuelle/Paris
```

### Phase 3: Corrections Backend

#### 3.1 Ajouter la route manquante dans `routes/api.php`

```php
// Groupe avec middleware simple.auth
Route::middleware('simple.auth')->group(function () {
    // Météo actuelle sans paramètre
    Route::get('/meteo/actuelle', [MeteoController::class, 'getCurrentWeather']);
    
    // ✅ Météo actuelle AVEC paramètre ville - CORRECTION
    Route::get('/meteo/actuelle/{ville}', [MeteoController::class, 'show'])
         ->where('ville', '[a-zA-ZÀ-ÿ\s\-]+'); // Validation du paramètre
});
```

#### 3.2 Ajouter la méthode `show()` dans MeteoController

```php
public function show(Request $request, ?string $ville = null): JsonResponse
{
    try {
        // Log pour debug
        \Log::info('MeteoController@show called', ['ville' => $ville]);
        
        // Si une ville est spécifiée
        if ($ville) {
            $meteoData = $this->getWeatherForCity($ville);
        } else {
            // Ville par défaut
            $meteoData = $this->getWeatherForCity('Paris');
        }
        
        return response()->json($meteoData);
        
    } catch (\Exception $e) {
        \Log::error('Erreur météo show:', ['error' => $e->getMessage()]);
        return response()->json([
            'error' => true,
            'message' => 'Erreur lors de la récupération de la météo',
            'details' => $e->getMessage()
        ], 500);
    }
}

private function getWeatherForCity(string $ville): array
{
    // TODO: Intégration avec API OpenWeatherMap
    // Pour l'instant, données mockées
    return [
        'temperature' => rand(15, 35),
        'humidity' => rand(40, 90),
        'description' => 'Ensoleillé',
        'ville' => $ville,
        'timestamp' => now()->toIso8601String()
    ];
}
```

### Phase 4: Nettoyage et Test

```bash
# Nettoyer le cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Recharger les routes
php artisan route:list | findstr meteo

# Tester
curl http://localhost:8000/api/meteo/actuelle/Paris
```

## 🔧 Corrections Frontend (Flutter)

Le code Flutter est déjà configuré pour utiliser:
- `getWeatherByCity()` → `/meteo/actuelle/{ville}`
- `getCurrentWeather()` → `/meteo/actuelle`

Ces routes sont **déjà implémentées correctement** dans `meteo_service.dart`.

## 📋 Checklist de Vérification

- [ ] La route `/api/meteo/actuelle/{ville}` est ajoutée dans `routes/api.php`
- [ ] La méthode `show()` existe dans `MeteoController`
- [ ] Le cache des routes est vidé (`php artisan route:clear`)
- [ ] Le test `curl http://localhost:8000/api/meteo/actuelle/Paris` retourne 200
- [ ] Les logs Laravel ne contiennent pas d'erreurs

## 🚀 Prochaines Étapes

1. **Exécuter les commandes de diagnostic** sur le backend Laravel
2. **Vérifier le fichier `routes/api.php`** pour confirmer l'absence de la route
3. **Ajouter la route manquante** avec le paramètre `{ville}`
4. **Vérifier que la méthode `show()`** existe dans `MeteoController`
5. **Tester la correction** avec Postman ou curl

---

**Status:** Plan prêt pour implémentation
**Date:** $(date)
**Priorité:** 🔴 Haute - Bloquant pour la fonctionnalité météo

