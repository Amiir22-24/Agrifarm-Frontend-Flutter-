# 📋 PLAN DE DIAGNOSTIC ET CORRECTION DES ERREURS - AgriFarm

## 🔍 ANALYSE DES ERREURS IDENTIFIÉES

### 1. **PROBLÈMES D'URL ET CONNECTIVITÉ**
- **Erreur 1** : `Failed to load resource: net::ERR_NAME_NOT_RESOLVED` sur `placeholder.com/farmer_tablet`
- **Erreur 2** : `HTTP request failed, statusCode: 401 (Unauthorized)` sur `:8000/api/ventes`
- **Erreur 3** : `net::ERR_CONNECTION_TIMED_OUT` sur `10.0.2.2:8000/api/recoltes`

### 2. **INCONSISTANCES DANS LES SERVICES**
- `api_service.dart` utilise `http://localhost:8000/api`
- `recolte_service.dart` utilise `http://10.0.2.2:8000/api` ✅ (correct pour émulateur)
- `vente_service.dart` utilise `http://localhost:8000/api`

### 3. **PROBLÈMES D'INTERFACE (RENDER OVERFLOW)**
- `RenderFlex overflowed by 207/103/92/245 pixels on the right`
- Problème de responsive design dans l'interface

---

## 🛠️ PLAN DE CORRECTION DÉTAILLÉ

### **ÉTAPE 1 : UNIFICATION DES URLS DES SERVICES** (Priorité Haute)
**Objectif** : Corriger les URLs pour assurer la cohérence entre tous les services
- [ ] Modifier `lib/services/api_service.dart` : changer `localhost` → `10.0.2.2`
- [ ] Modifier `lib/services/vente_service.dart` : changer `localhost` → `10.0.2.2`
- [ ] Vérifier que tous les services utilisent `http://10.0.2.2:8000/api`

### **ÉTAPE 2 : CORRECTION DES IMAGES PLACEHOLDER** (Priorité Moyenne)
**Objectif** : Remplacer les images non-fonctionnelles
- [ ] Créer des images locales dans `assets/images/`
- [ ] Modifier `lib/screens/welcome_screen.dart` pour utiliser les nouvelles images
- [ ] Tester le chargement des images

### **ÉTAPE 3 : DIAGNOSTIC AUTHENTIFICATION** (Priorité Haute)
**Objectif** : Résoudre les erreurs 401 Unauthorized
- [ ] Vérifier `lib/providers/auth_provider.dart`
- [ ] Examiner `lib/utils/storage_helper.dart`
- [ ] Tester la connexion API et les tokens
- [ ] Vérifier que le backend fonctionne sur `10.0.2.2:8000`

### **ÉTAPE 4 : CORRECTION LAYOUT RESPONSIVE** (Priorité Moyenne)
**Objectif** : Résoudre les erreurs de RenderFlex overflow
- [ ] Examiner les widgets qui causent le overflow
- [ ] Utiliser `SingleChildScrollView` et `Wrap` pour la responsivité
- [ ] Tester sur différentes tailles d'écran

### **ÉTAPE 5 : TESTS ET VALIDATION** (Priorité Moyenne)
**Objectif** : S'assurer que toutes les corrections fonctionnent
- [ ] Lancer l'application et vérifier la console
- [ ] Tester toutes les fonctionnalités principales
- [ ] Valider la connectivité réseau

---

## 🔧 FICHIERS À MODIFIER

1. **`lib/services/api_service.dart`** - URL base
2. **`lib/services/vente_service.dart`** - URL base  
3. **`lib/screens/welcome_screen.dart`** - Images placeholder
4. **`lib/providers/auth_provider.dart`** - Authentification
5. **Assets images** - Nouvelles images locales

---

## ⚠️ PRÉREQUIS AVANT MODIFICATION

- [ ] S'assurer que le backend fonctionne sur `10.0.2.2:8000`
- [ ] Vérifier les permissions réseau dans `android/app/src/main/AndroidManifest.xml`
- [ ] Sauvegarder l'état actuel du projet

---

## 🎯 RÉSULTAT ATTENDU

✅ Élimination des erreurs `ERR_NAME_NOT_RESOLVED`  
✅ Résolution des erreurs 401 Unauthorized  
✅ Correction des timeouts de connexion  
✅ Suppression des erreurs RenderFlex overflow  
✅ Application fonctionnelle avec interface responsive
