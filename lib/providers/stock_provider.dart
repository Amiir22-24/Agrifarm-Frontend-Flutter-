// lib/providers/stock_provider.dart
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/culture.dart';
import '../models/recolte.dart';
import '../services/stock_service.dart';
import '../services/culture_service.dart';
import '../utils/storage_helper.dart';
import '../utils/unit_converter.dart';
import 'auth_provider.dart';

class StockProvider with ChangeNotifier {
  List<Stock> _stocks = [];
  List<Culture> _cultures = [];
  List<Recolte> _recoltes = [];
  bool _isLoading = false;
  String? _error;

  List<Stock> get stocks => _stocks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalQuantite {
    return _stocks.fold(0.0, (sum, stock) => sum + stock.quantite);
  }

  int get nombreStocks => _stocks.length;

  // Getters pour le statut de péremption (calculé dynamiquement)
  int get stocksEnBonEtat => _stocks.where((s) => s.peremptionStatut == 'Bon état').length;
  int get stocksPresqueExpires => _stocks.where((s) => s.peremptionStatut == 'Presque expiré').length;
  int get stocksExpires => _stocks.where((s) => s.peremptionStatut == 'Expiré').length;

  // Getters pour le statut de disponibilité (données stockées)
  int get stocksDisponibles => _stocks.where((s) => s.disponibilite == 'Disponible').length;
  int get stocksReserves => _stocks.where((s) => s.disponibilite == 'Réservé').length;
  int get stocksSortis => _stocks.where((s) => s.disponibilite == 'Sortie').length;

  List<Stock> get stocksWithDisponibilite {
    return _stocks.where((s) => s.disponibilite == 'Disponible').toList();
  }

  /// Trouve une culture par son ID
  Culture? getCultureById(int cultureId) {
    try {
      return _cultures.firstWhere((c) => c.id == cultureId);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchStocks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        StockService.getStocks(),
        CultureService.getCultures().catchError((_) => <Culture>[]),
      ]);

      // Le service retourne directement List<Stock>, pas besoin de parser
      _stocks = results[0] as List<Stock>;
      _cultures = results[1] as List<Culture>;

      print('📦 === DEBUG FETCH STOCKS ===');
      print('📦 Nombre de stocks: ${_stocks.length}');
      print('📦 --- Statut de Péremption (calculé) ---');
      print('📦 En bon état: $stocksEnBonEtat');
      print('📦 Presque expirés: $stocksPresqueExpires');
      print('📦 Expirés: $stocksExpires');
      print('📦 --- Disponibilité (stocké) ---');
      print('📦 Disponibles: $stocksDisponibles');
      print('📦 Réservés: $stocksReserves');
      print('📦 Sortis: $stocksSortis');
      
      for (var stock in _stocks) {
        print('📦 Stock ID: ${stock.id} - produit: ${stock.produit}');
        print('📦   Péremption: ${stock.peremptionStatut}');
        print('📦   Disponibilité: ${stock.disponibiliteDisplay}');
        print('📦   Jours restants: ${stock.joursRestants ?? "Illimité"}');
      }

