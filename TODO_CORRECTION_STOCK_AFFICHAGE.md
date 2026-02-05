# TODO - Corrections Section Stocks

## Étape 1: Corriger lib/models/stock.dart
- [ ] Améliorer le getter `produit` pour afficher le nom de la culture
- [ ] Améliorer le parsing de `prixUnitaire` pour gérer différents formats du backend

## Étape 2: Corriger lib/providers/stock_provider.dart
- [ ] Ajouter un getter `totalValeur` avec gestion des valeurs infinies

## Étape 3: Corriger lib/screens/stock_screen.dart
- [ ] Utiliser `provider.totalValeur` pour le calcul
- [ ] Améliorer l'affichage des prix avec gestion des valeurs nulles
- [ ] Améliorer l'affichage du nom du produit avec Tooltip

## Tests après correction
- [ ] Le nom de la culture s'affiche correctement
- [ ] Le prix unitaire s'affiche pour chaque stock
- [ ] Le prix total (quantité × prix unitaire) s'affiche
- [ ] La valeur totale du stock s'affiche correctement dans les statistiques

