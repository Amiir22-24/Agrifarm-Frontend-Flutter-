# TODO - Implémentation Stock/Récolte/Vente

## ✅ TÂCHES TERMINÉES

### 1. Utilitaire de conversion d'unités
- [x] Créer `lib/utils/unit_converter.dart`
- [x] Implémenter `convert()` - conversion entre kg et tonne
- [x] Implémenter `toKg()` - conversion vers kg
- [x] Implémenter `fromKg()` - conversion depuis kg
- [x] Implémenter `calculerDecrement()` - vérification stock pour vente
- [x] Implémenter `formaterOptimise()` - affichage optimisé

### 2. StockProvider - Nouvelles méthodes
- [x] Ajouter `_recoltes` et méthodes associées
- [x] Implémenter `getTotalRecolteForCulture()` - total récolté en kg
- [x] Implémenter `getTotalStockForCulture()` - total en stock en kg
- [x] Implémenter `canCreateStock()` - vérifier si stock ≤ récolte
- [x] Implémenter `canSell()` - vérifier si stock suffisant pour vente
- [x] Implémenter `decrementStock()` - décrémenter après vente

### 3. VentesProvider - Validation de stock
- [x] Ajouter `canSell()` - vérification stock avant vente
- [x] Modifier `addVente()` - validation avec stocks

### 4. AddVenteScreen - Validation et décrémentation
- [x] Ajouter vérification de stock avant soumission
- [x] Afficher message d'erreur détaillé si stock insuffisant
- [x] Appeler `decrementStock()` après vente réussie

## 📋 TÂCHES EN COURS / À FAIRE

### Backend (Laravel)
- [ ] Créer endpoint `GET /api/recoltes/culture/{cultureId}` pour récupérer les récoltes d'une culture
- [ ] Créer endpoint `GET /api/stocks/culture/{cultureId}/total` pour le total en stock
- [ ] Créer endpoint `PUT /api/stocks/{id}/decrement` pour décrémenter le stock après vente

### Tests
- [ ] Tester la conversion d'unités (kg ↔ tonne)
- [ ] Tester la vérification de stock pour vente
- [ ] Tester la décrémentation automatique
- [ ] Tester l'affichage des messages d'erreur

## 📝 NOTES

### Format des données de stock
```json
{
  "id": 1,
  "produit": 1,
  "quantite": 100,
  "unite": "kg",
  "disponibilite": "Disponible"
}
```

### Format des données de récolte
```json
{
  "id": 1,
  "culture_id": 1,
  "quantite": 500,
  "unite": "kg",
  "date_recolte": "2024-01-15"
}
```

### Validation de stock
- Avant une vente: vérifier que `quantiteVendue ≤ stockActuel`
- Après une vente réussie: décrémenter le stock de `quantiteVendue`
- Si stock devient ≤ 0: marquer comme "Sorti"
