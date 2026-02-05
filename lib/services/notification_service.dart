// lib/services/notification_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../utils/storage_helper.dart';

class NotificationService {
  static const String baseUrl = 'http://localhost:8000/api';
  static const String notificationsEndpoint = '/notifications';

  /// Récupérer les headers avec le token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Origin': 'http://localhost:8000',
      'Referer': 'http://localhost:8000/',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Récupérer toutes les notifications avec pagination
  static Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int perPage = 30,
    bool unreadOnly = false,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (unreadOnly) params['unread'] = 'true';

    final uri = Uri.parse('$baseUrl$notificationsEndpoint')
        .replace(queryParameters: params);

    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // L'API Laravel retourne les données dans 'data' pour la pagination
      if (data['data'] != null) {
        return (data['data'] as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
      // Fallback: si pas de pagination, liste directe
      if (data is List) {
        return (data as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
      return [];
    } else {
      throw Exception('Erreur récupération notifications: ${response.statusCode}');
    }
  }

  /// Marquer une notification comme lue
  static Future<NotificationModel> markAsRead(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl$notificationsEndpoint/$id/read'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null) {
        return NotificationModel.fromJson(data['data']);
      }
      throw Exception('Réponse inattendue du serveur');
    } else {
      throw Exception('Erreur marquage notification: ${response.statusCode}');
    }
  }

  /// Marquer toutes les notifications comme lues
  static Future<int> markAllAsRead() async {
    final response = await http.put(
      Uri.parse('$baseUrl$notificationsEndpoint/mark-all-read'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['updated_count'] ?? 0;
    } else {
      throw Exception('Erreur marquage toutes notifications: ${response.statusCode}');
    }
  }

  /// Supprimer une notification
  static Future<void> deleteNotification(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$notificationsEndpoint/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erreur suppression notification: ${response.statusCode}');
    }
  }

  /// Compter les notifications non lues
  static Future<int> getUnreadCount() async {
    final notifications = await getNotifications(unreadOnly: true);
    return notifications.length;
  }
}

