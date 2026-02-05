# TODO - Correction de l'affichage des rapports IA

## Problème
Rien ne s'affiche lorsque l'utilisateur soumet une génération de rapport via le bouton 'Générer IA et le formulaire'.

## Corrections à apporter

### 1. Améliorer le dialogue de génération (_GenerateRapportDialog)
- [ ] Afficher un indicateur de chargement (GenerationLoading) pendant la génération
- [ ] Ne pas fermer le dialogue avant la fin de la génération
- [ ] Ajouter une validation du formulaire (période obligatoire)
- [ ] Améliorer la gestion des erreurs avec un message visible
- [ ] Garder le dialogue ouvert en cas d'erreur pour permettre une nouvelle tentative

### 2. Améliorer le rapport_provider.dart
- [ ] Initialiser `_filteredRapports` au démarrage si vide

### 3. Améliorer le rapport_screen_responsive.dart
- [ ] Ajouter un indicateur de chargement global pendant isGenerating
- [ ] Afficher un message d'erreur plus visible en haut de l'écran

## Plan d'implémentation

### Étape 1: Créer le fichier TODO.md
- [x] Créer ce fichier pour suivre le progrès

### Étape 2: Corriger le dialogue de génération
- [ ] Modifier `_GenerateRapportDialogState` dans `rapport_screen_responsive.dart`
- [ ] Ajouter un état `bool _isGenerating = false`
- [ ] Afficher un dialogue de chargement pendant la génération
- [ ] Gérer les erreurs avec un message affiché
- [ ] Ajouter une validation de formulaire

### Étape 3: Corriger le rapport_provider.dart
- [ ] Initialiser `_filteredRapports` dans `fetchRapports()` si vide

### Étape 4: Ajouter un indicateur de chargement global
- [ ] Modifier `_buildMainContent()` pour afficher un indicateur pendant isGenerating

## Fichiers à modifier
- `lib/screens/rapport_screen_responsive.dart` - Dialogue de génération
- `lib/providers/rapport_provider.dart` - Initialisation des filtres

