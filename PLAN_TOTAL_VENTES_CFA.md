# Plan d'implémentation - Total des ventes en Franc CFA

## Objectif
Afficher le montant total des ventes en Franc CFA (XOF) sur le tableau de bord utilisateur.

## Analyse

### Situation actuelle
- Le backend retourne des nombres bruts (ex: 1500.50) sans devise
- Le frontend formate actuellement en EUR avec `Intl.NumberFormat`
- Pour AgriFarm (Afrique de l'Ouest), il faut afficher en XOF (Franc CFA)

### Fichiers concernés
1. `lib/utils/constants.dart` - Ajouter constante XOF et fonction de formatage
2. `lib/providers/ventes_provider.dart` - Ajouter propriété `totalRevenueCFA`
3. `lib/screens/home_screen.dart` - Modifier l'affichage pour CFA dans la carte Ventes

## Plan d'implémentation

### Étape 1: Ajouter constantes et fonctions de formatage CFA
**Fichier:** `lib/utils/constants.dart`

```dart
// Constante pour le taux de change (EUR vers XOF)
const double XOF_PER_EUR = 655.957; // Taux fixe BCEAO

// Fonction pour formatter un montant en Franc CFA
String formatCFA(double amount) {
  final int amountCFA = (amount * XOF_PER_EUR).round();
  return '${NumberFormat('#,###', 'fr_FR').format(amountCFA)} XOF';
}
```

### Étape 2: Ajouter propriété totalRevenueCFA dans le provider
**Fichier:** `lib/providers/ventes_provider.dart`

```dart
// Après totalRevenue existant
double get totalRevenueCFA => totalRevenue * XOF_PER_EUR;
```

### Étape 3: Modifier l'affichage dans la carte Ventes
**Fichier:** `lib/screens/home_screen.dart` - Méthode `_buildVentesCard()`

Modifier cette partie:
```dart
Row(
  children: [
    const Icon(Icons.attach_money, size: 16, color: Colors.blue),
    const SizedBox(width: 4),
    Text(
      isLoading ? "..." : "${totalRevenue.toStringAsFixed(0)}€",
      style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.bold),
    ),
  ],
),
```

En:
```dart
Row(
  children: [
    const Icon(Icons.attach_money, size: 16, color: Colors.blue),
    const SizedBox(width: 4),
    Text(
      isLoading ? "..." : formatCFA(totalRevenue),
      style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.bold),
    ),
  ],
),
```

## Remarques importantes

1. **Pas de décimales en CFA**: Le franc CFA n'utilise pas de centimes (0.01 n'existe pas)
2. **Taux de change fixe**: Le taux EUR/XOF est fixe à ~656
3. **Séparation des milliers**: Utiliser le format français avec des espaces

## Fichiers à modifier

| Fichier | Modification |
|---------|-------------|
| `lib/utils/constants.dart` | Ajouter constante XOF et fonction `formatCFA()` |
| `lib/providers/ventes_provider.dart` | Ajouter `totalRevenueCFA` getter |
| `lib/screens/home_screen.dart` | Changer l'affichage € vers XOF |

## Tests à vérifier

- [ ] Le total s'affiche correctement en XOF
- [ ] Les milliers sont séparés par des espaces
- [ ] Pas de décimales après le montant
- [ ] L'indicateur de chargement s'affiche pendant le chargement

