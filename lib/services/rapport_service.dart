// ✅ CORRIGÉ - lib/services/rapport_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/rapport.dart';
import '../utils/storage_helper.dart';
import '../utils/pdf_generator.dart';

class RapportService {

  static const String baseUrl = 'http://localhost:8000/api';
  static const String sanctumUrl = 'http://localhost:8000';
  
  // ✅ Protection CSRF pour Laravel Sanctum
  static Future<void> _initCsrf() async {
    try {
      final client = http.Client();
      final response = await client.get(
        Uri.parse('$sanctumUrl/sanctum/csrf-cookie'),
        headers: {
          'Accept': 'application/json',
          'Origin': 'http://localhost:8000',
          'Referer': 'http://localhost:8000/',
        },
      );
      
      // Extraire le cookie XSRF-TOKEN de la réponse pour le transmettre
      final xsrfToken = response.headers['set-cookie']?.split(';').firstWhere(
        (c) => c.contains('XSRF-TOKEN'), 
        orElse: () => ''
      );
      
      if (xsrfToken != null && xsrfToken.isNotEmpty) {
        print('✅ CSRF cookie récupéré pour rapports');
      } else {
        print('✅ CSRF cookie défait pour rapports');
      }
      
      client.close();
    } catch (e) {
      print('⚠️ Erreur CSRF rapports: $e');
    }
  }
  
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-XSRF-TOKEN': token ?? '',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Liste des rapports
  static Future<List<Rapport>> getRapports() async {
    // ✅ Initialiser CSRF avant les requêtes authentifiées
    await _initCsrf();
    
    final response = await http.get(
      Uri.parse('$baseUrl/rapports'),
      headers: await _getHeaders(),
    );

    print('📥 Response status rapports: ${response.statusCode}');
    print('📥 Response body rapports: ${response.body}');
    print('📥 Response headers: ${response.headers}');

    if (response.statusCode == 200) {
      // ✅ CORRIGÉ: Gérer les deux formats de réponse
      final body = response.body;
      if (body == null || body.isEmpty) {
        throw Exception('Réponse vide du serveur');
      }
      
      try {
        final dynamic jsonData = jsonDecode(body);
        print('✅ JSON décodé avec succès: ${jsonData.runtimeType}');
        
        // Le backend peut retourner une liste directe ou un objet {data: [...]}
        List<dynamic> dataList;
        if (jsonData is List) {
          print('📊 Format: Liste directe (${jsonData.length} éléments)');
          dataList = jsonData;
        } else if (jsonData is Map<String, dynamic>) {
          if (jsonData['data'] is List) {
            print('📊 Format: Objet avec clé "data" (${(jsonData['data'] as List).length} éléments)');
            dataList = jsonData['data'];
          } else if (jsonData['data'] is Map) {
            print('📊 Format: Objet avec clé "data" (map unique)');
            dataList = [jsonData['data']];
          } else {
            print('⚠️ Clés disponibles dans la réponse: ${jsonData.keys.toList()}');
            throw Exception('Format inattendu: clé "data" de type ${jsonData['data']?.runtimeType}');
          }
        } else {
          print('⚠️ Type de réponse: ${jsonData.runtimeType}');
          throw Exception('Format de réponse inattendu: ${jsonData.runtimeType}');
        }
        
        final rapports = dataList.map((json) => Rapport.fromJson(json)).toList();
        print('✅ ${rapports.length} rapports parsés avec succès');
        return rapports;
      } catch (e) {
        print('⚠️ Erreur détaillée lors du parsing:');
        print('   Type: ${e.runtimeType}');
        print('   Message: $e');
        print('   Body complet: $body');
        rethrow;
      }
    }
    throw Exception('Erreur liste rapports: ${response.statusCode} - ${response.body}');
  }

