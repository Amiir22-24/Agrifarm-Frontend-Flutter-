// lib/utils/http_client.dart
// Client HTTP amélioré avec timeout et retry logic

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class HttpClient {
  static const Duration defaultTimeout = AppConfig.requestTimeout;
  static const int maxRetries = AppConfig.maxRetryAttempts;
  static const Duration retryDelay = AppConfig.retryDelay;

  // 🌐 GET avec retry automatique
  static Future<Map<String, dynamic>> getWithRetry(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
    int? maxAttempts,
  }) async {
    final attempts = maxAttempts ?? maxRetries;
    final requestTimeout = timeout ?? defaultTimeout;

    for (int attempt = 1; attempt <= attempts; attempt++) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: headers,
        ).timeout(requestTimeout);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'statusCode': response.statusCode,
            'data': jsonDecode(response.body),
            'attempts': attempt,
          };
        }

        // Pour les erreurs 422 et 400, on ne retry pas
        if (response.statusCode == 422 || response.statusCode == 400) {
          return {
            'success': false,
            'statusCode': response.statusCode,
            'error': 'Données invalides: ${response.body}',
            'attempts': attempt,
          };
        }

        // Pour les erreurs 5xx, on retry
        if (response.statusCode >= 500 && attempt < attempts) {
          await Future.delayed(retryDelay * attempt);
          continue;
        }

        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
          'attempts': attempt,
        };
      } catch (e) {
        if (attempt == attempts) {
          return {
            'success': false,
            'error': 'Échec après $attempts tentatives: $e',
            'attempts': attempt,
          };
        }

        // Délai exponentiel entre les tentatives
        await Future.delayed(retryDelay * attempt);
      }
    }

    return {
      'success': false,
      'error': 'Échec après $attempts tentatives',
      'attempts': attempts,
    };
  }

  // 🌐 POST avec retry automatique
  static Future<Map<String, dynamic>> postWithRetry(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    Duration? timeout,
    int? maxAttempts,
  }) async {
    final attempts = maxAttempts ?? maxRetries;
    final requestTimeout = timeout ?? defaultTimeout;

    for (int attempt = 1; attempt <= attempts; attempt++) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: body is String ? body : jsonEncode(body),
        ).timeout(requestTimeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {
            'success': true,
            'statusCode': response.statusCode,
            'data': jsonDecode(response.body),
            'attempts': attempt,
          };
        }

        // Pas de retry pour les erreurs client
        if (response.statusCode >= 400 && response.statusCode < 500) {
          return {
            'success': false,
            'statusCode': response.statusCode,
            'error': 'Erreur client: ${response.body}',
            'attempts': attempt,
          };
        }

        // Retry pour les erreurs serveur
        if (response.statusCode >= 500 && attempt < attempts) {
          await Future.delayed(retryDelay * attempt);
          continue;
        }

        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': 'HTTP ${response.statusCode}: ${response.body}',
          'attempts': attempt,
        };
      } catch (e) {
        if (attempt == attempts) {
          return {
            'success': false,
            'error': 'Échec POST après $attempts tentatives: $e',
            'attempts': attempt,
          };
        }

        await Future.delayed(retryDelay * attempt);
      }
    }

    return {
      'success': false,
      'error': 'Échec POST après $attempts tentatives',
      'attempts': attempts,
    };
  }

  // 🔧 Validation des réponses
  static bool isSuccessResponse(Map<String, dynamic> response) {
    return response['success'] == true;
  }

  static String getErrorMessage(Map<String, dynamic> response) {
    return response['error'] ?? 'Erreur inconnue';
  }

  static int getAttempts(Map<String, dynamic> response) {
    return response['attempts'] ?? 1;
  }

  // 📊 Métriques pour monitoring
  static Map<String, dynamic> getRequestMetrics(Map<String, dynamic> response) {
    return {
      'success': isSuccessResponse(response),
      'attempts': getAttempts(response),
      'statusCode': response['statusCode'],
      'hasError': response.containsKey('error'),
    };
  }
}
