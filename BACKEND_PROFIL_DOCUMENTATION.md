# Backend - Implémentation Profil et Mot de Passe

Ce document décrit les routes API nécessaires pour les fonctionnalités de profil implementées dans l'application Flutter.

## Routes API Requises

### 1. Changer le mot de passe

**Route:** `PUT /api/user/change-password`

**Description:** Permet à l'utilisateur de changer son mot de passe.

**Headers requis:**
- `Content-Type: application/json`
- `Accept: application/json`
- `Authorization: Bearer {token}`

**Corps de la requête:**
```json
{
    "current_password": "motdepasse_actuel",
    "new_password": "nouveau_mot_de_passe",
    "new_password_confirmation": "confirmation_mot_de_passe"
}
```

**Réponses possibles:**

- **200 OK** - Mot de passe modifié avec succès
  ```json
  {
      "message": "Mot de passe modifié avec succès"
  }
  ```

- **422 Unprocessable Entity** - Erreurs de validation
  ```json
  {
      "message": "Les données fournies sont invalides",
      "errors": {
          "current_password": ["Le mot de passe actuel est incorrect"],
          "new_password": ["Le nouveau mot de passe doit contenir au moins 8 caractères"]
      }
  }
  ```

- **401 Unauthorized** - Mot de passe actuel incorrect
  ```json
  {
      "message": "Le mot de passe actuel est incorrect"
  }
  ```

---

### 2. Modifier le profil (existant)

**Route:** `PUT /api/user/update`

**Description:** Met à jour les informations personnelles de l'utilisateur.

**Corps de la requête:**
```json
{
    "name": "Nouveau nom",
    "phone": "22961234567",
    "address": "Nouvelle adresse",
    "farm_name": "Nom de la ferme (optionnel)",
    "default_weather_city": "Lomé (optionnel)"
}
```

**Réponse:**
```json
{
    "user": {
        "id": 1,
        "name": "Nouveau nom",
        "email": "email@exemple.com",
        "profile": {
            "phone": "22961234567",
            "address": "Nouvelle adresse",
            "farm_name": "Nom de la ferme",
            "default_weather_city": "Lomé"
        }
    }
}
  ```

---

## Implémentation Laravel (Controller)

### Exemple de UserController.php

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class UserController extends Controller
{
    /**
     * Constructor - Appliquer le middleware auth
     */
    public function __construct()
    {
        $this->middleware('auth:sanctum');
    }

    /**
     * Récupérer le profil de l'utilisateur
     */
    public function show()
    {
        $user = Auth::user()->load('profile');
        
        return response()->json([
            'user' => $user
        ]);
    }

    /**
     * Mettre à jour le profil
     */
    public function update(Request $request)
    {
        $user = Auth::user();

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'required|string|max:20',
            'address' => 'required|string|max:500',
            'farm_name' => 'nullable|string|max:255',
            'default_weather_city' => 'nullable|string|max:100',
        ]);

        // Mettre à jour l'utilisateur
        $user->name = $validated['name'];
        $user->save();

        // Mettre à jour ou créer le profil
        $user->profile()->updateOrCreate(
            ['user_id' => $user->id],
            [
                'phone' => $validated['phone'],
                'address' => $validated['address'],
                'farm_name' => $validated['farm_name'] ?? null,
                'default_weather_city' => $validated['default_weather_city'] ?? null,
            ]
        );

        return response()->json([
            'user' => $user->load('profile'),
            'message' => 'Profil mis à jour avec succès'
        ]);
    }

    /**
     * Changer le mot de passe
     */
    public function changePassword(Request $request)
    {
        $user = Auth::user();

        $request->validate([
            'current_password' => 'required|string',
            'new_password' => [
                'required',
                'string',
                Password::min(8)
                    ->letters()
                    ->mixedCase()
                    ->numbers()
                    ->symbols(),
                'confirmed'
            ],
            'new_password_confirmation' => 'required|string',
        ], [
            'new_password.confirmed' => 'La confirmation du mot de passe ne correspond pas.',
            'new_password.password' => 'Le mot de passe doit contenir au moins 8 caractères, des lettres majuscules et minuscules, des chiffres et des symboles.',
        ]);

        // Vérifier le mot de passe actuel
        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'message' => 'Le mot de passe actuel est incorrect',
                'errors' => [
                    'current_password' => ['Le mot de passe actuel est incorrect']
                ]
            ], 422);
        }

        // Mettre à jour le mot de passe
        $user->password = Hash::make($request->new_password);
        $user->save();

        return response()->json([
            'message' => 'Mot de passe modifié avec succès'
        ]);
    }

    /**
     * Déconnexion (invalider le token)
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Déconnexion réussie'
        ]);
    }
}
```

---

## Fichier de Routes (routes/api.php)

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;

Route::middleware('auth:sanctum')->group(function () {
    // Profil utilisateur
    Route::get('/user', [UserController::class, 'show']);
    Route::put('/user/update', [UserController::class, 'update']);
    Route::put('/user/change-password', [UserController::class, 'changePassword']);
    
    // Ville météo
    Route::put('/user/weather-city', [UserController::class, 'updateWeatherCity']);
    Route::get('/user/weather-city', [UserController::class, 'getWeatherCity']);
    
    // Déconnexion
    Route::post('/logout', [UserController::class, 'logout']);
});
```

---

## Modèle User et Profile

### Modèle User.php

```php
<?php

namespace App\Models;

use Laravel\Sanctum\HasApiTokens;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
    ];

    /**
     * Relation avec le profil
     */
    public function profile()
    {
        return $this->hasOne(UserProfile::class);
    }
}
```

### Modèle UserProfile.php

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserProfile extends Model
{
    protected $fillable = [
        'user_id',
        'phone',
        'address',
        'farm_name',
        'default_weather_city',
    ];

    protected $table = 'user_profiles';

    /**
     * Relation avec l'utilisateur
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
```

---

## Migration de Base de Données

### Migration pour profiles

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateUserProfilesTable extends Migration
{
    public function up()
    {
        Schema::create('user_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('phone', 20);
            $table->string('address', 500);
            $table->string('farm_name', 255)->nullable();
            $table->string('default_weather_city', 100)->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('user_profiles');
    }
}
```

---

## Middleware CORS (config/cors.php)

Assurez-vous que le CORS est configuré pour accepter les requêtes de l'application mobile:

```php
'paths' => ['api/*', 'sanctum/csrf-cookie'],
'allowed_methods' => ['*'],
'allowed_origins' => ['http://localhost:8000', 'http://localhost:3000'],
'allowed_origins_patterns' => [],
'allowed_headers' => ['*'],
'exposed_headers' => [],
'max_age' => 0,
'supports_credentials' => true,
```

---

## Résumé des Endpoints

| Méthode | Route | Description |
|---------|-------|-------------|
| GET | `/api/user` | Récupérer le profil |
| PUT | `/api/user/update` | Modifier le profil |
| PUT | `/api/user/change-password` | Changer le mot de passe |
| PUT | `/api/user/weather-city` | Mettre à jour la ville météo |
| GET | `/api/user/weather-city` | Récupérer la ville météo |
| POST | `/api/logout` | Déconnexion |
| POST | `/api/sanctum/csrf-cookie` | Initialiser CSRF (Sanctum) |

---

## Notes Importantes

1. **Laravel Sanctum** doit être configuré pour l'authentification mobile
2. Le middleware `auth:sanctum` protège les routes de profil
3. La validation du mot de passe doit être stricte (8+ caractères, majuscules, minuscules, chiffres, symboles)
4. Les erreurs 422 doivent retourner un objet `errors` formaté pour l'affichage dans l'app