  // Créer un rapport manuel
  static Future<Rapport> createRapport(Rapport rapport) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rapports'),
      headers: await _getHeaders(),
      body: jsonEncode(rapport.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Rapport.fromJson(data['rapport']);
    }
    throw Exception('Erreur création rapport: ${response.statusCode}');
  }

  // Générer un rapport IA avec titre personnalisé
  static Future<Rapport> generateAiReport({
    required String periode,
    String? titre,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rapports/generer-ia'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'periode': periode,
          if (titre != null && titre.isNotEmpty) 'titre': titre,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Rapport.fromJson(data['rapport']);
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        throw Exception('Données invalides: ${error['message'] ?? 'Vérifiez les paramètres'}');
      } else if (response.statusCode == 401) {
        throw Exception('Authentification requise');
      } else if (response.statusCode == 500) {
        throw Exception('Erreur serveur. Réessayez plus tard.');
      } else {
        throw Exception('Erreur génération IA: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Délai d\'attente dépassé. Vérifiez votre connexion.');
      }
      rethrow;
    }
  }

  // Télécharger un rapport
  static Future<String> downloadRapport(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rapports/$id/download'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return response.body; // Retourne le HTML
    }
    throw Exception('Erreur téléchargement: ${response.statusCode}');
  }

  // Détail d'un rapport
  static Future<Rapport> getRapport(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rapports/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Rapport.fromJson(jsonDecode(response.body));
    }
    throw Exception('Erreur détail rapport: ${response.statusCode}');
  }

  // Supprimer un rapport
  static Future<void> deleteRapport(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/rapports/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur suppression: ${response.statusCode}');
    }
  }

  // Nouvelles fonctionnalités avancées
  
  // Télécharger et sauvegarder un rapport localement
  static Future<String?> downloadAndSaveRapport(int id) async {
    try {
      final htmlContent = await downloadRapport(id);
      
      // Créer le nom du fichier
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'rapport_${id}_$timestamp.html';
      
      // Note: Dans un vrai environnement, vous utiliseriez path_provider
      // pour sauvegarder dans le répertoire de téléchargements
      print('Fichier à sauvegarder: $fileName');
      print('Contenu HTML (premiers 200 caractères): ${htmlContent.substring(0, 200)}...');
      
      return fileName;
    } catch (e) {
      throw Exception('Erreur téléchargement et sauvegarde: $e');
    }
  }
  
  // Partager un rapport (simulation)
  static Future<void> shareRapport(int id) async {
    try {
      final rapport = await getRapport(id);
      final shareText = '''
📊 Rapport AgriFarm - ${rapport.titre}

${rapport.contenu.substring(0, 500)}${rapport.contenu.length > 500 ? '...' : ''}

Créé le: ${rapport.dateCompleteFormatee}
Période: ${rapport.periodeDisplay}

Généré par AgriFarm App
      ''';
      
      print('Partage du rapport:');
      print('Titre: ${rapport.titre}');
      print('Contenu à partager: ${shareText.substring(0, 200)}...');
      
      // Dans une vraie implémentation, vous utiliseriez share_plus
      // await Share.share(shareText, subject: 'Rapport AgriFarm - ${rapport.titre}');
    } catch (e) {
      throw Exception('Erreur partage: $e');
    }
  }
  
  // Copier le contenu d'un rapport dans le presse-papiers
  static Future<void> copyRapportContent(int id) async {
    try {
      final rapport = await getRapport(id);
      final copyText = '''
📊 ${rapport.titre}

${rapport.contenu}

---
Créé le: ${rapport.dateCompleteFormatee}
Période: ${rapport.periodeDisplay}
      ''';
      
      print('Contenu copié dans le presse-papiers:');
      print(copyText);
      
      // Dans une vraie implémentation, vous utiliseriez clipboard
      // await Clipboard.setData(ClipboardData(text: copyText));
    } catch (e) {
      throw Exception('Erreur copie: $e');
    }
  }
  
  // Obtenir un rapport par ID avec gestion d'erreur améliorée
  static Future<Rapport> getRapportById(int id) async {
    try {
      return await getRapport(id);
    } catch (e) {
      throw Exception('Erreur récupération rapport $id: $e');
    }
  }
  
  // Recherche de rapports (côté client)
  static List<Rapport> searchRapports(List<Rapport> rapports, String query) {
    if (query.isEmpty) return rapports;
    
    final lowercaseQuery = query.toLowerCase();
    return rapports.where((rapport) {
      return rapport.titre.toLowerCase().contains(lowercaseQuery) ||
             rapport.contenu.toLowerCase().contains(lowercaseQuery) ||
             rapport.periode.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
  
  // Filtrer les rapports par période
  static List<Rapport> filterRapportsByPeriode(List<Rapport> rapports, String periode) {
    if (periode == 'tous') return rapports;
    return rapports.where((rapport) => rapport.periode == periode).toList();
  }
  
  // Trier les rapports
  static List<Rapport> sortRapports(List<Rapport> rapports, String sortBy, bool descending) {
    final sorted = List<Rapport>.from(rapports);
    
    sorted.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'titre':
          comparison = a.titre.compareTo(b.titre);
          break;
        case 'periode':
          comparison = a.periode.compareTo(b.periode);
          break;
        case 'created_at':
        default:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return descending ? -comparison : comparison;
    });
    
    return sorted;
  }
  
  // Générer un rapport avec options avancées
  static Future<Rapport> generateAiReportAdvanced({
    required String periode,
    String? titre,
    bool includeWeather = true,
    bool includeSales = true,
    bool includeRecommendations = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rapports/generer-ia'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'periode': periode,
          if (titre != null && titre.isNotEmpty) 'titre': titre,
          'include_weather': includeWeather,
          'include_sales': includeSales,
          'include_recommendations': includeRecommendations,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Rapport.fromJson(data['rapport']);
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        throw Exception('Données invalides: ${error['message'] ?? 'Vérifiez les paramètres'}');
      } else if (response.statusCode == 401) {
        throw Exception('Authentification requise');
      } else if (response.statusCode == 500) {
        throw Exception('Erreur serveur. Réessayez plus tard.');
      } else {
        throw Exception('Erreur génération IA avancée: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Délai d\'attente dépassé. Vérifiez votre connexion.');
      }
      rethrow;
    }
  }
  
  // Obtenir les statistiques des rapports
  static Map<String, dynamic> getRapportsStatistics(List<Rapport> rapports) {
    final stats = <String, dynamic>{
      'total': rapports.length,
      'par_periode': <String, int>{},
      'par_mois': <String, int>{},
      'avec_meteo': 0,
      'sans_meteo': 0,
    };
    
    for (final rapport in rapports) {
      // Statistiques par période
      stats['par_periode'][rapport.periode] = 
          (stats['par_periode'][rapport.periode] ?? 0) + 1;
      
      // Statistiques par mois
      final mois = '${rapport.createdAt.year}-${rapport.createdAt.month.toString().padLeft(2, '0')}';
      stats['par_mois'][mois] = (stats['par_mois'][mois] ?? 0) + 1;
      
      // Statistiques météo
      if (rapport.aDonneesMeteo) {
        stats['avec_meteo']++;
      } else {
        stats['sans_meteo']++;
      }
    }
    
    return stats;
  }

  // ✅ NOUVELLE MÉTHODE: Télécharger et sauvegarder en PDF
  // Cette méthode génère un PDF professionnel et le sauvegarde localement
  static Future<String> downloadRapportPdf(Rapport rapport) async {
    try {
      print('🚀 Début génération PDF pour rapport: ${rapport.id} - ${rapport.titre}');
      
      // 1. Générer le PDF professionnel
      final pdfBytes = await PdfGenerator.generateRapportPdf(rapport);
      print('✅ PDF généré: ${pdfBytes.length} octets');
      
      // 2. Générer le nom du fichier
      final fileName = PdfGenerator.generateFileName(rapport);
      print('📄 Nom du fichier: $fileName');
      
      // 3. Sauvegarder le PDF dans le répertoire de téléchargements
      final filePath = await PdfGenerator.savePdfToFile(
        pdfBytes: pdfBytes,
        fileName: fileName,
      );
      
      print('✅ PDF sauvegardé avec succès: $filePath');
      return filePath;
      
    } catch (e) {
      print('❌ Erreur génération PDF: $e');
      throw Exception('Erreur lors de la génération du PDF: $e');
    }
  }
}
