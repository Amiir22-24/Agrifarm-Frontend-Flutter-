// lib/providers/rapport_provider.dart
import 'package:flutter/material.dart';
import '../models/rapport.dart';
import '../services/rapport_service.dart';
import '../utils/rapport_messages.dart';

class RapportProvider with ChangeNotifier {
  // États de base
  List<Rapport> _rapports = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;

  // Nouveaux états pour les fonctionnalités avancées
  List<Rapport> _filteredRapports = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  String _searchQuery = '';
  String _filterPeriode = 'tous';
  String _sortBy = 'created_at';
  bool _sortDesc = true;
  Set<int> _selectedIds = {};
  bool _isSelectionMode = false;
  bool _isDownloading = false;
  String? _successMessage;

  // Getters pour les états de base
  List<Rapport> get rapports => _rapports;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  bool get isDownloading => _isDownloading;
  String? get successMessage => _successMessage;

  int get totalRapports => _rapports.length;
  int get totalFilteredRapports => _filteredRapports.length;

  // Charger tous les rapports
  Future<void> fetchRapports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rapports = await RapportService.getRapports();
      // ✅ CORRECTION: Initialiser la liste filtrée
      _filteredRapports = List.from(_rapports);
      print('✅ ${_rapports.length} rapports chargés avec succès');
    } catch (e) {
      _error = e.toString();
      print('❌ Erreur fetchRapports: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Générer un rapport IA
  Future<Rapport?> generateAiReport({
    required String periode,
    String? titre,
  }) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      print('🚀 Début génération rapport IA - période: $periode');
      final rapport = await RapportService.generateAiReport(
        periode: periode,
        titre: titre,
      );
      
      print('✅ Rapport généré avec succès: ${rapport.id} - ${rapport.titre}');
      print('📄 Contenu: ${rapport.contenu.substring(0, 100)}...');
      print('🌡️ Température: ${rapport.temperature}');
      print('💧 Humidité: ${rapport.humidite}');
      
      _rapports.insert(0, rapport);
      
      // ✅ CORRECTION CRITIQUE: Mettre à jour la liste filtrée
      _applyFilters();
      
      notifyListeners();
      return rapport;
    } catch (e) {
      print('❌ Erreur génération rapport: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  // Créer un rapport manuel
  Future<bool> createRapport(Rapport rapport) async {
    try {
      final newRapport = await RapportService.createRapport(rapport);
      _rapports.insert(0, newRapport);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Télécharger un rapport
  Future<String?> downloadRapport(int id) async {
    try {
      return await RapportService.downloadRapport(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Supprimer un rapport
  Future<bool> deleteRapport(int id) async {
    try {
      await RapportService.deleteRapport(id);
      _rapports.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Filtrer par période
  List<Rapport> getRapportsByPeriode(String periode) {
    return _rapports.where((r) => r.periode == periode).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Nouveaux getters pour les fonctionnalités avancées
  List<Rapport> get filteredRapports => _filteredRapports;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  String get searchQuery => _searchQuery;
  String get filterPeriode => _filterPeriode;
  String get sortBy => _sortBy;
  bool get sortDesc => _sortDesc;
  Set<int> get selectedIds => _selectedIds;
  bool get isSelectionMode => _isSelectionMode;
  
  // Méthodes pour la gestion de la recherche et filtrage
  void updateSearch(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void updateFilter(String periode) {
    _filterPeriode = periode;
    _applyFilters();
    notifyListeners();
  }

  void updateSort(String sortBy, bool descending) {
    _sortBy = sortBy;
    _sortDesc = descending;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<Rapport> filtered = List.from(_rapports);

    // Filtrer par période
    if (_filterPeriode != 'tous') {
      filtered = filtered.where((r) => r.periode == _filterPeriode).toList();
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        return r.titre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               r.contenu.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Trier
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
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
      return _sortDesc ? -comparison : comparison;
    });

    _filteredRapports = filtered;
    print('📋 Filtres appliqués: ${filtered.length} rapports sur ${_rapports.length}');
  }

  // Méthodes pour la sélection multiple
  void toggleSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    
    if (_selectedIds.isEmpty) {
      _isSelectionMode = false;
    }
    
    notifyListeners();
  }

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedIds.clear();
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedIds = _filteredRapports.map((r) => r.id).toSet();
    _isSelectionMode = true;
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  // Actions en lot
  Future<bool> deleteSelected() async {
    if (_selectedIds.isEmpty) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      for (final id in _selectedIds) {
        await RapportService.deleteRapport(id);
      }
      _rapports.removeWhere((r) => _selectedIds.contains(r.id));
      _selectedIds.clear();
      _isSelectionMode = false;
      _applyFilters();
      _successMessage = '${_selectedIds.length} rapport(s) supprimé(s) avec succès';
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthodes de pagination
  void nextPage() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  // Méthodes de téléchargement avec état
  Future<String?> downloadRapportWithState(int id) async {
    _isDownloading = true;
    notifyListeners();

    try {
      final result = await RapportService.downloadRapport(id);
      _successMessage = 'Téléchargement réussi';
      return result;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  // ✅ NOUVELLE MÉTHODE: Télécharger et sauvegarder le PDF localement
  Future<String?> downloadPdfWithState(int id) async {
    _isDownloading = true;
    _error = null;
    notifyListeners();

    try {
      print('🚀 Début téléchargement PDF pour le rapport ID: $id');
      
      // 1. Récupérer le rapport
      final rapport = _rapports.firstWhere((r) => r.id == id);
      print('📄 Rapport trouvé: ${rapport.titre}');
      
      // 2. Générer et sauvegarder le PDF
      final filePath = await RapportService.downloadRapportPdf(rapport);
      
      _successMessage = 'PDF sauvegardé: $filePath';
      print('✅ Téléchargement PDF terminé: $filePath');
      
      return filePath;
      
    } catch (e) {
      print('❌ Erreur téléchargement PDF: $e');
      _error = 'Erreur lors du téléchargement du PDF: $e';
      notifyListeners();
      return null;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  // Méthodes utilitaires
  bool isSelected(int id) => _selectedIds.contains(id);
  int get selectedCount => _selectedIds.length;
  bool get hasSelection => _selectedIds.isNotEmpty;
  
  List<Rapport> get selectedRapports => 
      _rapports.where((r) => _selectedIds.contains(r.id)).toList();

  // Rafraîchir avec filtres appliqués
  Future<void> refreshWithFilters() async {
    await fetchRapports();
    _applyFilters();
  }

  // Réinitialiser tous les filtres
  void resetFilters() {
    _searchQuery = '';
    _filterPeriode = 'tous';
    _sortBy = 'created_at';
    _sortDesc = true;
    _currentPage = 1;
    _applyFilters();
    notifyListeners();
  }

  // Méthodes de partage et copie
  Future<void> shareRapport(int id) async {
    try {
      print('Partage du rapport $id');
    } catch (e) {
      _error = e.toString();
      throw Exception('Erreur partage: $e');
    }
  }

  Future<void> copyRapportContent(int id) async {
    try {
      final rapport = _rapports.firstWhere((r) => r.id == id);
      final copyText = '''
📊 ${rapport.titre}

${rapport.contenu}

---
Créé le: ${rapport.dateCompleteFormatee}
Période: ${rapport.periodeDisplay}
      ''';
      
      print('Contenu à copier: ${copyText.substring(0, 200)}...');
    } catch (e) {
      _error = e.toString();
      throw Exception('Erreur copie: $e');
    }
  }

  // Méthodes utilitaires pour les statistiques
  Map<String, dynamic> getStatistics() {
    return {
      'total': _rapports.length,
      'avec_meteo': _rapports.where((r) => r.aDonneesMeteo).length,
      'sans_meteo': _rapports.where((r) => !r.aDonneesMeteo).length,
      'par_periode': {
        'jour': _rapports.where((r) => r.periode == 'jour').length,
        'semaine': _rapports.where((r) => r.periode == 'semaine').length,
        'mois': _rapports.where((r) => r.periode == 'mois').length,
      },
    };
  }
}

