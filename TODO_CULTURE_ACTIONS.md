# TODO - Intégration des fonctions Modifier et Supprimer pour les cultures

## Modifications terminées ✅

### 1. Modifier `lib/screens/add_culture_screen.dart` ✅
- [x] Ajouter un paramètre optionnel `Culture? culture` au constructeur
- [x] Pré-remplir les champs si c'est une édition
- [x] Changer le titre "Ajouter" → "Modifier"
- [x] Changer le bouton "Ajouter la culture" → "Enregistrer les modifications"
- [x] Implémenter la logique d'ajout ou de modification selon le mode

### 2. Modifier `lib/main.dart` ✅
- [x] Ajouter la route `/edit-culture` avec passage de culture via arguments

### 3. Modifier `lib/screens/cultures_screen.dart` ✅
- [x] Implémenter la logique du bouton Modifier → navigation vers AddCultureScreen en mode édition
- [x] Implémenter la logique du bouton Supprimer → dialog de confirmation + appel provider.deleteCulture
- [x] Ajouter une méthode pour la dialog de confirmation de suppression

## Résumé des modifications

### add_culture_screen.dart
- Le constructeur accepte maintenant un paramètre `Culture? culture` optionnel
- En mode édition (`_isEditing = true`), les champs sont pré-remplis avec les données existantes
- Le titre et le bouton changent dynamiquement selon le mode
- La méthode `_handleSubmit()` gère les deux cas (ajout et modification)

### main.dart
- Ajout de l'import `models/culture.dart`
- Ajout de la route `/edit-culture` qui récupère la culture via les arguments

### cultures_screen.dart
- Ajout de la méthode `_navigateToEditCulture()` pour la navigation vers l'écran d'édition
- Ajout de la méthode `_showDeleteConfirmation()` pour la boîte de confirmation de suppression
- Les boutons Modifier et Supprimer sont maintenant connectés aux fonctions du provider

