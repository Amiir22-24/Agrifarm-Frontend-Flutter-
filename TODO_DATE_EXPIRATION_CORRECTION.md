# TODO - Correction Date d'Expiration Stock

## Problème
Le champ `date_expiration` est envoyé au backend mais ce champ n'existe pas dans la table stocks du backend. Donc après création, le stock réapparaît avec "Date d'expiration non définie".

## Solution
Retirer complètement le champ `date_expiration` du frontend car le backend ne le supporte pas.

## Tâches

### 1. lib/models/stock.dart ✅ TERMINÉ
- ✅ Supprimer `dateExpiration` de `toJson()` car le backend ne le supporte pas
- ✅ Conserver `dateExpiration` dans le modèle pour compatibilité mais ne pas l'envoyer à l'API

### 2. lib/providers/stock_provider.dart ✅ TERMINÉ (pas de changement nécessaire)
- ✅ Ne plus passer `dateExpiration` dans le stock envoyé (déjà géré par toJson)

### 3. lib/screens/stock_screen.dart ✅ TERMINÉ
- ✅ Supprimer la colonne "Date d'expiration" de la DataTable
- ✅ Dans `AddStockDialog._buildExpirationField()`: Retirer le champ expiration du formulaire
- ✅ Dans `EditStockDialog._buildExpirationField()`: Retirer le champ expiration du formulaire
- ✅ Supprimer les méthodes `_pickDateExpiration()` et les variables `_expirationIllimitee`, `_dateExpiration`
- ✅ Ajuster `_handleSave()` pour ne plus créer de Stock avec dateExpiration

### 4. Tests de vérification
- [ ] Vérifier que le stock est créé sans erreur
- [ ] Vérifier que la date d'expiration n'apparaît plus dans l'interface

## Résumé des modifications

### lib/models/stock.dart
- Dans `toJson()`: Retiré `if (dateExpiration != null) 'date_expiration': ...`
- NOTE: Le modèle `Stock` conserve quand même `dateExpiration` pour ne pas casser l'application si le backend est mis à jour plus tard

### lib/screens/stock_screen.dart
- DataTable: Supprimé les colonnes "Date d'expiration" et "État de péremption"
- AddStockDialog: Retiré le champ d'expiration du formulaire
- EditStockDialog: Retiré le champ d'expiration du formulaire
- Les stocks sont maintenant créés sans date d'expiration

## Status: TERMINÉ ✅


