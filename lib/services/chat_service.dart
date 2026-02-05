import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/chat_state.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import '../utils/storage_helper.dart';

class ChatService {
  final String baseUrl;
  final http.Client client;

  ChatService({required this.baseUrl, http.Client? client}) 
      : client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Envoyer une question au chatbot
  Future<ApiResponse<ChatResponse>> sendQuestion({
    required String question,
    required List<ChatMessage> history,
  }) async {
    try {
      final headers = await _getHeaders();
      final historyJson = history.map((msg) => msg.toJson()).toList();
      final body = jsonEncode({
        'question': question, 
        'history': historyJson
      });

      final response = await client.post(
        Uri.parse('$baseUrl${ApiConstants.chatEndpoint}'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: ApiConstants.timeoutSeconds));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Le backend peut retourner la réponse directement ou dans 'data'
        final data = responseData['data'] ?? responseData;
        return ApiResponse.success(
          responseData, 
          (json) => ChatResponse.fromJson(json['data'] ?? json)
        );
      } else if (response.statusCode == 401) {
        return ApiResponse.error('Session expirée', response.statusCode);
      } else {
        return ApiResponse.error(
          responseData['message'] ?? 'Erreur lors de l\'envoi du message',
          response.statusCode
        );
      }
    } on http.ClientException catch (e) {
      return ApiResponse.error('Erreur de connexion: ${e.message}');
    } on FormatException catch (e) {
      return ApiResponse.error('Format de réponse invalide: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Erreur inattendue: ${e.toString()}');
    }
  }

  // Réinitialiser la conversation
  Future<ApiResponse<void>> resetConversation() async {
    try {
      final headers = await _getHeaders();
      final response = await client.post(
        Uri.parse('$baseUrl${ApiConstants.chatResetEndpoint}'),
        headers: headers,
      ).timeout(const Duration(seconds: ApiConstants.timeoutSeconds));

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse<void>.success(responseData, (_) => null);
      } else {
        return ApiResponse.error(
          responseData['message'] ?? 'Erreur lors de la réinitialisation',
          response.statusCode
        );
      }
    } catch (e) {
      return ApiResponse.error('Erreur: ${e.toString()}');
    }
  }

  // Obtenir le statut de l'IA
  Future<ApiResponse<AiStatus>> getChatStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await client.get(
        Uri.parse('$baseUrl${ApiConstants.chatStatusEndpoint}'),
        headers: headers,
      ).timeout(const Duration(seconds: ApiConstants.timeoutSeconds));

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final data = responseData['data'];
        if (data != null) {
          return ApiResponse.success(
            responseData, 
            (json) => AiStatus.fromJson(json['data'] ?? {})
          );
        }
        return ApiResponse.error('Données de statut manquantes');
      } else {
        return ApiResponse.error(
          responseData['message'] ?? 'Erreur lors de la récupération du statut',
          response.statusCode
        );
      }
    } catch (e) {
      return ApiResponse.error('Erreur: ${e.toString()}');
    }
  }

  // Libérer les ressources
  void dispose() {
    client.close();
  }
}

