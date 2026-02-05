// 🔴 PRIORITÉ 1 - lib/providers/cultures_provider.dart
import 'package:flutter/material.dart';
import '../models/culture.dart';
import '../services/culture_service.dart';

class CulturesProvider with ChangeNotifier {
  List<Culture> _cultures = [];
  bool _isLoading = false;
  String? _error;

  List<Culture> get cultures => _cultures;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalCultures => _cultures.length;

  Future<void> fetchCultures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cultures = await CultureService.getCultures();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCulture(Culture culture) async {
    try {
      final newCulture = await CultureService.createCulture(culture);
      _cultures.insert(0, newCulture);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCulture(int id, Culture culture) async {
    try {
      final updated = await CultureService.updateCulture(id, culture);
      final index = _cultures.indexWhere((c) => c.id == id);
      if (index != -1) {
        _cultures[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCulture(int id) async {
    try {
      await CultureService.deleteCulture(id);
      _cultures.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _cultures = [];
    _error = null;
    notifyListeners();
  }
}
