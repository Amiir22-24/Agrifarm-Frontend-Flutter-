# PLAN DE CORRECTION - Section Stocks

## Problèmes identifiés

### 1. Prix unitaire et prix total non affichés
- **Cause possible**: Le modèle `Stock.fromJson` ne récupère pas correctement `prix_unitaire` du backend
- Le backend pourrait retourner un champ différent ou le parsing échoue

### 2. Prix total des stocks non affiché
- **Cause possible**: Si `prixUnitaire` est 0, alors `valeurTotale` sera aussi 0
- Le calcul `stocks.fold(0.0, (sum, stock) => sum + stock.valeurTotale)` dépend de la valeur de `valeurTotale`

### 3. Affichage "Stock + ID" au lieu du nom du produit
- **Cause**: La propriété `produit` du modèle retourne parfois "Stock ${cultureId}" au lieu du nom de la culture
- Le problème est dans le getter `produit` qui ne trouve pas le nom de la culture

## Modifications à apporter

### Fichier: `lib/models/stock.dart`

#### A. Améliorer le getter `produit` pour afficher le nom de la culture
```dart
String get produit {
  // Priorité 1: Si culture.nom existe et n'est pas vide
  if (culture?.nom != null && culture!.nom.isNotEmpty) {
    return culture!.nom;
  }
  // Priorité 2: Sinon utiliser la description
  if (description != null && description!.isNotEmpty) {
    return description!;
  }
  // Priorité 3: Sinon afficher "Stock #ID"
  return 'Stock #${id ?? cultureId}';
}
```

#### B. Améliorer le parsing de `prixUnitaire` pour gérer différents formats du backend
```dart
double get _parsePrixUnitaire {
  final value = json['prix_unitaire'];
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String && value.isNotEmpty) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
  }
  return 0.0;
}
```

### Fichier: `lib/providers/stock_provider.dart`

#### C. Ajouter un getter `totalValeur` qui calcule correctement
```dart
double get totalValeur {
  return _stocks.fold(0.0, (sum, stock) {
    final valeur = stock.quantite * stock.prixUnitaire;
    return sum + (valeur.isFinite ? valeur : 0.0);
  });
}
```

#### D. Ajouter un getter `nombreStocks`
```dart
int get nombreStocks => _stocks.length;
```

### Fichier: `lib/screens/stock_screen.dart`

#### E. Améliorer l'affichage des prix avec gestion des valeurs nulles
```dart
// Au lieu de:
DataCell(Text("${stock.prixUnitaire.toStringAsFixed(2)} €")),

// Utiliser:
DataCell(Text(stock.prixUnitaire > 0 
  ? "${stock.prixUnitaire.toStringAsFixed(2)} €" 
  : "N/A")),
```

#### F. Améliorer le calcul du total valeur dans le build
```dart
final totalValeur = provider.totalValeur;
```

#### G. Améliorer l'affichage du nom du produit dans le tableau
```dart
DataCell(
  Tooltip(
    message: stock.description ?? '',
    child: Text(
      stock.produit,
      style: const TextStyle(fontWeight: FontWeight.w500),
    ),
  ),
),
```

## Fichiers à modifier

1. `lib/models/stock.dart` - Améliorer le getter `produit` et le parsing
2. `lib/providers/stock_provider.dart` - Ajouter les getters calculés
3. `lib/screens/stock_screen.dart` - Améliorer l'affichage des prix

## Tests à effectuer après correction

1. Vérifier que le nom de la culture s'affiche correctement
2. Vérifier que le prix unitaire s'affiche pour chaque stock
3. Vérifier que le prix total (quantité × prix unitaire) s'affiche
4. Vérifier que la valeur totale du stock s'affiche correctement dans les statistiques

