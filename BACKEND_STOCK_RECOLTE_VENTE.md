# Backend Laravel - Stock/Récolte/Vente

## Endpoints nécessaires

### 1. Récupérer les récoltes d'une culture
```
GET /api/recoltes/culture/{cultureId}
```

### 2. Calculer le total en stock pour une culture
```
GET /api/stocks/culture/{cultureId}/total
```

### 3. Décrémenter le stock après vente
```
PUT /api/stocks/{id}/decrement
Body: { "quantite": 50, "unite": "kg" }
```

---

## Fichier de routes (routes/api.php)

```php
<?php

use App\Http\Controllers\StockController;
use App\Http\Controllers\RecolteController;
use App\Http\Controllers\VenteController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Routes protégées par auth:sanctum
Route::middleware(['auth:sanctum'])->group(function () {
    
    // ========== STOCKS ==========
    Route::prefix('stocks')->group(function () {
        Route::get('/', [StockController::class, 'index']);
        Route::post('/', [StockController::class, 'store']);
        Route::get('/{id}', [StockController::class, 'show']);
        Route::put('/{id}', [StockController::class, 'update']);
        Route::delete('/{id}', [StockController::class, 'destroy']);
        
        // NOUVEAU: Total en stock pour une culture
        Route::get('/culture/{cultureId}/total', [StockController::class, 'totalByCulture']);
        
        // NOUVEAU: Décrémenter le stock après vente
        Route::put('/{id}/decrement', [StockController::class, 'decrement']);
    });
    
    // ========== RÉCOLTES ==========
    Route::prefix('recoltes')->group(function () {
        Route::get('/', [RecolteController::class, 'index']);
        Route::post('/', [RecolteController::class, 'store']);
        Route::get('/{id}', [RecolteController::class, 'show']);
        Route::put('/{id}', [RecolteController::class, 'update']);
        Route::delete('/{id}', [RecolteController::class, 'destroy']);
        
        // NOUVEAU: Récoltes par culture
        Route::get('/culture/{cultureId}', [RecolteController::class, 'byCulture']);
    });
    
    // ========== VENTES ==========
    Route::prefix('ventes')->group(function () {
        Route::get('/', [VenteController::class, 'index']);
        Route::post('/', [VenteController::class, 'store']);
        Route::get('/{id}', [VenteController::class, 'show']);
        Route::put('/{id}', [VenteController::class, 'update']);
        Route::delete('/{id}', [VenteController::class, 'destroy']);
    });
});
```

---

## StockController.php

