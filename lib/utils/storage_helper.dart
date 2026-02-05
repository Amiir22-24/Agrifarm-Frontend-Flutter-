// lib/utils/storage_helper.dart - VERSION COMPLÈTE
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chat_message.dart';

class StorageHelper {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _chatHistoryKey = 'chat_history';

  // Token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // User
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    return userData != null ? jsonDecode(userData) : null;
  }

  // Chat History
  static Future<void> saveChatHistory(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = messages.map((m) => m.toJson()).toList();
    await prefs.setString(_chatHistoryKey, jsonEncode(encoded));
  }

  static Future<List<ChatMessage>?> getChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_chatHistoryKey);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((json) => ChatMessage.fromJson(json)).toList();
    }
    return null;
  }

  static Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatHistoryKey);
  }

  // Clear All
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }


  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Supprimer le token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Nettoyer les données utilisateur
  static Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Nettoyer les données d'authentification
  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
