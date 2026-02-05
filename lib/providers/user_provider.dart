// lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import 'auth_provider.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _userWeatherCity;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userWeatherCity => _userWeatherCity;

  Future<void> fetchUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getUser();
      if (response['user'] != null) {
        _user = User.fromJson(response['user']);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔄 Synchronisation avec AuthProvider
  Future<void> syncWithAuthProvider(AuthProvider authProvider) async {
    if (authProvider.user != null) {
      _user = authProvider.user;
      notifyListeners();
    } else {
      // Si pas de données dans AuthProvider, essayer de les récupérer
      await fetchUser();
    }
  }

  Future<bool> updateUser(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.updateUser(data);
      if (response['user'] != null) {
        _user = User.fromJson(response['user']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> updateWeatherCity(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.updateWeatherCity(city);
      
      // Mettre à jour localement la ville par défaut
      if (_user != null) {
        _user = User(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
          // Le modèle User a été mis à jour pour ne plus utiliser role et profile
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // 🆕 Récupérer la ville météo de l'utilisateur
  // CORRECTION: Utiliser d'abord la ville du profil si disponible
  Future<void> fetchUserWeatherCity() async {
    try {
      // D'abord essayer d'utiliser la ville du profil si elle existe
      if (_user?.profile?.defaultWeatherCity != null && 
          _user!.profile!.defaultWeatherCity.isNotEmpty) {
        _userWeatherCity = _user!.profile!.defaultWeatherCity;
        notifyListeners();
        return;
      }
      
      // Sinon récupérer depuis l'endpoint API
      final city = await ProfileService.getWeatherCity();
      if (city.isNotEmpty) {
        _userWeatherCity = city;
      } else {
        // Fallback vers une ville par défaut si rien n'est configuré
        _userWeatherCity = 'Paris';
      }
      notifyListeners();
    } catch (e) {
      // En cas d'erreur, utiliser une ville par défaut
      _userWeatherCity = 'Paris';
      notifyListeners();
    }
  }

  // 🆕 Mettre à jour la ville météo via ProfileService
  Future<bool> updateUserWeatherCity(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ProfileService.updateWeatherCity(city);
      _userWeatherCity = city;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // 🆕 Réinitialiser la ville météo (déconnexion)
  void clearWeatherCity() {
    _userWeatherCity = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    await fetchUser();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void updateUserLocally(User user) {
    _user = user;
    notifyListeners();
  }

  bool get hasUser => _user != null;
  String? get userName => _user?.name;
  String? get userEmail => _user?.email;

  // 🔧 DIAGNOSTIC : Méthode de déconnexion
  void logout() {
    _user = null;
    _isLoading = false;
    _error = null;
    _userWeatherCity = null;
    notifyListeners();
  }

  // 🆕 Changer le mot de passe
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ProfileService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
