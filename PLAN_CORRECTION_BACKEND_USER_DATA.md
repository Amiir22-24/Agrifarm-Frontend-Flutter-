# Plan de Correction Backend - Isolation des Données par Utilisateur

## Problème Identifié

Le backend Laravel renvoie toutes les données de la base de données au lieu de filtrer par utilisateur connecté. Chaque utilisateur voit les cultures, stocks, récoltes, rapports, notifications, etc. de tous les autres utilisateurs.

## Entités Affectées (TOUTES doivent être corrigées)

1. **Culture** - `GET /api/cultures`
2. **Stock** - `GET /api/stocks`
3. **Recolte** - `GET /api/recoltes`
4. **Vente** - `GET /api/ventes`
5. **Rapport** - `GET /api/rapports`
6. **Notification** - `GET /api/notifications`

## Corrections Nécessaires

### 1. CultureController
```php
// AVANT
public function index()
{
    return Culture::all();
}

// APRÈS
public function index()
{
    return Culture::where('user_id', auth()->id())->get();
}
```

### 2. StockController
```php
// AVANT
public function index()
{
    return Stock::all();
}

// APRÈS
public function index()
{
    return Stock::where('user_id', auth()->id())->get();
}
```

### 3. RecolteController
```php
// AVANT
public function index()
{
    return Recolte::all();
}

// APRÈS
public function index()
{
    return Recolte::where('user_id', auth()->id())->get();
}
```

### 4. VenteController
```php
// AVANT
public function index()
{
    return Vente::all();
}

// APRÈS
public function index()
{
    return Vente::where('user_id', auth()->id())->get();
}
```

### 5. RapportController
```php
// AVANT
public function index()
{
    return Rapport::all();
}

// APRÈS
public function index()
{
    return Rapport::where('user_id', auth()->id())->get();
}
```

### 6. NotificationController
```php
// AVANT
public function index()
{
    return Notification::all();
}

// APRÈS
public function index()
{
    return Notification::where('user_id', auth()->id())->get();
}
```

## Modification des Méthodes de Création

Lors de la création d'une nouvelle entité, le `user_id` doit être automatiquement défini :

```php
public function store(Request $request)
{
    $validated = $request->validate([
        // ... validation rules
    ]);

    $culture = Culture::create([
        ...$validated,
        'user_id' => auth()->id(), // AJOUTER CECI
    ]);

    return response()->json(['culture' => $culture], 201);
}
```

## Middleware de Vérification

S'assurer que les utilisateurs ne peuvent accéder qu'à leurs propres données :

```php
public function show($id)
{
    $culture = Culture::findOrFail($id);
    
    // Vérifier que l'utilisateur est propriétaire
    if ($culture->user_id !== auth()->id()) {
        return response()->json(['error' => 'Non autorisé'], 403);
    }
    
    return $culture;
}
```

## Vérification de la Base de Données

Vérifier que les tables ont bien la colonne `user_id` :

```sql
ALTER TABLE cultures ADD COLUMN user_id BIGINT UNSIGNED NULL;
ALTER TABLE stocks ADD COLUMN user_id BIGINT UNSIGNED NULL;
ALTER TABLE recoltes ADD COLUMN user_id BIGINT UNSIGNED NULL;
ALTER TABLE ventes ADD COLUMN user_id BIGINT UNSIGNED NULL;
ALTER TABLE rapports ADD COLUMN user_id BIGINT UNSIGNED NULL;
ALTER TABLE notifications ADD COLUMN user_id BIGINT UNSIGNED NULL;

-- Ajouter les contraintes de clé étrangère
ALTER TABLE cultures ADD CONSTRAINT fk_cultures_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE stocks ADD CONSTRAINT fk_stocks_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE recoltes ADD CONSTRAINT fk_recoltes_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE ventes ADD CONSTRAINT fk_ventes_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE rapports ADD CONSTRAINT fk_rapports_user FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE notifications ADD CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id);
```

## Résumé des Étapes

1. **Ajouter la colonne `user_id`** à toutes les tables si elle n'existe pas
2. **Mettre à jour les controllers** pour filtrer par `user_id`
3. **Modifier les méthodes store/create** pour inclure automatiquement `user_id`
4. **Ajouter des vérifications de propriété** dans les méthodes show/update/delete
5. **Migrez les données existantes** si nécessaire (assigner un utilisateur par défaut)
6. **Tester l'isolation des données** en créant des comptes de test

## Temps Estimé
- Backend : 2-3 heures
- Tests : 1 heure
- Total : 3-4 heures

## Resultat Attendu
Chaque utilisateur ne voit que ses propres données (cultures, stocks, récoltes, ventes, rapports, notifications) et ne peut pas accéder aux données des autres utilisateurs.

