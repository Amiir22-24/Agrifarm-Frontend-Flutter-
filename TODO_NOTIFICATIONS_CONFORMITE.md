# TODO - MISE EN CONFORMITÉ SECTION NOTIFICATIONS

## Objectif
Mettre à jour la section Notifications pour qu'elle soit conforme au guide complet.

## Fichiers modifiés (4) ✅
- [x] 1. `lib/models/notification_model.dart` - Ajout NotificationTypeData, readAt, typeData getter
- [x] 2. `lib/services/notification_service.dart` - Pagination, parsing correct
- [x] 3. `lib/providers/notifications_provider.dart` - Pagination, refresh, méthodes unread-only
- [x] 4. `lib/screens/notifications_screen.dart` - Filtres, pull-to-refresh, meilleure UI

## Fichiers créés (2) ✅
- [x] 5. `lib/screens/notification_detail_screen.dart` - Écran de détails
- [x] 6. `lib/widgets/notification_badge.dart` - Badge de notification pour navbar

## Récapitulatif des modifications

### 1. notification_model.dart
- ✅ Ajout `readAt` optionnel (DateTime?)
- ✅ Ajout `isRead` avec parsing de `is_read`/`lu`
- ✅ Ajout classe `NotificationTypeData` avec :
  - `category`, `action`, `priority`, `data`
  - `iconPath` selon la catégorie
  - `priorityColor` selon la priorité
  - `actionTitle`, `categoryTitle` pour l'affichage
- ✅ Ajout `typeData` getter avec parsing JSON du champ `type`
- ✅ Méthode `toJson()` pour la sérialisation

### 2. notification_service.dart
- ✅ Utilisation de `StorageHelper` pour les headers
- ✅ Support de pagination (`page`, `perPage`)
- ✅ Filtre `unreadOnly`
- ✅ Parsing de réponse Laravel avec `data['data']`
- ✅ `markAsRead()` retourne le modèle mis à jour
- ✅ `markAllAsRead()` retourne le nombre de notifications mises à jour

### 3. notifications_provider.dart
- ✅ `_unreadNotifications` list séparée
- ✅ `_currentPage`, `_hasMorePages` pour pagination
- ✅ `loadUnreadOnly()` méthode dédiée
- ✅ `refresh()` pour pull-to-refresh
- ✅ `markAsRead()` avec mise à jour locale
- ✅ `markAllAsRead()` avec mise à jour locale
- ✅ `setShowUnreadOnly()` pour le filtre
- ✅ `displayNotifications` getter calculé

### 4. notifications_screen.dart
- ✅ Toggle filtre "non lues" avec PopupMenuButton
- ✅ Pull-to-refresh (RefreshIndicator)
- ✅ `NotificationTile` avec :
  - Indicateurs de couleur selon la priorité
  - Icônes selon la catégorie
  - Badge priorité (critical/high/normal)
  - Formatage intelligent des dates
- ✅ Menu contextuel (marquer lu / supprimer)
- ✅ Navigation vers `NotificationDetailScreen`
- ✅ Confirmation avant suppression
- ✅ Messages SnackBar pour feedback utilisateur

### 5. notification_detail_screen.dart (NOUVEAU)
- ✅ Affichage icône, priorité, catégorie
- ✅ Affichage message complet
- ✅ Affichage données supplémentaires (data JSON)
- ✅ Affichage dates (reçu/lu)
- ✅ Bouton marquer comme lu si pas encore lu

### 6. notification_badge.dart (NOUVEAU)
- ✅ Widget avec badge rouge
- ✅ Affichage compteur non lues
- ✅ Affichage "99+" si > 99
- ✅ Intégration avec NotificationsProvider

## Route configurée ✅
- `/notifications` → `NotificationsScreen` (dans main.dart)

## Provider configuré ✅
- `NotificationsProvider` enregistré dans MultiProvider (dans main.dart)

## Structure finale符合ante au guide ✅
```
lib/src/
├── models/
│   └── notification_model.dart ✅
├── services/
│   └── notification_service.dart ✅
├── providers/
│   └── notifications_provider.dart ✅
├── screens/
│   ├── notifications_screen.dart ✅
│   └── notification_detail_screen.dart ✅ (NOUVEAU)
└── widgets/
    └── notification_badge.dart ✅ (NOUVEAU)
```

