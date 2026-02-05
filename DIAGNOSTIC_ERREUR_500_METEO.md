# 🔧 Diagnostic Erreur 500 - Météo Laravel

## 🚨 Problème actuel
**Erreur :** `GET http://localhost:8000/api/meteo/actuelle 500 (Internal Server Error)`

## 🎯 Actions de diagnostic côté Backend

### 1. **Vérifier les logs Laravel**
```bash
# Accéder au dossier Laravel
cd /chemin/vers/votre/projet/laravel

# Voir les logs en temps réel
tail -f storage/logs/laravel.log

# Ou voir les dernières erreurs
tail -n 50 storage/logs/laravel.log
```

### 2. **Tester la route directement avec curl**
```bash
# Test de santé de l'API
curl -v http://localhost:8000/api/health

# Test spécifique de la route météo
curl -v http://localhost:8000/api/meteo/actuelle

# Test avec headers JSON
curl -v -H "Accept: application/json" http://localhost:8000/api/meteo/actuelle
```

### 3. **Vérifier les routes Laravel**
```bash
# Lister toutes les routes
php artisan route:list

# Filtrer les routes météo uniquement
php artisan route:list | grep meteo
```

**Routes attendues :**
- `GET /api/meteo/actuelle` → `MeteoController@show`
- `GET /api/meteo/actuelle/{ville}` → `MeteoController@show`
- `GET /api/cultures/{id}/weather` → `MeteoController@weatherForCrop`

### 4. **Vérifier le MeteoController**
Vérifier que le fichier `app/Http/Controllers/MeteoController.php` existe et contient la méthode `show()` :

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class MeteoController extends Controller
{
    /**
     * Afficher la météo actuelle ou pour une ville spécifique
     */
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
            \Log::error('Erreur météo:', ['error' => $e->getMessage()]);
            return response()->json([
                'error' => true,
                'message' => 'Erreur serveur météo',
                'details' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Obtenir la météo pour une ville
     */
    private function getWeatherForCity(string $ville): array
    {
        // TODO: Implémenter la logique météo réelle
        // Pour l'instant, retourner des données mockées
        return [
            'temperature' => rand(15, 30),
            'humidity' => rand(40, 80),
            'description' => 'Ensoleillé',
            'ville' => $ville,
            'timestamp' => now()->toIso8601String()
        ];
    }
    
    // Autres méthodes...
}
```

### 5. **Vérifier les routes API**
Fichier `routes/api.php` doit contenir :

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\MeteoController;

Route::middleware('api')->group(function () {
    
    // Routes météo
    Route::get('/meteo/actuelle', [MeteoController::class, 'show']);
    Route::get('/meteo/actuelle/{ville}', [MeteoController::class, 'show']);
    Route::get('/cultures/{id}/weather', [MeteoController::class, 'weatherForCrop']);
    Route::get('/meteo/historique', [MeteoController::class, 'history']);
    
    // Route de santé
    Route::get('/health', function () {
        return response()->json(['status' => 'OK']);
    });
});
```

### 6. **Vérifier la configuration CORS**
Fichier `config/cors.php` doit permettre les requêtes :

```php
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'], // En dev uniquement
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
```

### 7. **Vérifier l'autoloading**
```bash
# Redémarrer l'autoloader
composer dump-autoload

# Nettoyer le cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
```

### 8. **Redémarrer le serveur**
```bash
# Arrêter le serveur (Ctrl+C)
# Puis redémarrer
php artisan serve
```

## 🔍 Points de contrôle

### ✅ Checklist de vérification :

1. **Le MeteoController existe ?**
   - [ ] Fichier `app/Http/Controllers/MeteoController.php`
   - [ ] Méthode `show()` présente
   - [ ] Import `use Illuminate\Http\JsonResponse;`

2. **Les routes sont définies ?**
   - [ ] Routes dans `routes/api.php`
   - [ ] Controller correctement référencé
   - [ ] Méthode existante

3. **Le serveur fonctionne ?**
   - [ ] `php artisan serve` démarré
   - [ ] Port 8000 accessible
   - [ ] Pas d'erreur dans la console

4. **Les logs sont propres ?**
   - [ ] Pas d'erreur dans `storage/logs/laravel.log`
   - [ ] Pas d'erreur de syntaxe PHP
   - [ ] Autoloading OK

## 🚨 Si le problème persiste

1. **Activer le debug Laravel :**
   - Fichier `.env` : `APP_DEBUG=true`
   - Redémarrer le serveur

2. **Tester avec Postman ou Insomnia :**
   - URL : `http://localhost:8000/api/meteo/actuelle`
   - Method : GET
   - Headers : `Accept: application/json`

3. **Vérifier les permissions :**
   ```bash
   chmod -R 755 storage/
   chmod -R 755 bootstrap/cache/
   ```

---

**Prochaines étapes :** Une fois le diagnostic effectué, partagez-moi les résultats pour que je puisse vous aider à corriger le problème spécifique !
