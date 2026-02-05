
// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/storage_helper.dart';
import '../models/user.dart';
import 'user_provider.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  User? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;

  // 🔐 Authentification
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);

      if (response['token'] != null) {
        // ✅ Débogage du token
        final token = response['token'];
        print('🔑 Token reçu du backend: $token');
        print('🔑 Longueur du token: ${token.length}');

        // Sauvegarder le token
        await StorageHelper.saveToken(token);

        // Vérifier que le token est bien sauvegardé
        final savedToken = await StorageHelper.getToken();
        print('🔑 Token sauvegardé: $savedToken');
        print('🔑 Longueur du token sauvegardé: ${savedToken?.length}');

        // Récupérer l'utilisateur si disponible
        if (response['user'] != null) {
          _user = User.fromJson(response['user']);
        }

        _isAuthenticated = true;
        notifyListeners();
        return true;
      }

      _error = 'Réponse invalide du serveur';
      return false;
    } catch (e) {
      // Gestion spécifique des erreurs d'authentification
      String errorMessage = e.toString();

      if (errorMessage.contains('401') || errorMessage.contains('Unauthorized')) {
        _error = 'Email ou mot de passe incorrect';
      } else if (errorMessage.contains('400') || errorMessage.contains('Bad Request')) {
        _error = 'Données de connexion invalides';
      } else if (errorMessage.contains('500') || errorMessage.contains('Internal Server Error')) {
        _error = 'Erreur serveur. Veuillez réessayer plus tard';
      } else if (errorMessage.contains('Connection') || errorMessage.contains('SocketException')) {
        _error = 'Erreur de connexion. Vérifiez votre réseau';
      } else {
        _error = 'Erreur de connexion. Veuillez réessayer';
      }

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.register(userData);
      
      if (response['token'] != null) {
        // Sauvegarder le token
        await StorageHelper.saveToken(response['token']);
        
        // Récupérer l'utilisateur si disponible
        if (response['user'] != null) {
          _user = User.fromJson(response['user']);
        }
        
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      
      _error = 'Réponse invalide du serveur';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Appel backend pour invalider le token
      await ApiService.logout();
    } catch (e) {
      // Ignorer les erreurs de logout côté serveur
      print('Erreur logout serveur: $e');
    } finally {
      // Nettoyer côté client dans tous les cas
      await StorageHelper.removeToken();
      _isAuthenticated = false;
      _user = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔄 Gestion des tokens et sessions
  Future<bool> checkAuthStatus() async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        _isAuthenticated = false;
        notifyListeners();
        return false;
      }

      // Vérifier la validité du token en récupérant l'utilisateur
      final response = await ApiService.getUser();
      if (response['user'] != null) {
        _user = User.fromJson(response['user']);
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      

      // Token invalide
      await StorageHelper.removeToken();
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Gestion spécifique des erreurs d'authentification
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        // Token expiré ou invalide
        await StorageHelper.clearAuth();
        _isAuthenticated = false;
        _user = null;
        _error = 'Session expirée. Veuillez vous reconnecter.';
        notifyListeners();
        return false;
      }
      
      // Autres erreurs réseau
      _error = 'Erreur de connexion. Vérifiez votre réseau.';
      _isAuthenticated = false;
      _user = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshAuth() async {
    await checkAuthStatus();
  }

  // 📝 Gestion des erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 🛠️ Méthodes utilitaires
  bool get hasValidSession => _isAuthenticated && _user != null;
  String? get userName => _user?.name;
  String? get userEmail => _user?.email;
  int? get userId => _user?.id;

  // ✅ Nouvelle méthode pour accéder au token directement
  Future<String?> getToken() async {
    return await StorageHelper.getToken();
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  // 🔄 Chargement initial avec synchronisation
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await checkAuthStatus();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
