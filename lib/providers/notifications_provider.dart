// lib/providers/notifications_provider.dart

import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationsProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> _unreadNotifications = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _showUnreadOnly = false;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => _unreadNotifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get unreadCount => _notifications.where((n) => n.isRead == false).length;
  bool get hasMorePages => _hasMorePages;
  bool get showUnreadOnly => _showUnreadOnly;

  /// Charger toutes les notifications
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePages = true;
      _notifications = [];
      _unreadNotifications = [];
    }

    if (_isLoading || !_hasMorePages) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newNotifications = await NotificationService.getNotifications(
        page: _currentPage,
        perPage: 30,
      );

      if (newNotifications.isEmpty) {
        _hasMorePages = false;
      } else {
        _notifications.addAll(newNotifications);
        _currentPage++;
      }

      // Mettre à jour les non lues
      _unreadNotifications = _notifications.where((n) => n.isRead == false).toList();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Erreur loadNotifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger uniquement les notifications non lues
  Future<void> loadUnreadOnly() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _unreadNotifications = await NotificationService.getNotifications(
        unreadOnly: true,
      );
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Erreur loadUnreadOnly: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger notifications avec filtre
  Future<void> fetchNotifications({bool? unread}) async {
    if (unread == true) {
      await loadUnreadOnly();
    } else {
      await loadNotifications();
    }
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(NotificationModel notification) async {
    try {
      await NotificationService.markAsRead(notification.id);
      
      // Mettre à jour localement
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: notification.id,
          userId: notification.userId,
          titre: notification.titre,
          message: notification.message,
          type: notification.type,
          isRead: true,
          createdAt: notification.createdAt,
          readAt: DateTime.now(),
        );
      }

      final unreadIndex = _unreadNotifications.indexWhere((n) => n.id == notification.id);
      if (unreadIndex != -1) {
        _unreadNotifications.removeAt(unreadIndex);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Erreur markAsRead: $e');
      rethrow;
    }
  }

  /// Marquer une notification comme lue par ID
  Future<void> markAsReadById(int id) async {
    try {
      await NotificationService.markAsRead(id);
      
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final oldNotif = _notifications[index];
        _notifications[index] = NotificationModel(
          id: oldNotif.id,
          userId: oldNotif.userId,
          titre: oldNotif.titre,
          message: oldNotif.message,
          type: oldNotif.type,
          isRead: true,
          createdAt: oldNotif.createdAt,
          readAt: DateTime.now(),
        );
      }

      _unreadNotifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Erreur markAsReadById: $e');
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      await NotificationService.markAllAsRead();
      
      // Mettre à jour localement
      _notifications = _notifications.map((n) => NotificationModel(
        id: n.id,
        userId: n.userId,
        titre: n.titre,
        message: n.message,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
        readAt: DateTime.now(),
      )).toList();

      _unreadNotifications = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Erreur markAllAsRead: $e');
      rethrow;
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(int id) async {
    try {
      await NotificationService.deleteNotification(id);
      
      _notifications.removeWhere((n) => n.id == id);
      _unreadNotifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('Erreur deleteNotification: $e');
      rethrow;
    }
  }

  /// Définir le mode d'affichage
  void setShowUnreadOnly(bool value) {
    _showUnreadOnly = value;
    notifyListeners();
  }

  /// Rafraîchir les notifications (pull to refresh)
  Future<void> refresh() async {
    await loadNotifications(refresh: true);
  }

  /// Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Obtenir les notifications à afficher
  List<NotificationModel> get displayNotifications {
    return _showUnreadOnly ? _unreadNotifications : _notifications;
  }

  /// Effacer toutes les données (pour déconnexion/nouvel utilisateur)
  void clearData() {
    _notifications = [];
    _unreadNotifications = [];
    _error = null;
    _currentPage = 1;
    _hasMorePages = true;
    notifyListeners();
  }
}