```php
<?php

namespace App\Http\Controllers;

use App\Models\Stock;
use App\Models\Culture;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class StockController extends Controller
{
    /**
     * Liste tous les stocks de l'utilisateur
     */
    public function index(Request $request)
    {
        $stocks = Stock::where('user_id', $request->user()->id)
            ->with('culture')
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json($stocks);
    }

    /**
     * Créer un nouveau stock
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'produit' => 'required|exists:cultures,id',
            'quantite' => 'required|numeric|min:0.01',
            'unite' => 'required|string|in:kg,tonne,sac,litre,unite',
            'dateEntree' => 'required|date',
            'dateExpiration' => 'nullable|date|after:dateEntree',
            'disponibilite' => 'required|string|in:Disponible,Réservé,Sortie',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'errors' => $validator->errors()
            ], 422);
        }

        // Vérifier que la culture appartient à l'utilisateur
        $culture = Culture::where('id', $request->produit)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$culture) {
            return response()->json([
                'message' => 'Culture non trouvée ou non autorisée'
            ], 404);
        }

        $stock = Stock::create([
            'user_id' => $request->user()->id,
            'produit' => $request->produit,
            'quantite' => $request->quantite,
            'unite' => $request->unite,
            'dateEntree' => $request->dateEntree,
            'dateExpiration' => $request->dateExpiration,
            'disponibilite' => $request->disponibilite,
        ]);

        return response()->json([
            'stock' => $stock->load('culture'),
            'message' => 'Stock créé avec succès'
        ], 201);
    }

    /**
     * Afficher un stock
     */
    public function show(Request $request, $id)
    {
        $stock = Stock::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->with('culture')
            ->first();

        if (!$stock) {
            return response()->json(['message' => 'Stock non trouvé'], 404);
        }

        return response()->json($stock);
    }

    /**
     * Mettre à jour un stock
     */
    public function update(Request $request, $id)
    {
        $stock = Stock::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$stock) {
            return response()->json(['message' => 'Stock non trouvé'], 404);
        }

        $validator = Validator::make($request->all(), [
            'quantite' => 'sometimes|numeric|min:0.01',
            'unite' => 'sometimes|string|in:kg,tonne,sac,litre,unite',
            'disponibilite' => 'sometimes|string|in:Disponible,Réservé,Sortie',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $stock->update($validator->validated());

        return response()->json([
            'stock' => $stock->fresh()->load('culture'),
            'message' => 'Stock mis à jour'
        ]);
    }

    /**
     * Supprimer un stock
     */
    public function destroy(Request $request, $id)
    {
        $stock = Stock::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$stock) {
            return response()->json(['message' => 'Stock non trouvé'], 404);
        }

        $stock->delete();

        return response()->json(['message' => 'Stock supprimé']);
    }

    /**
     * NOUVEAU: Total en stock pour une culture (en kg)
     */
    public function totalByCulture(Request $request, $cultureId)
    {
        // Vérifier que la culture appartient à l'utilisateur
        $culture = Culture::where('id', $cultureId)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$culture) {
            return response()->json(['message' => 'Culture non trouvée'], 404);
        }

        // Calculer le total en kg
        $stocks = Stock::where('produit', $cultureId)
            ->where('user_id', $request->user()->id)
            ->where('disponibilite', '!=', 'Sortie')
            ->get();

        $totalKg = 0;
        foreach ($stocks as $stock) {
            $quantiteKg = $this->convertirEnKg($stock->quantite, $stock->unite);
            $totalKg += $quantiteKg;
        }

        return response()->json([
            'culture_id' => $cultureId,
            'culture_nom' => $culture->nom,
            'total_kg' => round($totalKg, 2),
            'total_tonne' => round($totalKg / 1000, 3),
            'nombre_stocks' => $stocks->count(),
        ]);
    }

    /**
     * NOUVEAU: Décrémenter le stock après une vente
     */
    public function decrement(Request $request, $id)
    {
        $stock = Stock::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$stock) {
            return response()->json(['message' => 'Stock non trouvé'], 404);
        }

        $validator = Validator::make($request->all(), [
            'quantite' => 'required|numeric|min:0.01',
            'unite' => 'required|string|in:kg,tonne',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $quantiteADecrementer = $validator->validated()['quantite'];
        $unite = $validator->validated()['unite'];

        // Convertir en kg pour la comparaison
        $stockEnKg = $this->convertirEnKg($stock->quantite, $stock->unite);
        $aDecrementerEnKg = $this->convertirEnKg($quantiteADecrementer, $unite);

        // Vérifier si le stock est suffisant
        if ($stockEnKg < $aDecrementerEnKg) {
            return response()->json([
                'message' => 'Stock insuffisant pour cette opération',
                'stock_actuel_kg' => round($stockEnKg, 2),
                'quantite_demandee_kg' => round($aDecrementerEnKg, 2),
                'manquant_kg' => round($aDecrementerEnKg - $stockEnKg, 2),
            ], 422);
        }

        // Calculer la nouvelle quantité
        $nouveauStockEnKg = $stockEnKg - $aDecrementerEnKg;
        
        // Convertir vers l'unité originale du stock
        $nouvelleQuantite = $this->convertirDepuisKg($nouveauStockEnKg, $stock->unite);

        // Mettre à jour le stock
        $stock->quantite = $nouvelleQuantite;
        
        // Si la quantité devient 0 ou très petite, marquer comme "Sorti"
        if ($nouvelleQuantite <= 0.01) {
            $stock->quantite = 0;
            $stock->disponibilite = 'Sortie';
            $stock->dateSortie = now();
        }

        $stock->save();

        return response()->json([
            'stock' => $stock->fresh(),
            'message' => 'Stock décrémenté avec succès',
            'quantite_decroiteree_kg' => round($aDecrementerEnKg, 2),
            'nouveau_stock_kg' => round($nouveauStockEnKg, 2),
        ]);
    }

    /**
     * Helper: Convertir une valeur en kg
     */
    private function convertirEnKg(float $valeur, string $unite): float
    {
        return match ($unite) {
            'kg' => $valeur,
            'tonne' => $valeur * 1000,
            'sac' => $valeur * 50, // 1 sac = 50 kg par défaut
            'litre' => $valeur, // 1 litre ≈ 1 kg
            default => $valeur,
        };
    }

    /**
     * Helper: Convertir depuis kg vers l'unité cible
     */
    private function convertirDepuisKg(float $valeurEnKg, string $uniteCible): float
    {
        return match ($uniteCible) {
            'kg' => $valeurEnKg,
            'tonne' => $valeurEnKg / 1000,
            'sac' => $valeurEnKg / 50,
            'litre' => $valeurEnKg,
            default => $valeurEnKg,
        };
    }
}
```

