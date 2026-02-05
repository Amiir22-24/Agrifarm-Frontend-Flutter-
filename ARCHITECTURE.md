# Architecture de l'Application Flutter AgriFarm

## Vue d'ensemble de l'architecture

L'application AgriFarm suit l'architecture **Clean Architecture** avec **Provider Pattern** pour la gestion d'état. Elle est organisée en plusieurs couches distinctes pour séparer les responsabilités et faciliter la maintenance.

## Structure par Sections

### 🔧 1. CONFIGURATION PRINCIPALE

**Rôle :** Point d'entrée de l'application, configuration des providers, routes et thème global.

#### Fichiers :
- **`lib/main.dart`**
  - Point d'entrée de l'application
  - Configuration du MultiProvider avec tous les providers
  - Configuration du thème Material Design
  - Gestion des routes principales
  - AuthWrapper pour la gestion de l'authentification

---

### 📊 2. MODÈLES DE DONNÉES (Models)

**Rôle :** Définition des structures de données, sérialisation/désérialisation JSON.

#### Fichiers :

- **`lib/models/user.dart`**
  - Modèle utilisateur
  - Attributs : id, nom, email, téléphone, ferme, etc.
  - Méthodes : toJson(), fromJson()

- **`lib/models/culture.dart`**
  - Modèle des cultures agricoles
  - Attributs : id, nom, type, date plantation, statut, etc.
  - Méthodes : toJson(), fromJson()

- **`lib/models/vente.dart`**
  - Modèle des ventes
  - Attributs : id, cultureId, quantité, prix, date, client, etc.
  - Méthodes : toJson(), fromJson()

- **`lib/models/stock.dart`**
  - Modèle du stock
  - Attributs : id, cultureId, quantité disponible, unité, etc.
  - Méthodes : toJson(), fromJson()

- **`lib/models/recolte.dart`**
  - Modèle des récoltes
  - Attributs : id, cultureId, quantité, qualité, date, etc.
  - Méthodes : toJson(), fromJson()

- **`lib/models/meteo.dart`**
  - Modèle des données météorologiques
  - Attributs : température, humidité, précipitations, etc.
  - Méthodes : toJson(), fromJson()

- **`lib/models/rapport.dart`**
  - Modèle des rapports
  - Attributs : id, titre, contenu, type, période, etc.
  - Méthodes : toJson(), fromJson()

- **`lib/models/notification_model.dart`**
  - Modèle des notifications
  - Attributs : id, titre, message, lu/non lu, date, type, etc.
  - Méthodes : toJson(), fromJson()

- **`lib/models/chat_message.dart`**
  - Modèle des messages de chat
  - Attributs : id, message, type (utilisateur/bot), timestamp, etc.
  - Méthodes : toJson(), fromJson()

---

### 🌐 3. SERVICES ET API

**Rôle :** Communication avec le backend, gestion des requêtes HTTP, authentification.

#### Fichiers :

- **`lib/services/api_service.dart`**
  - Service API principal
  - Méthodes génériques : GET, POST, PUT, DELETE
  - Gestion des stocks, ventes, authentification
  - Méthodes utilitaires : search(), getDashboardStats(), analytics
  - Headers automatiques avec token

- **`lib/services/auth_service.dart`** (utilisé par AuthProvider)
  - Authentification utilisateur
  - Méthodes : login(), register(), logout()
  - Gestion des tokens JWT

- **`lib/services/culture_service.dart`**
  - Gestion des cultures
  - Méthodes : getCultures(), createCulture(), updateCulture(), deleteCulture()
  - getCultureWeather() pour météo spécifique

- **`lib/services/vente_service.dart`**
  - Gestion des ventes
  - Méthodes : getVentes(), createVente(), updateVente(), deleteVente()
  - Filtres par date et pagination

- **`lib/services/stock_service.dart`**
  - Gestion du stock
  - Méthodes : getStocks(), createStock(), updateStock(), deleteStock()

- **`lib/services/recolte_service.dart`**
  - Gestion des récoltes
  - Méthodes : getRecoltes(), createRecolte(), updateRecolte(), deleteRecolte()
  - getRecolteStats() pour statistiques

- **`lib/services/meteo_service.dart`**
  - Service météorologique
  - Méthodes : getWeatherByCity(), getCurrentWeather(), getWeatherForecast()
  - getCultureWeather() pour météo par culture

- **`lib/services/notification_service.dart`**
  - Gestion des notifications
  - Méthodes : getNotifications(), markAsRead(), markAllAsRead()
  - deleteNotification(), getUnreadCount()

- **`lib/services/rapport_service.dart`**
  - Gestion des rapports
  - Méthodes : getRapports(), createRapport(), generateAiReport()
  - downloadRapport(), getRapport(), deleteRapport()

- **`lib/services/chat_service.dart`**
  - Service de chat avec IA
  - Méthodes : sendMessage(), resetChat(), getChatStatus()

- **`lib/services/profile_service.dart`**
  - Gestion du profil utilisateur
  - Méthodes : getUser(), updateUser(), updateWeatherCity()

---

### 🔄 4. PROVIDERS (Gestion d'État)

**Rôle :** Gestion de l'état de l'application, liaison entre services et interface utilisateur.

#### Fichiers :

