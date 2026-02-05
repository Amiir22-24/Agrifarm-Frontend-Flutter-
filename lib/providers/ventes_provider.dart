// 🔴 PRIORITÉ 1 - lib/providers/ventes_provider.dart
import 'package:flutter/material.dart';
import '../models/vente.dart';
import '../services/vente_service.dart';
import '../utils/unit_converter.dart';

class VentesProvider with ChangeNotifier {
  List<Vente> _ventes = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<Vente> get ventes => _ventes;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  int get totalVentes => _ventes.length;
  
  /// Revenu total des ventes
  /// Calcule automatiquement le montant si non fourni: quantite * prixUnitaire
  double get totalRevenue =>
    _ventes.fold(0.0, (sum, vente) => sum + (vente.montant ?? (vente.quantite * vente.prixUnitaire)));

  Future<void> fetchVentes({String? from, String? to}) async {
    _isLoading = true;
    _error = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final response = await VenteService.getVentes(
        from: from,
        to: to,
        page: _currentPage,
      );
      final List<dynamic> data = response['data'];
      _ventes = data.map((json) => Vente.fromJson(json)).toList();
      _hasMore = response['current_page'] < response['last_page'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    _currentPage++;
    notifyListeners();

    try {
      final response = await VenteService.getVentes(page: _currentPage);
      final List<dynamic> data = response['data'];
      final newVentes = data.map((json) => Vente.fromJson(json)).toList();
      _ventes.addAll(newVentes);
      _hasMore = response['current_page'] < response['last_page'];
    } catch (e) {
      _error = e.toString();
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Vérifie si une vente est possible (stock suffisant)
  /// Retourne un Map avec 'possible' (bool) et 'message' (String)
  Map<String, dynamic> canSell({
    required int stockId,
    required double quantite,
    required String unite,
    List<dynamic>? stocks,
  }) {
    // Trouver le stock dans la liste ou chercher par ID
    final stockList = stocks ?? [];
    dynamic stock;
    
    if (stockList.isNotEmpty) {
      stock = stockList.firstWhere(
        (s) => s.id == stockId || s['id'] == stockId,
        orElse: () => null,
      );
    }
    
    // Si pas trouvé dans la liste, on ne peut pas vérifier
    if (stock == null) {
      return {
        'possible': true,
        'message': 'Stock non trouvé, vérification ignorée',
        'details': {'stockNonTrouvé': true},
      };
    }
    
    // Récupérer la quantité et l'unité du stock
    final quantiteStock = stock.quantite is double 
        ? stock.quantite 
        : double.parse(stock.quantite.toString());
    final uniteStock = stock.unite is String ? stock.unite : 'kg';
    
    // Calculer la décrémentation
    final resultat = UnitConverter.calculerDecrement(
      stockActuel: quantiteStock,
      uniteStock: uniteStock,
      quantiteVendue: quantite,
      uniteVente: unite,
    );
    
    if (!resultat['possible']) {
      return {
        'possible': false,
        'message': 'Stock insuffisant pour cette vente.',
        'details': {
          'stockActuel': resultat['stockActuel'],
          'unite': resultat['unite'],
          'stockEnKg': resultat['stockEnKg'],
          'venteEnKg': resultat['venteEnKg'],
          'manquantKg': resultat['manquantKg'],
        },
      };
    }
    
    return {
      'possible': true,
      'message': 'Vente possible',
      'details': {
        'stockId': stockId,
        'nouvelleQuantite': resultat['nouvelleQuantite'],
        'unite': resultat['unite'],
        'stockRestantKg': resultat['stockRestantKg'],
      },
    };
  }

  /// Ajoute une vente avec vérification de stock et décrémentation
  Future<bool> addVente(Vente vente, {List<dynamic>? stocks}) async {
    try {
      // Vérifier si le stock est suffisant
      final stockId = vente.stockId;
      final quantite = vente.quantite;
      final unite = vente.stock?.unite ?? 'kg';
      
      final verification = canSell(
        stockId: stockId,
        quantite: quantite,
        unite: unite,
        stocks: stocks,
      );
      
      if (!verification['possible']) {
        _error = verification['message'];
        notifyListeners();
        return false;
      }
      
      // Créer la vente
      final newVente = await VenteService.createVente(vente);
      _ventes.insert(0, newVente);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVente(int id, Vente vente) async {
    try {
      final updatedVente = await VenteService.updateVente(id, vente);
      final index = _ventes.indexWhere((v) => v.id == id);
      if (index != -1) {
        _ventes[index] = updatedVente;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVente(int id) async {
    try {
      await VenteService.deleteVente(id);
      _ventes.removeWhere((v) => v.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Vente? getVenteById(int id) {
    try {
      return _ventes.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _ventes = [];
    _error = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }
}
