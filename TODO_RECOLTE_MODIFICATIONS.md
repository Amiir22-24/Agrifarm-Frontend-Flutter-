# TODO - Modifications Section Récolte

## Objectifs:
1. ✅ Supprimer les champs "Destination" et "Prix total" du formulaire de création
2. ✅ Rendre le bouton "Modifier" fonctionnel

## Tâches:

### 1. Modifier `lib/screens/recoltes_screen.dart`
- [x] 1.1 Supprimer `_prixVenteController` et `_destination`
- [x] 1.2 Supprimer les champs Destination et Prix total du formulaire AddRecolteDialog
- [x] 1.3 Créer EditRecolteDialog avec pré-remplissage des données
- [x] 1.4 Connecter le bouton edit pour ouvrir EditRecolteDialog

### 2. Modifier `lib/models/recolte.dart`
- [x] 2.1 Garder les champs optionnels pour compatibilité (pas de changement nécessaire)

### 3. Tester les modifications
- [ ] 3.1 Vérifier que le formulaire de création ne contient plus Destination et Prix total
- [ ] 3.2 Vérifier que le bouton Modifier ouvre le dialogue avec les données

## Progression:
- [x] Analyse et plan validés par l'utilisateur
- [x] Modifications implémentées
- [ ] Tests de validation en attente