- **`lib/providers/auth_provider.dart`**
  - État d'authentification
  - Gestion du login/logout
  - Vérification du statut d'authentification
  - Stockage local du token

- **`lib/providers/cultures_provider.dart`**
  - État des cultures
  - CRUD des cultures
  - Actualisation automatique des données

- **`lib/providers/ventes_provider.dart`**
  - État des ventes
  - Gestion des ventes avec filtres
  - Pagination

- **`lib/providers/stock_provider.dart`**
  - État du stock
  - Gestion en temps réel du stock

- **`lib/providers/recolte_provider.dart`**
  - État des récoltes
  - Calculs de statistiques

- **`lib/providers/meteo_provider.dart`**
  - État des données météorologiques
  - Cache des données météo

- **`lib/providers/weather_provider.dart`**
  - Provider spécifique pour l'interface météo
  - Interface avec les cartes météo

- **`lib/providers/notifications_provider.dart`**
  - État des notifications
  - Gestion des notifications non lues
  - Actions sur les notifications

- **`lib/providers/rapport_provider.dart`**
  - État des rapports
  - Génération et gestion des rapports IA

- **`lib/providers/chat_provider.dart`**
  - État du chat
  - Historique des messages
  - Interface avec le service IA

- **`lib/providers/user_provider.dart`**
  - État du profil utilisateur
  - Mise à jour du profil

---

### 📱 5. ÉCRANS ET INTERFACES (Screens)

**Rôle :** Interfaces utilisateur, navigation, interaction avec l'utilisateur.

#### Fichiers :

- **`lib/screens/login_screen.dart`**
  - Écran de connexion
  - Formulaire email/mot de passe
  - Redirection vers inscription
  - Gestion des erreurs de connexion

- **`lib/screens/register_screen.dart`**
  - Écran d'inscription
  - Formulaire de création de compte
  - Validation des données
  - Redirection après inscription

- **`lib/screens/home_screen.dart`**
  - Écran d'accueil/tableau de bord
  - Vue d'ensemble des données
  - Cartes de statistiques
  - Navigation vers autres écrans

- **`lib/screens/cultures_screen.dart`**
  - Liste des cultures
  - Actions CRUD sur les cultures
  - Filtrage et recherche

- **`lib/screens/add_culture_screen.dart`**
  - Formulaire d'ajout de culture
  - Sélection du type de culture
  - Dates et paramètres

- **`lib/screens/ventes_screen.dart`**
  - Liste des ventes
  - Filtrage par date/période
  - Ajout/modification de ventes

- **`lib/screens/stock_screen.dart`**
  - Gestion du stock
  - Alertes de stock faible
  - Mises à jour de stock

- **`lib/screens/rapport_screen.dart`**
  - Liste et gestion des rapports
  - Génération de rapports IA
  - Téléchargement de rapports

- **`lib/screens/chat_screen.dart`**
  - Interface de chat avec IA
  - Historique des conversations
  - Suggestions de questions

- **`lib/screens/notifications_screen.dart`**
  - Liste des notifications
  - Actions : marquer lu, supprimer
  - Filtres lu/non lu

- **`lib/screens/profile_screen.dart`**
  - Profil utilisateur
  - Modification des informations
  - Paramètres de l'application

---

### 🛠️ 6. UTILITAIRES

**Rôle :** Fonctions utilitaires, stockage local, helpers.

#### Fichiers :

- **`lib/utils/storage_helper.dart`**
  - Stockage local avec SharedPreferences
  - Gestion du token JWT
  - Sauvegarde des données utilisateur
  - Méthodes : getToken(), saveToken(), removeToken(), saveUser(), getUser()

---

### 🎨 7. WIDGETS PERSONNALISÉS

**Rôle :** Composants réutilisables pour l'interface utilisateur.

#### Fichiers :

- **`lib/widgets/weather_card.dart`**
  - Carte d'affichage météo
  - Température, conditions, icônes
  - Réutilisable dans différents écrans

---

## Flux de Données

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Screens   │────│   Providers  │────│  Services   │
│ (UI Layer)  │    │(State Mgmt)  │    │ (Data Layer)│
└─────────────┘    └──────────────┘    └─────────────┘
        │                   │                   │
        │                   │                   │
        ▼                   ▼                   ▼
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Widgets   │    │   Models     │    │   Backend   │
│  (Components)│    │ (Data Model) │    │ (API/REST)  │
└─────────────┘    └──────────────┘    └─────────────┘
```

## Technologies Utilisées

- **Framework :** Flutter
- **Gestion d'état :** Provider Pattern
- **HTTP :** package http
- **Stockage local :** SharedPreferences
- **Architecture :** Clean Architecture avec séparation des couches

## Avantages de cette Architecture

1. **Séparation des responsabilités** : Chaque couche a un rôle spécifique
2. **Réutilisabilité** : Services et widgets réutilisables
3. **Maintenabilité** : Code organisé et modulaire
4. **Testabilité** : Chaque couche peut être testée indépendamment
5. **Évolutivité** : Facilité d'ajout de nouvelles fonctionnalités

## Configuration Backend

**URL du Backend :** `http://localhost:8000/api`

Tous les services pointent vers cette URL pour communiquer avec le backend Laravel/API REST.
