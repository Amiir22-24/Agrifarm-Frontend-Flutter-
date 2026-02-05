# TODO - Correction DEBUG ADD STOCK

## Problème
Erreur 422 lors de la création d'un stock:
- `produit: [The produit field must be a string.]`
- `disponibilite: [The disponibilite field is required.]`

## Causes
1. Le champ `produit` est envoyé comme entier (int), mais le backend attend une chaîne (string)
2. Le champ `disponibilite` n'est pas envoyé - le code envoie `statut` à la place

## Solution
Modifier la méthode `toJson()` dans `lib/models/stock.dart`:
- Convertir `produit` en string
- Remplacer `'statut': disponibilite` par `'disponibilite': disponibilite`

## Étapes
- [x] Analyser le code source et identifier les fichiers à modifier
- [x] Corriger la méthode `toJson()` dans `lib/models/stock.dart`
- [x] Tester la création d'un stock

## Modifications apportées

### Fichier: `lib/models/stock.dart`

**Méthode `toJson()` - Avant:**
```dart
'produit': produit, // Conserver en int pour le backend
'statut': disponibilite, // Le backend attend 'statut' et non 'disponibilite'
```

**Méthode `toJson()` - Après:**
```dart
// Le backend attend 'produit' comme string (ID de la culture)
'produit': produit.toString(),
// Le backend attend 'disponibilite' et non 'statut'
'disponibilite': disponibilite,
```

## Résumé des corrections
1. **`produit`**: Converti de `int` vers `String` avec `produit.toString()`
2. **`disponibilite`**: Le champ était mal nommé `statut`, corrigé en `disponibilite`

