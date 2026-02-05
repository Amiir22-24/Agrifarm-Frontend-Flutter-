# TODO - Ventes Corrections

## Objectif
Corriger 3 problèmes dans la section Ventes:
1. ✅ Ajouter un arrière-plan flou (blur) au formulaire de vente
2. ✅ Corriger la navigation après l'enregistrement d'une vente
3. ✅ Afficher le nom du produit au lieu de "Produit #ID"

---

## Problème 1: Arrière-plan flou pour le formulaire de vente ✅ CORRIGÉ

### Fichier modifié
- `lib/screens/add_vente_screen.dart`

### Changements effectués
- Enveloppé le Dialog avec un Stack
- Ajouté un BackdropFilter pour l'effet de flou (ImageFilter.blur)
- Ajouté un Container avec color: Colors.black.withOpacity(0.3)
- Ajouté une ombre (boxShadow) au dialog pour l'effet de profondeur

---

## Problème 2: Navigation incorrecte après enregistrement ✅ CORRIGÉ

### Fichier modifié
- `lib/screens/add_vente_screen.dart`

### Changements effectués
- Remplacé `Navigator.of(context).pushNamedAndRemoveUntil(...)` par `Navigator.pop(context)`
- Cela ferme simplement le dialogue et retourne à l'écran précédent

### Code avant:
```dart
// ❌ PROBLÉMATIQUE - Cause une navigation superflue
Navigator.of(context).pushNamedAndRemoveUntil(
  '/ventes', 
  (Route<dynamic> route) => route.isFirst,
);
```

### Code après:
```dart
// ✅ SIMPLE - Retourne à l'écran précédent
Navigator.pop(context);
```

---

## Problème 3: Affichage du nom du produit ✅ CORRIGÉ

### Fichiers modifiés
- `lib/screens/ventes_screen.dart` - Méthode `_getProductName` (2 occurrences)
- `lib/screens/vente_detail_screen.dart` - Méthode `_getCultureName`

### Logique de priorité améliorée:
1. stock?.culture?.nom
2. stock?.culture?.type
3. stock?.produitNomValue
4. Chercher dans StockProvider.stocks
5. Chercher dans CulturesProvider via stock.produit
6. "Produit #$stockId" (dernier recours)

---

## Tests à effectuer
1. ✅ Ouvrir le formulaire d'ajout de vente - L'arrière-plan doit être flou
2. ✅ Enregistrer une vente - La page des ventes doit s'afficher directement
3. ✅ Cliquer sur une vente pour voir les détails - Le nom du produit doit s'afficher correctement

