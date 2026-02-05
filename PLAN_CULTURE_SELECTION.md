# Plan d'Amélioration - Sélection des Cultures par Nom

## Objectif
Améliorer l'interface des récoltes pour permettre la sélection des cultures par leur nom au lieu de leur ID, et afficher les noms des cultures dans la liste des récoltes.

## Analyse de la Structure Actuelle

### ✅ Points Forts
- Le modèle `Recolte` contient déjà un champ `culture` optionnel
- Le `RecolteProvider` gère déjà les données de récoltes
- Le `CulturesProvider` gère la liste des cultures
- Le service de récoltes charge déjà les informations de culture avec les données

### 🔧 Problèmes Identifiés
1. **Formulaire d'ajout de récolte** : Utilise un champ TextField pour l'ID au lieu d'un dropdown
2. **Sélection de culture** : Pas d'interface intuitive pour choisir une culture
3. **Affichage** : Fonctionne déjà correctement (affiche le nom si disponible)

## Plan d'Implémentation

### 1. Modifier l'écran des récoltes (`lib/screens/recoltes_screen.dart`)
- [ ] Ajouter l'import du CulturesProvider
- [ ] Remplacer le champ "ID de la culture" par un DropdownButtonFormField
- [ ] Charger les cultures au niveau de l'écran
- [ ] Synchroniser la sélection de culture avec l'ID

### 2. Améliorer l'expérience utilisateur
- [ ] Ajouter des indicateurs de chargement pour les cultures
- [ ] Gérer les cas où aucune culture n'est disponible
- [ ] Ajouter une validation pour s'assurer qu'une culture est sélectionnée

### 3. Tester la cohérence
- [ ] Vérifier que les cultures sont correctement liées aux récoltes
- [ ] S'assurer que l'affichage fonctionne dans les deux sens (création/affichage)

## Détails Techniques

### Modifications du formulaire AddRecolteDialog
```dart
// Remplacer:
TextFormField(
  controller: _cultureIdController,
  decoration: const InputDecoration(labelText: 'ID de la culture *'),
  keyboardType: TextInputType.number,
)

// Par:
DropdownButtonFormField<int>(
  value: _selectedCultureId,
  decoration: const InputDecoration(labelText: 'Culture *'),
  items: cultures.map((culture) => 
    DropdownMenuItem(
      value: culture.id,
      child: Text('${culture.nom} (${culture.type})'),
    )
  ).toList(),
)
```

### Gestion des providers
- Charger les cultures dans `_RecoltesScreenState`
- Passer la liste des cultures au AddRecolteDialog
- Synchroniser les states

## Étapes de Test
1. Créer quelques cultures de test
2. Ajouter une récolte en sélectionnant une culture par son nom
3. Vérifier que la récolte s'affiche avec le bon nom de culture
4. Tester les cas limites (aucune culture disponible)
