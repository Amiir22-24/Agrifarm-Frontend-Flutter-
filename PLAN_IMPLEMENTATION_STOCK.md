# PLAN D'IMPLÉMENTATION - Corrections Stock AgriFarm

## 🎯 OBJECTIF
Corriger les erreurs identifiées dans le modèle Stock et ses implémentations

## 📋 CORRECTIONS À IMPLÉMENTER

### 1. MODÈLE STOCK (lib/models/stock.dart)
**Problèmes actuels :**
- ✅ `cultureId` existe déjà (correct)
- ❌ Validation `quantite` : accepter minimum 0 au lieu de > 0
- ❌ Champs `prix_unitaire` mal gérés
- ❌ `dateAchat` existe déjà (correct)

**Actions :**
- [ ] Améliorer validation `quantite` (> 0)
- [ ] Clarifier la documentation des champs
- [ ] Vérifier la sérialisation JSON

### 2. SERVICE STOCK (lib/services/stock_service.dart)
**Problèmes actuels :**
- ✅ URL `/api/stocks` correct
- ✅ Méthode POST correcte
- ✅ Headers corrects

**Actions :**
- [ ] Ajouter validation côté client
- [ ] Améliorer la gestion d'erreurs
- [ ] Vérifier la sérialisation JSON

### 3. ÉCRAN STOCK (lib/screens/stock_screen.dart)
**Problèmes actuels :**
- ✅ Formulaire `AddStockDialog` correct
- ❌ Validation `quantite` : accepts 0, should be > 0
- ❌ Manque validation `prix_unitaire` stricte

**Actions :**
- [ ] Corriger validation `quantite` (> 0)
- [ ] Améliorer validation `prix_unitaire` (> 0)
- [ ] Clarifier les messages d'erreur

### 4. PROVIDER STOCK (lib/providers/stock_provider.dart)
**Problèmes actuels :**
- [ ] Vérifier la gestion des erreurs
- [ ] Améliorer la validation côté provider

## 🛠️ ÉTAPES D'IMPLÉMENTATION

### Étape 1 : Analyser le code actuel
- [x] Lire le modèle Stock
- [ ] Lire le provider Stock
- [ ] Analyser le formulaire d'ajout

### Étape 2 : Corriger le modèle Stock
- [ ] Améliorer validation `quantite`
- [ ] Clarifier la documentation
- [ ] Corriger sérialisation JSON si nécessaire

### Étape 3 : Corriger le formulaire
- [ ] Corriger validation `quantite` (> 0)
- [ ] Améliorer validation `prix_unitaire`
- [ ] Clarifier messages d'erreur

### Étape 4 : Corriger le provider
- [ ] Améliorer gestion d'erreurs
- [ ] Ajouter validation côté provider

### Étape 5 : Tester les corrections
- [ ] Vérifier que les corrections fonctionnent
- [ ] Tester la création de stock
- [ ] Valider les messages d'erreur

## 📝 FICHIERS À MODIFIER

1. `lib/models/stock.dart`
2. `lib/screens/stock_screen.dart` (AddStockDialog)
3. `lib/providers/stock_provider.dart`
4. `lib/services/stock_service.dart` (si nécessaire)

## ⚠️ POINTS D'ATTENTION

- **Ne pas casser** l'existant
- **Maintenir** la compatibilité avec l'API backend
- **Tester** chaque modification
- **Documenter** les changements