      _associateCulturesToStocks();
    } catch (e) {
      print('❌ Erreur fetchStocks: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Associe les cultures aux stocks en utilisant produit (cultureId)
  void _associateCulturesToStocks() {
    print('🔗 === ASSOCIATION CULTURES-STOCKS ===');
    for (var stock in _stocks) {
      final culture = getCultureById(stock.produit);
      if (culture != null) {
        stock.culture = culture;
        print('✅ Association réussie: Stock#${stock.id} -> Culture "${culture.nom}"');
      } else {
        print('⚠️ Aucune culture trouvée pour Stock#${stock.id} avec produit: ${stock.produit}');
      }
    }
  }

  Future<bool> addStock(Stock stock, AuthProvider authProvider) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final validationError = _validateStockData(stock);
      if (validationError != null) {
        _error = 'Données invalides: $validationError';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final userId = _getCurrentUserId(authProvider);
      if (userId == null) {
        _error = 'Utilisateur non connecté';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Conserver le nom du produit s'il est défini (pour affichage immédiat)
      final String? savedProduitNom = stock.produitNomValue;

      final stockWithUserId = Stock(
        id: stock.id,
        userId: userId,
        produit: stock.produit,
        quantite: stock.quantite,
        unite: stock.unite,
        dateEntree: stock.dateEntree,
        dateExpiration: stock.dateExpiration,
        dateSortie: stock.dateSortie,
        disponibilite: stock.disponibilite,
        statut: stock.statut,
        user: stock.user,
        culture: stock.culture,
        produitNom: savedProduitNom,
      );

      print('📦 === DEBUG ADD STOCK ===');
      print('📦 Produit ID: ${stock.produit}');
      print('📦 Date expiration: ${stock.dateExpiration}');
      print('📦 Disponibilité: ${stock.disponibilite}');

      final newStock = await StockService.createStock(stockWithUserId);
      
      // Associer immédiatement la culture au nouveau stock pour affichage
      final culture = getCultureById(newStock.produit);
      if (culture != null) {
        newStock.culture = culture;
        print('✅ Culture associée au nouveau stock: "${culture.nom}"');
      } else if (savedProduitNom != null) {
        // Si pas de culture trouvée, utiliser le nom temporaire
        newStock.produitNomValue = savedProduitNom;
        print('✅ Nom produit temporaire utilisé: "$savedProduitNom"');
      }

      _stocks.insert(0, newStock);
      _isLoading = false;
      notifyListeners();
      print('✅ Stock ajouté avec succès: ${newStock.produitNom}');
      return true;
    } catch (e) {
      print('❌ Erreur addStock: $e');
      _error = 'Erreur lors de l\'ajout: ${_getReadableError(e.toString())}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String? _validateStockData(Stock stock) {
    if (stock.produit <= 0) return 'Produit invalide';
    if (stock.quantite <= 0) return 'Quantité doit être supérieure à 0';
    if (stock.unite.isEmpty) return 'Unité requise';
    if (stock.disponibilite.isEmpty) return 'Disponibilité requise';
    if (stock.dateEntree.isAfter(DateTime.now())) return 'Date d\'entrée ne peut pas être dans le futur';
    if (stock.dateExpiration != null && stock.dateExpiration!.isBefore(stock.dateEntree)) {
      return 'Date d\'expiration doit être après la date d\'entrée';
    }
    if (stock.dateSortie != null && stock.dateSortie!.isBefore(stock.dateEntree)) {
      return 'Date de sortie doit être après la date d\'entrée';
    }
    return null;
  }

  int? _getCurrentUserId(AuthProvider authProvider) {
    return authProvider.userId;
  }

  String _getReadableError(String error) {
    print('🔍 ERREUR DÉTAILLÉE: $error');
    
    if (error.contains('VALIDATION_ERROR')) {
      return error.replaceAll('VALIDATION_ERROR: ', '').trim();
    } else if (error.contains('422')) {
      return 'Données invalides. Vérifiez les informations saisies.';
    } else if (error.contains('401') || error.contains('EMAIL_PASSWORD_INVALID')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    } else if (error.contains('403')) {
      return 'Accès refusé. Vérifiez vos permissions.';
    } else if (error.contains('404')) {
      return 'Ressource introuvable. Vérifiez le produit sélectionné.';
    } else if (error.contains('500')) {
      return 'Erreur serveur. Réessayez plus tard.';
    } else if (error.contains('503')) {
      return 'Service temporairement indisponible.';
    } else if (error.contains('network') || error.contains('Socket') || error.contains('Connection')) {
      return 'Problème de connexion. Vérifiez votre réseau.';
    } else if (error.contains('timeout') || error.contains('TimeoutException')) {
      return 'Délai d\'attente dépassé. Vérifiez votre connexion.';
    } else if (error.contains('parse') || error.contains('FormatException')) {
      return 'Erreur de format des données.';
    } else if (error.contains('null') || error.contains('null value')) {
      return 'Données manquantes. Vérifiez les champs obligatoires.';
    } else if (error.contains('SocketException') || error.contains('handshake')) {
      return 'Impossible de se connecter au serveur. Vérifiez que localhost:8000 est accessible.';
    } else if (error.contains('dart:convert') || error.contains('JSON')) {
      return 'Erreur de traitement des données.';
    }
    
    return 'Erreur inconnue: $error';
  }

  Future<bool> updateStock(int id, Stock stock) async {
    try {
      final updated = await StockService.updateStock(id, stock);
      final index = _stocks.indexWhere((s) => s.id == id);
      if (index != -1) {
        _stocks[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: ${_getReadableError(e.toString())}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStock(int id) async {
    try {
      await StockService.deleteStock(id);
      _stocks.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression: ${_getReadableError(e.toString())}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _stocks = [];
    _cultures = [];
    _recoltes = [];
    _error = null;
    notifyListeners();
  }

  // ========== NOUVELLES MÉTHODES POUR LA GESTION STOCK/RÉCOLTE/VENTE ==========

  /// Charge les récoltes pour une culture spécifique
  Future<void> fetchRecoltesForCulture(int cultureId) async {
    try {
      // Import dynamique du service de récolte
      final response = await _getRecoltesFromService(cultureId);
      if (response != null) {
        _recoltes = response;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Erreur fetchRecoltesForCulture: $e');
    }
  }

  /// Simule l'appel au service de récoltes (à remplacer par le vrai service)
  Future<List<Recolte>> _getRecoltesFromService(int cultureId) async {
    // Cette méthode sera remplacée par l'appel réel au service
    // Pour l'instant, retourne une liste vide
    return [];
  }

  /// Calcule la quantité totale récoltée pour une culture (en kg)
  double getTotalRecolteForCulture(int cultureId, [String? uniteCible]) {
    final recoltesCulture = _recoltes.where((r) => r.cultureId == cultureId);
    
    // Sommer toutes les quantités en kg
    double totalEnKg = 0;
    for (var recolte in recoltesCulture) {
      final quantiteEnKg = UnitConverter.toKg(
        valeur: recolte.quantite,
        unite: recolte.unite,
      ) ?? 0;
      totalEnKg += quantiteEnKg;
    }
    
    // Convertir vers l'unité cible si spécifiée
    if (uniteCible != null) {
      return UnitConverter.fromKg(valeurEnKg: totalEnKg, uniteCible: uniteCible) ?? 0;
    }
    
    return totalEnKg;
  }

  /// Calcule la quantité totale en stock pour une culture (en kg)
  double getTotalStockForCulture(int cultureId, [String? uniteCible]) {
    final stocksCulture = _stocks.where((s) => s.produit == cultureId);
    
    // Sommer toutes les quantités en kg
    double totalEnKg = 0;
    for (var stock in stocksCulture) {
      final quantiteEnKg = UnitConverter.toKg(
        valeur: stock.quantite,
        unite: stock.unite,
      ) ?? 0;
      totalEnKg += quantiteEnKg;
    }
    
    // Convertir vers l'unité cible si spécifiée
    if (uniteCible != null) {
      return UnitConverter.fromKg(valeurEnKg: totalEnKg, uniteCible: uniteCible) ?? 0;
    }
    
    return totalEnKg;
  }

  /// Vérifie si le stock peut être créé (ne dépasse pas la récolte)
  /// Retourne un Map avec 'possible' (bool) et 'message' (String)
  Map<String, dynamic> canCreateStock({
    required int cultureId,
    required double quantite,
    required String unite,
  }) {
    // Calculer le stock actuel pour cette culture
    final stockActuel = getTotalStockForCulture(cultureId, unite);
    
    // Calculer la récolte totale pour cette culture
    final recolteTotale = getTotalRecolteForCulture(cultureId, unite);
    
    // Vérifier si la nouvelle quantité dépasse la récolte
    final nouvelleQuantiteTotal = stockActuel + quantite;
    
    if (nouvelleQuantiteTotal > recolteTotale) {
      final stockMaxPossible = recolteTotale - stockActuel;
      return {
        'possible': false,
        'message': 'La quantité demandée ($quantite $unite) dépasse le stock maximum possible.',
        'details': {
          'stockActuel': stockActuel,
          'quantiteDemandee': quantite,
          'stockMaxPossible': stockMaxPossible > 0 ? stockMaxPossible : 0,
          'recolteTotale': recolteTotale,
          'unite': unite,
          'excès': nouvelleQuantiteTotal - recolteTotale,
        },
      };
    }
    
    return {
      'possible': true,
      'message': 'Stock valide',
      'details': {
        'stockActuel': stockActuel,
        'quantiteDemandee': quantite,
        'nouveauStock': nouvelleQuantiteTotal,
        'recolteTotale': recolteTotale,
        'unite': unite,
      },
    };
  }

  /// Vérifie si une vente peut être effectuée (stock suffisant)
  /// Retourne un Map avec 'possible' (bool) et 'message' (String)
  Map<String, dynamic> canSell({
    required int stockId,
    required double quantite,
    required String unite,
  }) {
    // Trouver le stock
    final stock = _stocks.firstWhere(
      (s) => s.id == stockId,
      orElse: () => throw Exception('Stock non trouvé'),
    );
    
    // Calculer la décrémentation
    final resultat = UnitConverter.calculerDecrement(
      stockActuel: stock.quantite,
      uniteStock: stock.unite,
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

  /// Décrémente le stock après une vente réussie
  /// Retourne true si succès, false sinon
  bool decrementStock({
    required int stockId,
    required double quantite,
    required String unite,
  }) {
    try {
      final index = _stocks.indexWhere((s) => s.id == stockId);
      if (index == -1) {
        print('❌ Stock non trouvé: $stockId');
        return false;
      }
      
      final stock = _stocks[index];
      
      // Vérifier si possible
      final resultat = UnitConverter.calculerDecrement(
        stockActuel: stock.quantite,
        uniteStock: stock.unite,
        quantiteVendue: quantite,
        uniteVente: unite,
      );
      
      if (!resultat['possible']) {
        print('❌ Décrémentation impossible: stock insuffisant');
        return false;
      }
      
      // Calculer la nouvelle quantité
      final nouvelleQuantite = resultat['nouvelleQuantite'] as double;
      final nouvelleDisponibilite = nouvelleQuantite <= 0.01 ? 'Sortie' : stock.disponibilite;
      
      // Créer un nouveau stock avec la quantité mise à jour
      final updatedStock = Stock(
        id: stock.id,
        userId: stock.userId,
        produit: stock.produit,
        quantite: nouvelleQuantite,
        unite: stock.unite,
        dateEntree: stock.dateEntree,
        dateExpiration: stock.dateExpiration,
        dateSortie: nouvelleQuantite <= 0.01 ? DateTime.now() : stock.dateSortie,
        disponibilite: nouvelleDisponibilite,
        statut: stock.statut,
        user: stock.user,
        culture: stock.culture,
      );
      
      // Remplacer l'ancien stock par le nouveau
      _stocks[index] = updatedStock;
      
      notifyListeners();
      print('✅ Stock décrémenté: ${updatedStock.produitNom} - Nouvelle quantité: ${updatedStock.quantite} ${updatedStock.unite}');
      return true;
    } catch (e) {
      print('❌ Erreur decrementStock: $e');
      return false;
    }
  }

  /// Récupère le stock disponible pour un produit donné
  Stock? getStockById(int stockId) {
    try {
      return _stocks.firstWhere((s) => s.id == stockId);
    } catch (e) {
      return null;
    }
  }

  /// Formate la quantité de manière lisible
  String formaterQuantite(double quantite, String unite) {
    return UnitConverter.formaterOptimise(quantite, unite);
  }
}
