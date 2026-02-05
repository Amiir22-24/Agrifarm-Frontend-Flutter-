# TODO - Correction de la section Stocks

## Problèmes identifiés:
1. ❌ Le prix unitaire ne s'affiche pas
2. ❌ Le prix total par stock ne s'affiche pas
3. ❌ Le prix total des stocks affiche "N/A"
4. ❌ Affiche "Stock #ID" au lieu du nom du produit

## Fichiers à modifier:
1. `lib/models/stock.dart` - Corriger le parsing JSON
2. `lib/providers/stock_provider.dart` - Améliorer l'association culture-stock
3. `lib/screens/stock_screen.dart` - Améliorer l'affichage des prix

## Plan d'action:

### Étape 1: Corriger lib/models/stock.dart
- [ ] Corriger le parsing de `cultureId` (utiliser `culture_id` au lieu de `produit`)
- [ ] Améliorer le parsing du prix unitaire
- [ ] Améliorer le getter `produit` pour afficher le nom de la culture

### Étape 2: Corriger lib/providers/stock_provider.dart
- [ ] Améliorer `_associateCulturesToStocks()` pour meilleure association
- [ ] Ajouter un debug plus complet pour voir les données reçues

### Étape 3: Corriger lib/screens/stock_screen.dart
- [ ] Améliorer l'affichage du prix unitaire
- [ ] Améliorer l'affichage de la valeur totale
- [ ] Améliorer l'affichage du prix total des stocks

## Status: EN COURS

