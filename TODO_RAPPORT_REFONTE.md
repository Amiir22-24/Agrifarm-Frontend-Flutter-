# TODO - Refonte Section Rapports Style Professionnel

## 🎯 Objectif
Refondre `lib/screens/rapport_screen.dart` avec un style professionnel conforme aux autres écrans de l'application.

## 📋 Tâches à Accomplir

### Phase 1: Structure de Base
- [ ] Créer le header avec titre et sous-titre
- [ ] Implémenter les 2 cartes statistiques
- [ ] Configurer le scaffold avec fond gris

### Phase 2: Section Filtres
- [ ] Barre de recherche stylisée
- [ ] Chips de période (Tous, Jour, Semaine, Mois)
- [ ] Bouton de réinitialisation

### Phase 3: Liste des Rapports
- [ ] Card professionnelle pour chaque rapport
- [ ] Affichage des métadonnées (date, température, humidité)
- [ ] Chip de période colorée
- [ ] Gestion de l'état vide

### Phase 4: Dialog de Génération
- [ ] Dialog redesigné selon le style AgriFarm
- [ ] Radio buttons pour la période
- [ ] Champ titre optionnel
- [ ] Boutons Annuler/Générer

### Phase 5: Actions et Navigation
- [ ] Bouton flottant (FAB) stylisé
- [ ] Navigation vers l'écran de détail
- [ ] Gestion du chargement et des erreurs

### Phase 6: Écran de Détail
- [ ] Créer `RapportDetailScreen` professionnel
- [ ] Affichage structuré du contenu
- [ ] Métadonnées et conditions météo

## 📁 Fichiers à Modifier
| Fichier | Action |
|---------|--------|
| `lib/screens/rapport_screen.dart` | Refonte complète |

## 🎨 Design System Appliqué
- **Couleur primaire** : `Color(0xFF21A84D)` / `Color(0xFF1B5E20)`
- **Fond** : `Color(0xFFF8F9FA)`
- **Cartes** : Blanc avec bordure `Color(0xFFEEEEEE)`
- **Coins arrondis** : `BorderRadius.circular(16)`
- **Padding écran** : `EdgeInsets.all(24.0)`
- **Titre** : 28px bold
- **Sous-titre** : 14px gris

## 🚀 Progression

```
Phase 1: [          ] 0%
Phase 2: [          ] 0%
Phase 3: [          ] 0%
Phase 4: [          ] 0%
Phase 5: [          ] 0%
Phase 6: [          ] 0%
```

## 📝 Notes
- Pas de notifications dans les rapports
- Style cohérent avec cultures_screen.dart et stock_screen.dart
- Responsive design inclus

---

*Créé le ${DateTime.now().toString()}*

