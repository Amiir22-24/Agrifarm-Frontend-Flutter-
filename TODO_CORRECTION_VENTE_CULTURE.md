# TODO - Correction de l'affichage du nom de culture dans les ventes

## Objectif
Le nom de la culture en stock vendu ne s'affiche pas dans la section vente lorsque l'utilisateur crée une vente.

## Analyse du problème
1. Lorsque la vente est créée, le backend peut ne pas retourner l'objet `stock` complet avec la relation `culture` imbriquée
2. Le code actuel dans `ventes_screen.dart` essaie d'obtenir le nom via `vente.stock?.culture?.nom`, mais si `culture` est null, il revient à `vente.stock?.produitNomValue` qui est aussi null pour les ventes动态 created
3. Il n'y a pas de mécanisme de fallback pour récupérer les données de culture manquantes

## Plan d'implémentation

### Étape 1: Modifier `lib/screens/ventes_screen.dart`
- Ajouter l'accès à `CulturesProvider` pour récupérer le nom de la culture par ID
- Implémenter une meilleure logique de fallback:
  - Priorité 1: `vente.stock?.culture?.nom` (relation déjà chargée)
  - Priorité 2: Chercher dans `CulturesProvider` en utilisant `vente.stock?.produit` (cultureId)
  - Priorité 3: Afficher un nom générique avec l'ID

### Étape 2: Vérifier `lib/models/vente.dart`
- S'assurer que le parsing JSON inclut correctement la relation `stock->culture`
- Le code actuel semble correct, mais vérifions

### Étape 3: Tester l'affichage
- Vérifier que le nom de la culture s'affiche correctement après la création d'une vente

## Fichiers à modifier
- `lib/screens/ventes_screen.dart` - Correction principale
- `lib/models/vente.dart` - Vérification (peut-être pas nécessaire)

## Statut
- [x] Étape 1: Modifier ventes_screen.dart - AJOUTÉ: Import CulturesProvider, méthode _loadCulturesIfNeeded(), méthode _getCultureName() avec fallback multiple
- [x] Étape 2: Vérifier vente.dart - Non nécessaire, le parsing est déjà correct
- [x] Étape 3: Modifier vente_detail_screen.dart - AJOUTÉ: même logique de fallback pour l'affichage du détail

