# TODO - Correction des 3 problèmes de stock

## Problème 1: Supprimer la carte "Valeur estimée"
- [ ] Modifier `lib/screens/stock_screen.dart` - Supprimer les lignes de la carte "Valeur estimée"

## Problème 2: Afficher immédiatement le nom du produit
- [ ] Modifier `lib/models/stock.dart` - Ajouter champ `produitNom` et modifier getter
- [ ] Modifier `lib/providers/stock_provider.dart` - Associer culture après création du stock
- [ ] Modifier `lib/screens/stock_screen.dart` (AddStockDialog) - Passer le nom de la culture

## Problème 3: Corriger l'enregistrement de la date d'expiration
- [ ] Vérifier que `dateExpiration` est correctement envoyé dans `stock_service.dart`
- [ ] Ajouter debug logs si nécessaire

---

## Progression
- [ ] Étape 1: Supprimer carte "Valeur estimée" ✅ EN ATTENTE
- [ ] Étape 2: Ajouter champ produitNom dans Stock model ✅ EN ATTENTE
- [ ] Étape 3: Modifier provider pour association immédiate ✅ EN ATTENTE
- [ ] Étape 4: Passer nom culture dans AddStockDialog ✅ EN ATTENTE
- [ ] Étape 5: Vérifier envoi date expiration ✅ EN ATTENTE

