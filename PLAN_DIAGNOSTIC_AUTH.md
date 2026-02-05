# Plan de Diagnostic et Correction - Problèmes d'Authentification

## 🔍 Problèmes Identifiés

### 1. Message "Utilisateur non connecté" lors de la création de stock
**Cause** : Le `StockProvider` essaie de récupérer l'ID utilisateur via `StorageHelper.getUser()` mais les données utilisateur ne sont pas correctement synchronisées.

### 2. Nom d'utilisateur qui ne s'affiche pas dans le navbar
**Cause** : Désynchronisation entre `AuthProvider` et `UserProvider` :
- `AuthProvider` gère l'authentification et sauvegarde les données utilisateur
- `HomeScreen` utilise `UserProvider` pour l'affichage
- Les deux providers ne sont pas synchronisés

### 3. Le nom s'affiche seulement dans le profil
**Cause** : Le `UserProvider` ne charge les données utilisateur que lorsqu'on accède à l'écran profil.

## 🎯 Plan de Correction

### Étape 1 : Synchronisation des Providers
- Modifier l'`AuthProvider` pour notifier le `UserProvider` lors de la connexion
- Assurer que les données utilisateur sont partagées entre les deux providers

### Étape 2 : Correction du StockProvider
- Modifier `_getCurrentUserId()` pour utiliser l'`AuthProvider` directement
- Éliminer la dépendance au stockage local pour l'ID utilisateur

### Étape 3 : Initialisation des Providers
- Assurer l'initialisation correcte des providers au démarrage de l'application
- Synchroniser les données utilisateur dès la connexion

### Étape 4 : Correction de l'affichage du nom
- Corriger l'affichage du nom dans la navbar
- Assurer que les données sont disponibles dès la connexion

## 📋 Fichiers à Modifier
1. `lib/providers/auth_provider.dart` - Synchronisation avec UserProvider
2. `lib/providers/stock_provider.dart` - Récupération de l'ID utilisateur
3. `lib/providers/user_provider.dart` - Synchronisation avec AuthProvider
4. `lib/main.dart` - Initialisation des providers
5. `lib/screens/home_screen.dart` - Correction de l'affichage
