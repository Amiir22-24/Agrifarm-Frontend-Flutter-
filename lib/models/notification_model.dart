// lib/models/notification_model.dart

import 'dart:convert';

class NotificationModel {
  final int id;
  final int? userId;
  final String titre;
  final String? message;
  final String? type; // JSON string
  final bool isRead; // Converted from is_read/lu
  final DateTime createdAt;
  final DateTime? readAt; // From is_read

  NotificationModel({
    required this.id,
    this.userId,
    required this.titre,
    this.message,
    this.type,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      titre: json['titre'] ?? '',
      message: json['message'],
      type: json['type'],
      isRead: json['is_read'] != null || json['lu'] == true || json['lu'] == 1,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      readAt: _parseReadAt(json['is_read']),
    );
  }

  static DateTime? _parseReadAt(dynamic value) {
    if (value == null) return null;
    if (value == false || value == true) return null;
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'titre': titre,
      'message': message,
      'type': type,
      'is_read': isRead ? DateTime.now().toIso8601String() : null,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Parser le champ type JSON pour extraire les métadonnées
  NotificationTypeData? get typeData {
    if (type == null) return null;
    try {
      return NotificationTypeData.fromJson(json.decode(type!));
    } catch (e) {
      // Si le parsing échoue, créer un typeData par défaut
      return NotificationTypeData.fromJson({
        'category': 'system',
        'action': 'info',
        'priority': 'normal',
        'data': {},
      });
    }
  }
}

class NotificationTypeData {
  final String category; // culture, recolte, stock, vente, weather, system
  final String action; // created, updated, deleted, alert, critical
  final String priority; // normal, high, critical
  final Map<String, dynamic> data;

  NotificationTypeData({
    required this.category,
    required this.action,
    required this.priority,
    required this.data,
  });

  factory NotificationTypeData.fromJson(Map<String, dynamic> json) {
    return NotificationTypeData(
      category: json['category'] ?? 'system',
      action: json['action'] ?? 'info',
      priority: json['priority'] ?? 'normal',
      data: json['data'] ?? {},
    );
  }

  /// Icône selon la catégorie
  String get iconPath {
    switch (category) {
      case 'culture': 
        return '🌱';
      case 'recolte': 
        return '🌾';
      case 'stock': 
        return '📦';
      case 'vente': 
        return '💰';
      case 'weather': 
        return '🌤️';
      case 'stock_critical': 
        return '⚠️';
      default: 
        return '📢';
    }
  }

  /// Couleur selon la priorité (ARGB int pour Flutter)
  int get priorityColor {
    switch (priority) {
      case 'critical': 
        return 0xFFE53935; // Rouge
      case 'high': 
        return 0xFFFF9800; // Orange
      default: 
        return 0xFF4CAF50; // Vert
    }
  }

  /// Titre descriptif de l'action
  String get actionTitle {
    switch (action) {
      case 'created': 
        return 'Création';
      case 'updated': 
        return 'Mise à jour';
      case 'deleted': 
        return 'Suppression';
      case 'alert': 
        return 'Alerte';
      case 'critical': 
        return 'Critique';
      default: 
        return 'Information';
    }
  }

  /// Catégorie lisible
  String get categoryTitle {
    switch (category) {
      case 'culture': 
        return 'Culture';
      case 'recolte': 
        return 'Récolte';
      case 'stock': 
        return 'Stock';
      case 'vente': 
        return 'Vente';
      case 'weather': 
        return 'Météo';
      case 'stock_critical': 
        return 'Stock critique';
      default: 
        return 'Système';
    }
  }
}

