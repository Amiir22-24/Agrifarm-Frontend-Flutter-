# TODO - Séparation Péremption et Disponibilité Stock

## Modèle Stock (`lib/models/stock.dart`)
- [x] Ajouter champ `disponibilite` (valeurs: "Disponible", "Sortie", "Réservé")
- [x] Créer propriété calculée `peremptionStatut` avec nouvelle logique
- [x] Logique péremption:
  - Bon état: intervalle > 15 jours
  - Presque expiré: intervalle entre 15 et 1 jour
  - Expiré: date jour >= date_expiration

## StockProvider (`lib/providers/stock_provider.dart`)
- [x] Mettre à jour getters de comptage pour utiliser `peremptionStatut`
- [x] Mise à jour validation pour champ `disponibilite`

## StockScreen (`lib/screens/stock_screen.dart`)
- [x] Ajouter colonne "Disponibilité" (donnée stockée)
- [x] Ajouter colonne "État de péremption" (calculé automatiquement)
- [x] Modifier AddStockDialog pour inclure sélection disponibilité
- [x] Modifier EditStockDialog pour inclure sélection disponibilité

## StockService (`lib/services/stock_service.dart`)
- [x] Mettre à jour parsing JSON pour nouveau champ `disponibilite`

