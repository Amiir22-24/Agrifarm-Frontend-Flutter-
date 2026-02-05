# TODO: Correction Erreur fetchStocks - TypeError _JsonMap

## Problème
Erreur: `TypeError: Instance of '_JsonMap': type '_JsonMap' is not a subtype of type 'List<dynamic>'`

Le service `stock_service.dart` assume que l'API retourne toujours une Liste directe, mais le backend peut retourner un objet Map avec pagination `{data: [...]}`.

## Solution
Modifier `getStocks()` dans `stock_service.dart` pour gérer les deux formats de réponse.

## Étapes
- [x] 1. Mettre à jour `stock_service.dart` pour gérer List et Map
- [x] 2. Mettre à jour `stock_provider.dart` pour utiliser directement la liste retournée par le service

## Fichiers modifiés
- `lib/services/stock_service.dart`
- `lib/providers/stock_provider.dart`

## Résumé des modifications
1. **stock_service.dart**: La méthode `getStocks()` vérifie maintenant si la réponse est une Liste ou une Map avec pagination, et retourne toujours `List<Stock>`
2. **stock_provider.dart**: La méthode `fetchStocks()` utilise directement le résultat du service sans再做额外的解析


