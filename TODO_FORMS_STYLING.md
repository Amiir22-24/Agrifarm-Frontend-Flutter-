# TODO: Unifier le style des formulaires comme la section Récolte

## Objectif
Appliquer le style cohérent de la section "Récolte" à tous les formulaires de l'application.

## Formulaires à mettre à jour

### 1. add_vente_screen.dart
- [x] Refondre la structure en Dialog avec borderRadius: 16
- [x] Ajouter un header avec titre vert et bouton fermer
- [x] Appliquer le style des champs (_inputDeco)
- [x] Mettre en page les champs en lignes (2 par ligne)
- [x] Styliser les boutons Annuler/Valider

### 2. stock_screen.dart - AddStockDialog
- [ ] Refondre en Dialog moderne (comme Récolte)
- [ ] Ajouter header avec titre et bouton fermer
- [ ] Appliquer le style des champs
- [ ] Styliser les boutons d'action

### 3. stock_screen.dart - EditStockDialog
- [ ] Refondre en Dialog moderne (comme Récolte)
- [ ] Ajouter header avec titre et bouton fermer
- [ ] Appliquer le style des champs
- [ ] Styliser les boutons d'action

## Style de référence (section Récolte)

### Dialog
- borderRadius: 16
- couleur blanche

### Header
- Titre: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))
- IconButton pour fermer

### Champs de saisie
- borderRadius: 8
- borderSide: Color(0xFFEEEEEE)
- enabledBorder same
- contentPadding: horizontal: 16, vertical: 12

### Labels
- TextStyle(fontWeight: FontWeight.bold, fontSize: 13)

### Boutons
- Annuler: fond blanc, texte noir, BorderSide(color: Color(0xFFEEEEEE))
- Valider: fond Color(0xFF21A84D), texte blanc
- Taille: width: 180, height: 48
- borderRadius: 8

## Progression
- [ ] Commencer avec add_vente_screen.dart
- [ ] Mettre à jour AddStockDialog dans stock_screen.dart
- [ ] Mettre à jour EditStockDialog dans stock_screen.dart