---

## RecolteController.php

```php
<?php

namespace App\Http\Controllers;

use App\Models\Recolte;
use App\Models\Culture;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class RecolteController extends Controller
{
    /**
     * Liste toutes les récoltes
     */
    public function index(Request $request)
    {
        $recoltes = Recolte::where('user_id', $request->user()->id)
            ->with('culture')
            ->orderBy('date_recolte', 'desc')
            ->paginate(20);

        return response()->json($recoltes);
    }

    /**
     * Créer une nouvelle récolte
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'culture_id' => 'required|exists:cultures,id',
            'quantite' => 'required|numeric|min:0.01',
            'unite' => 'required|string|in:kg,tonne,sac,litre',
            'date_recolte' => 'required|date',
            'qualite' => 'nullable|string',
            'observations' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Vérifier que la culture appartient à l'utilisateur
        $culture = Culture::where('id', $request->culture_id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$culture) {
            return response()->json(['message' => 'Culture non trouvée'], 404);
        }

        $recolte = Recolte::create([
            'user_id' => $request->user()->id,
            'culture_id' => $request->culture_id,
            'quantite' => $request->quantite,
            'unite' => $request->unite,
            'date_recolte' => $request->date_recolte,
            'qualite' => $request->qualite,
            'observations' => $request->observations,
        ]);

        return response()->json([
            'recolte' => $recolte->load('culture'),
            'message' => 'Récolte enregistrée avec succès'
        ], 201);
    }

    /**
     * Afficher une récolte
     */
    public function show(Request $request, $id)
    {
        $recolte = Recolte::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->with('culture')
            ->first();

        if (!$recolte) {
            return response()->json(['message' => 'Récolte non trouvée'], 404);
        }

        return response()->json($recolte);
    }

    /**
     * Mettre à jour une récolte
     */
    public function update(Request $request, $id)
    {
        $recolte = Recolte::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$recolte) {
            return response()->json(['message' => 'Récolte non trouvée'], 404);
        }

        $validator = Validator::make($request->all(), [
            'quantite' => 'sometimes|numeric|min:0.01',
            'unite' => 'sometimes|string|in:kg,tonne,sac,litre',
            'qualite' => 'sometimes|nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $recolte->update($validator->validated());

        return response()->json([
            'recolte' => $recolte->fresh()->load('culture'),
            'message' => 'Récolte mise à jour'
        ]);
    }

    /**
     * Supprimer une récolte
     */
    public function destroy(Request $request, $id)
    {
        $recolte = Recolte::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$recolte) {
            return response()->json(['message' => 'Récolte non trouvée'], 404);
        }

        $recolte->delete();

        return response()->json(['message' => 'Récolte supprimée']);
    }

    /**
     * NOUVEAU: Récupérer toutes les récoltes d'une culture
     */
    public function byCulture(Request $request, $cultureId)
    {
        // Vérifier que la culture appartient à l'utilisateur
        $culture = Culture::where('id', $cultureId)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$culture) {
            return response()->json(['message' => 'Culture non trouvée'], 404);
        }

        $recoltes = Recolte::where('culture_id', $cultureId)
            ->where('user_id', $request->user()->id)
            ->orderBy('date_recolte', 'desc')
            ->get();

        // Calculer le total en kg
        $totalKg = 0;
        foreach ($recoltes as $recolte) {
            $totalKg += $this->convertirEnKg($recolte->quantite, $recolte->unite);
        }

        return response()->json([
            'culture_id' => $cultureId,
            'culture_nom' => $culture->nom,
            'recoltes' => $recoltes,
            'total_kg' => round($totalKg, 2),
            'total_tonne' => round($totalKg / 1000, 3),
            'nombre_recoltes' => $recoltes->count(),
        ]);
    }

    /**
     * Helper: Convertir en kg
     */
    private function convertirEnKg(float $valeur, string $unite): float
    {
        return match ($unite) {
            'kg' => $valeur,
            'tonne' => $valeur * 1000,
            'sac' => $valeur * 50,
            'litre' => $valeur,
            default => $valeur,
        };
    }
}
```

