# Plan de corrections pour la section Vente

## Résumé des modifications demandées

| # | Demande | Fichier(s) concerné(s) |
|---|---------|------------------------|
| 1 | Afficher le produit au lieu du client | `ventes_screen.dart` |
| 2 | Calculer le prix total (prix × qté) | `vente.dart`, `vente_detail_screen.dart` |
| 3 | Bouton Modifier fonctionnel | `vente_detail_screen.dart` |
| 4 | Bouton Supprimer fonctionnel | `vente_detail_screen.dart` |
| 5 | Enlever l'heure de la vue détail | `vente_detail_screen.dart` |
| 6 | Statut: "Vendu", "En attente" | `vente_detail_screen.dart`, `ventes_screen.dart` |
| 7 | Styling comme les autres sections | `ventes_screen.dart`, `vente_detail_screen.dart`, `add_vente_screen.dart` |

---

## Modifications détaillées

### 1. ventes_screen.dart - Afficher le produit au lieu du client

**Actuel:**
```dart
Text(
  vente.client ?? 'Client non spécifié',
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  ),
),
```

**À modifier:**
```dart
final String produit = (vente.stock?.produit ?? 'Produit non spécifié').toString();
Text(
  produit,
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  ),
),
```

### 2. vente_detail_screen.dart - Afficher le prix total calculé

**À ajouter dans le header:**
```dart
Text(
  '${(vente.quantite * vente.prixUnitaire).toStringAsFixed(0)}',
  style: const TextStyle(
    color: Colors.white,
    fontSize: 36,
    fontWeight: FontWeight.bold,
  ),
),
```

### 3. vente_detail_screen.dart - Bouton Modifier fonctionnel

**Implémentation:**
- Créer un `EditVenteDialog` similaire à `EditStockDialog`
- Appeler `VentesProvider.updateVente()`
- Navigation vers l'écran d'édition

### 4. vente_detail_screen.dart - Bouton Supprimer fonctionnel

**Implémentation:**
- Afficher un `AlertDialog` de confirmation
- Appeler `VentesProvider.deleteVente()`
- Retourner à la liste après suppression

### 5. vente_detail_screen.dart - Supprimer l'heure

**À supprimer:**
```dart
_buildDetailRow(
  icon: Icons.access_time_outlined,
  label: 'Heure',
  value: vente.dateVente.toString().split(' ')[1].substring(0, 5),
),
```

### 6. Statut - Changement des labels

**Actuel:**
- 'en_cours' → 'En cours'
- 'termine' → 'Terminée'
- 'annule' → 'Annulée'

**À modifier:**
- 'vendu' → 'Vendu'
- 'en_attente' → 'En attente'

### 7. Styling - Harmoniser avec les autres sections

**Éléments à harmoniser:**
- Header avec dégradé vert
- Cartes avec bordures arrondies
- Boutons avec style consistencia
- Couleurs: `Color(0xFF21A84D)` et `Color(0xFF1B5E20)`

---

## Fichiers à modifier

1. `lib/screens/ventes_screen.dart`
2. `lib/screens/vente_detail_screen.dart`
3. `lib/screens/add_vente_screen.dart` (optionnel, pour harmoniser)
4. `lib/models/vente.dart` (si nécessaire pour le statut)

## Tests à effectuer

- [ ] Les ventes affichent le produit au lieu du client
- [ ] Le montant total est calculé automatiquement
- [ ] Le bouton Modifier ouvre le dialogue d'édition
- [ ] Le bouton Supprimer demande confirmation et supprime
- [ ] L'heure n'apparaît plus dans les détails
- [ ] Les statuts sont "Vendu" et "En attente"
- [ ] L'interface est cohérente avec les autres sections

