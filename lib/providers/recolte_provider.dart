// lib/providers/recolte_provider.dart
import 'package:flutter/material.dart';
import '../models/recolte.dart';
import '../services/recolte_service.dart';

class RecolteProvider with ChangeNotifier {
  List<Recolte> _recoltes = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String? _error;

  List<Recolte> get recoltes => _recoltes;
  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalRecoltes => _recoltes.length;
  double get totalQuantite {
    return _recoltes.fold(0.0, (sum, r) => sum + r.quantite);
  }

  // Charger toutes les récoltes de l'utilisateur connecté
  Future<void> fetchRecoltes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Utiliser getMyRecoltes() si disponible, sinon utiliser getRecoltes()
      try {
        _recoltes = await RecolteService.getMyRecoltes();
      } catch (e) {
        // Fallback: utiliser l'ancienne route si /user/recoltes n'existe pas encore
        print('⚠️ Endpoint /user/recoltes non disponible, utilisation de /recoltes');
        _recoltes = await RecolteService.getRecoltes();
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Erreur fetchRecoltes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les statistiques
  Future<void> fetchStats() async {
    try {
      _stats = await RecolteService.getRecolteStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Ajouter une récolte
  Future<bool> addRecolte(Recolte recolte) async {
    try {
      final newRecolte = await RecolteService.createRecolte(recolte);
      _recoltes.insert(0, newRecolte);
      await fetchStats();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Mettre à jour une récolte
  Future<bool> updateRecolte(int id, Recolte recolte) async {
    try {
      final updated = await RecolteService.updateRecolte(id, recolte);
      final index = _recoltes.indexWhere((r) => r.id == id);
      if (index != -1) {
        _recoltes[index] = updated;
        await fetchStats();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Supprimer une récolte
  Future<bool> deleteRecolte(int id) async {
    try {
      await RecolteService.deleteRecolte(id);
      _recoltes.removeWhere((r) => r.id == id);
      await fetchStats();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Filtrer par culture
  List<Recolte> getRecoltesByCulture(int cultureId) {
    return _recoltes.where((r) => r.cultureId == cultureId).toList();
  }

  // Filtrer par qualité
  List<Recolte> getRecoltesByQualite(String qualite) {
    return _recoltes.where((r) => 
      r.qualite.toLowerCase() == qualite.toLowerCase()
    ).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _recoltes = [];
    _stats = null;
    _error = null;
    notifyListeners();
  }
}