---

## VenteController.php (Mise à jour pour décrémenter le stock)

```php
<?php

namespace App\Http\Controllers;

use App\Models\Vente;
use App\Models\Stock;
use App\Models\Culture;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class VenteController extends Controller
{
    /**
     * Liste toutes les ventes
     */
    public function index(Request $request)
    {
        $query = Vente::where('user_id', $request->user()->id)
            ->with(['stock.culture']);

        // Filtres optionnels
        if ($request->from) {
            $query->whereDate('date_vente', '>=', $request->from);
        }
        if ($request->to) {
            $query->whereDate('date_vente', '<=', $request->to);
        }

        $ventes = $query->orderBy('date_vente', 'desc')
            ->paginate($request->per_page ?? 20);

        return response()->json($ventes);
    }

    /**
     * Créer une nouvelle vente
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'stock_id' => 'required|exists:stocks,id',
            'client' => 'nullable|string|max:255',
            'quantite' => 'required|numeric|min:0.01',
            'prix_unitaire' => 'required|numeric|min:0',
            'montant' => 'required|numeric|min:0',
            'date_vente' => 'required|date',
            'statut' => 'required|string|in:vendu,en_attente',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Vérifier que le stock existe et appartient à l'utilisateur
        $stock = Stock::where('id', $request->stock_id)
            ->whereHas('culture', function ($query) use ($request) {
                $query->where('user_id', $request->user()->id);
            })
            ->first();

        if (!$stock) {
            return response()->json(['message' => 'Stock non trouvé'], 404);
        }

        // Vérifier que le stock est disponible
        if ($stock->disponibilite === 'Sortie') {
            return response()->json([
                'message' => 'Ce stock a déjà été sorti'
            ], 422);
        }

        // Vérifier que la quantité demandée est disponible
        $stockEnKg = $this->convertirEnKg($stock->quantite, $stock->unite);
        $quantiteDemandeeEnKg = $this->convertirEnKg($request->quantite, $stock->unite);

        if ($stockEnKg < $quantiteDemandeeEnKg) {
            return response()->json([
                'message' => 'Stock insuffisant pour cette vente',
                'stock_disponible_kg' => round($stockEnKg, 2),
                'quantite_demandee_kg' => round($quantiteDemandeeEnKg, 2),
                'manquant_kg' => round($quantiteDemandeeEnKg - $stockEnKg, 2),
            ], 422);
        }

        // Créer la vente dans une transaction
        DB::transaction(function () use ($request, $stock, $quantiteDemandeeEnKg, $stockEnKg) {
            // Créer la vente
            $vente = Vente::create([
                'user_id' => $request->user()->id,
                'stock_id' => $request->stock_id,
                'client' => $request->client,
                'quantite' => $request->quantite,
                'prix_unitaire' => $request->prix_unitaire,
                'montant' => $request->montant,
                'date_vente' => $request->date_vente,
                'statut' => $request->statut,
            ]);

            // Décrémenter le stock
            $nouveauStockEnKg = $stockEnKg - $quantiteDemandeeEnKg;
            $nouvelleQuantite = $this->convertirDepuisKg($nouveauStockEnKg, $stock->unite);

            $stock->quantite = $nouvelleQuantite;
            
            if ($nouvelleQuantite <= 0.01) {
                $stock->quantite = 0;
                $stock->disponibilite = 'Sortie';
                $stock->date_sortie = now();
            }

            $stock->save();

            return $vente;
        });

        // Récupérer la vente créée avec les relations
        $vente = Vente::where('stock_id', $request->stock_id)
            ->where('user_id', $request->user()->id)
            ->latest()
            ->first();

        return response()->json([
            'vente' => $vente->load('stock.culture'),
            'message' => 'Vente créée avec succès'
        ], 201);
    }

    /**
     * Afficher une vente
     */
    public function show(Request $request, $id)
    {
        $vente = Vente::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->with('stock.culture')
            ->first();

        if (!$vente) {
            return response()->json(['message' => 'Vente non trouvée'], 404);
        }

        return response()->json($vente);
    }

    /**
     * Mettre à jour une vente
     */
    public function update(Request $request, $id)
    {
        $vente = Vente::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$vente) {
            return response()->json(['message' => 'Vente non trouvée'], 404);
        }

        $validator = Validator::make($request->all(), [
            'statut' => 'sometimes|string|in:vendu,en_attente',
            'client' => 'sometimes|nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $vente->update($validator->validated());

        return response()->json([
            'vente' => $vente->fresh()->load('stock.culture'),
            'message' => 'Vente mise à jour'
        ]);
    }

    /**
     * Supprimer une vente
     */
    public function destroy(Request $request, $id)
    {
        $vente = Vente::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$vente) {
            return response()->json(['message' => 'Vente non trouvée'], 404);
        }

        // Restaurer le stock si la vente est supprimée
        $stock = Stock::find($vente->stock_id);
        if ($stock) {
            $stockEnKg = $this->convertirEnKg($stock->quantite, $stock->unite);
            $quantiteVenteEnKg = $this->convertirEnKg($vente->quantite, $stock->unite);
            
            $nouveauStockEnKg = $stockEnKg + $quantiteVenteEnKg;
            $nouvelleQuantite = $this->convertirDepuisKg($nouveauStockEnKg, $stock->unite);

            $stock->quantite = $nouvelleQuantite;
            $stock->disponibilite = 'Disponible';
            $stock->date_sortie = null;
            $stock->save();
        }

        $vente->delete();

        return response()->json(['message' => 'Vente supprimée']);
    }

    /**
     * Helper: Convertir en kg
     */
    private function convertirEnKg(float $valeur, string $unite): float
    {
        return match ($unite) {
            'kg' => $valeur,
            'tonne' => $valeur * 1000,
            'sac' => $valeur * 50,
            'litre' => $valeur,
            default => $valeur,
        };
    }

    /**
     * Helper: Convertir depuis kg
     */
    private function convertirDepuisKg(float $valeurEnKg, string $uniteCible): float
    {
        return match ($uniteCible) {
            'kg' => $valeurEnKg,
            'tonne' => $valeurEnKg / 1000,
            'sac' => $valeurEnKg / 50,
            'litre' => $valeurEnKg,
            default => $valeurEnKg,
        };
    }
}
```

