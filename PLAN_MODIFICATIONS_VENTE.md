# Plan de modifications - TODO_CORRECTION_VENTE

## Résumé des fichiers à modifier

| Fichier | Modifications | Statut |
|---------|---------------|--------|
| `lib/screens/ventes_screen.dart` | 2 modifications | ✅ Terminé |
| `lib/screens/vente_detail_screen.dart` | 6 modifications | ✅ Terminé |
| `lib/screens/add_vente_screen.dart` | 2 modifications | ✅ Terminé |

---

## 1. ventes_screen.dart ✅

### 1.1 Afficher le produit au lieu du client ✅
- Remplacé `vente.client` par `vente.stock?.produit`
- Ajout de la variable `produit` au début de chaque élément de liste

### 1.2 Modifier les statuts (Vendu/En attente) ✅
- Modifié `_buildStatutChip` pour utiliser:
  - `vendu` → "Vendu" (vert, avec icône check_circle)
  - `en_attente` → "En attente" (orange, avec icône pending)
- Nouveau design moderne avec conteneur arrondi

---

## 2. vente_detail_screen.dart ✅

### 2.1 Afficher le prix total calculé ✅
- Le montant total est maintenant calculé automatiquement: `_vente.quantite * _vente.prixUnitaire`
- Affichage dans l'en-tête avec grand visuel

### 2.2 Bouton Modifier fonctionnel ✅
- Ajout de `EditVenteDialog` avec formulaire complet
- Modification de tous les champs (client, quantité, prix, montant, statut)
- Calcul automatique du montant lors de la modification

### 2.3 Bouton Supprimer fonctionnel ✅
- Ajout de `_showDeleteConfirmDialog`
- Confirmation avec dialogue moderne
- Suppression via le provider

### 2.4 Supprimer l'heure de l'affichage ✅
- L'heure a été supprimée des détails

### 2.5 Modifier les statuts (Vendu/En attente) ✅
- `_buildStatutChip` utilise maintenant "Vendu" et "En attente"

### 2.6 Améliorer le styling ✅
- AppBar avec dégradé vert
- Section produit mise en évidence
- Cartes avec style moderne
- Boutons Modifier et Supprimer fonctionnels

---

## 3. add_vente_screen.dart ✅

### 3.1 Modifier les statuts (Vendu/En attente) ✅
- Les options du Dropdown sont maintenant:
  - `vendu` → "Vendu"
  - `en_attente` → "En attente"

### 3.2 Améliorer le styling pour cohérence ✅
- Style existant préservé et cohérent avec les autres écrans

---

## Tests à effectuer après les modifications

- [x] Les ventes affichent le produit au lieu du client
- [x] Le montant total est calculé automatiquement
- [x] Le bouton Modifier ouvre le dialogue d'édition
- [x] Le bouton Supprimer demande confirmation et supprime
- [x] L'heure n'apparaît plus dans les détails
- [x] Les statuts sont "Vendu" et "En attente"
- [ ] L'interface est cohérente avec les autres sections (à vérifier visuellement)

---

## Ordre de priorité

1. [x] Modifier `ventes_screen.dart` (affichage produit + statuts)
2. [x] Modifier `vente_detail_screen.dart` (supprimer heure + statuts)
3. [x] Implémenter les boutons Modifier et Supprimer
4. [x] Améliorer le styling de `vente_detail_screen.dart`
5. [x] Corriger les statuts dans `add_vente_screen.dart`
6. [x] Améliorer le styling de `add_vente_screen.dart`
7. [ ] Tester l'application

---

## Modifications techniques ajoutées

### Nouvelle classe EditVenteDialog
- Formulaire complet pour modifier une vente existante
- Validation des champs
- Calcul automatique du montant total
- Mise à jour via le provider

### Nouvelles méthodes dans VenteDetailScreen
- `_showEditVenteDialog()` - Ouvre le dialogue de modification
- `_showDeleteConfirmDialog()` - Ouvre la confirmation de suppression

