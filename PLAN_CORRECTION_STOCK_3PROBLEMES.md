# PLAN DE CORRECTION - PROBLÈMES STOCK

## Problèmes identifiés

### 1. Supprimer la case "types et somme des stocks"
**Fichier**: `lib/screens/stock_screen.dart`
**Problème**: La carte "Valeur estimée" avec "${stocks.length} types" n'est pas utile
**Solution**: Supprimer cette carte statistique

### 2. Afficher immédiatement le nom du produit lors de la création
**Fichiers**: 
- `lib/models/stock.dart`
- `lib/providers/stock_provider.dart`
- `lib/screens/stock_screen.dart` (AddStockDialog)

**Problème**: Lors de la création d'un stock, "Stock + id" s'affiche car la culture n'est pas associée immédiatement
**Solution**: 
- Ajouter un champ `produitNom` dans le modèle Stock
- Stocker le nom de la culture sélectionnée temporairement lors de la création
- Utiliser ce nom pour l'affichage immédiat

### 3. Corriger l'enregistrement de la date d'expiration
**Fichiers**:
- `lib/models/stock.dart` (toJson)
- `lib/providers/stock_provider.dart` (addStock)
- `lib/screens/stock_screen.dart` (AddStockDialog)

**Problème**: Quand un statut différent de "Expiration illimitée" est sélectionné, la date n'est pas sauvegardée
**Solution**: 
- Vérifier que `dateExpiration` est correctement transmise dans le JSON
- S'assurer que le format ISO 8601 est respecté
- Ajouter des logs de débogage pour tracer la date

---

## Fichiers à modifier

### 1. lib/models/stock.dart
- [ ] Ajouter champ `produitNom` pour stocker le nom temporairement
- [ ] Modifier `produitNom` getter pour utiliser ce champ en priorité
- [ ] Vérifier que `toJson()` envoie `date_expiration` correctement

### 2. lib/providers/stock_provider.dart
- [ ] Dans `addStock()`, associate la culture au nouveau stock avant de l'ajouter à la liste
- [ ] Ajouter debug logs pour tracer la date d'expiration

### 3. lib/screens/stock_screen.dart
- [ ] Supprimer la carte "Valeur estimée" (lignes ~75-82)
- [ ] Dans `AddStockDialog`, passer le nom de la culture sélectionnée au Stock créé
- [ ] Vérifier que `_expirationIllimitee` et `_dateExpiration` sont correctement gérés

---

## Ordre de correction

1. Supprimer la carte "Valeur estimée" (changement simple)
2. Ajouter le support du nom de produit temporaire (modèle + provider + dialog)
3. Corriger l'envoi de la date d'expiration (provider + service)