---

## Migration pour ajouter le champ date_sortie (si nécessaire)

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddDateSortieToStocksTable extends Migration
{
    public function up()
    {
        Schema::table('stocks', function (Blueprint $table) {
            $table->date('date_sortie')->nullable()->after('dateExpiration');
        });
    }

    public function down()
    {
        Schema::table('stocks', function (Blueprint $table) {
            $table->dropColumn('date_sortie');
        });
    }
}
```

---

## Tests API

### Test 1: Récupérer les récoltes d'une culture
```bash
curl -X GET http://localhost:8000/api/recoltes/culture/1 \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Accept: application/json"
```

### Test 2: Total en stock pour une culture
```bash
curl -X GET http://localhost:8000/api/stocks/culture/1/total \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Accept: application/json"
```

### Test 3: Décrémenter le stock
```bash
curl -X PUT http://localhost:8000/api/stocks/1/decrement \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"quantite": 50, "unite": "kg"}'
```

### Test 4: Créer une vente (décrémente automatiquement le stock)
```bash
curl -X POST http://localhost:8000/api/ventes \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "stock_id": 1,
    "client": "Client Example",
    "quantite": 50,
    "prix_unitaire": 1500,
    "montant": 75000,
    "date_vente": "2024-01-15",
    "statut": "vendu"
  }'
