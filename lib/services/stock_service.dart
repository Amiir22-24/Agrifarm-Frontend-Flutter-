// lib/services/stock_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../utils/storage_helper.dart';

class StockService {

  static const String baseUrl = 'http://localhost:8000/api';
  
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String _extractErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data['message'] != null) {
        return data['message'];
      } else if (data['error'] != null) {
        return data['error'];
      } else if (data['errors'] != null) {
        return data['errors'].toString();
      } else {
        return 'Erreur HTTP ${response.statusCode}';
      }
    } catch (e) {
      return 'Erreur HTTP ${response.statusCode}';
    }
  }

  static Future<List<Stock>> getStocks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/stocks'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      
      // Gérer les deux formats de réponse: Liste directe ou Map avec pagination
      List<dynamic> stocksList;
      
      if (data is List) {
        // Format: liste directe
        stocksList = data;
      } else if (data is Map<String, dynamic>) {
        // Format: objet avec pagination {data: [...], ...}
        if (data['data'] is List) {
          stocksList = data['data'] as List<dynamic>;
        } else {
          stocksList = [];
        }
      } else {
        stocksList = [];
      }
      
      return stocksList.map((json) => Stock.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Erreur stocks');
  }

  static Future<Stock> createStock(Stock stock) async {
    if (stock.quantite <= 0) {
      throw Exception('La quantité doit être supérieure à 0');
    }
    if (stock.produit == null || stock.produit <= 0) {
      throw Exception('Le produit est obligatoire');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stocks'),
        headers: await _getHeaders(),
        body: jsonEncode(stock.toJson()),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['stock'] != null) {
          return Stock.fromJson(responseData['stock'] as Map<String, dynamic>);
        } else if (responseData['data'] != null) {
          return Stock.fromJson(responseData['data'] as Map<String, dynamic>);
        } else if (responseData is Map && responseData.containsKey('id')) {
          return Stock.fromJson(responseData as Map<String, dynamic>);
        } else {
          throw Exception('Structure de réponse inattendue');
        }
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Erreur création: $errorMessage');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Stock> updateStock(int id, Stock stock) async {
    if (stock.quantite <= 0) {
      throw Exception('La quantité doit être supérieure à 0');
    }
    if (stock.produit == null || stock.produit <= 0) {
      throw Exception('Le produit est obligatoire');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/stocks/$id'),
        headers: await _getHeaders(),
        body: jsonEncode(stock.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['stock'] != null) {
          return Stock.fromJson(responseData['stock'] as Map<String, dynamic>);
        } else if (responseData['data'] != null) {
          return Stock.fromJson(responseData['data'] as Map<String, dynamic>);
        } else if (responseData is Map && responseData.containsKey('id')) {
          return Stock.fromJson(responseData as Map<String, dynamic>);
        } else {
          throw Exception('Structure de réponse inattendue');
        }
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Erreur modification: $errorMessage');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteStock(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/stocks/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorMessage = _extractErrorMessage(response);
      throw Exception('Erreur suppression: $errorMessage');
    }
  }
}

