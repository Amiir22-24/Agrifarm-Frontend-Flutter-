// lib/models/stock.dart - Modèle adapté pour correspondre au backend Laravel
// Séparation de la gestion du cycle de vie (péremption) et de l'état de disponibilité
import 'user.dart';
import 'culture.dart';

class Stock {
  final int? id;
  final int? userId;
  final int produit;  // ID de la culture/produit associée (correspond à 'produit' dans Laravel)
  final double quantite;
  final String unite;
  final DateTime dateEntree;  // Renommé de dateAchat -> date_entree (Laravel)
  final DateTime? dateExpiration;  // Nouvelle date d'expiration
  final DateTime? dateSortie;  // Nouveau champ pour date_sortie (Laravel)
  final String disponibilite;  // Statut de disponibilité (stocké en base): "Disponible", "Sortie", "Réservé"
  final String? statut;  // Conservé pour compatibilité backend, maintenant optionnel
  final User? user;
  Culture? _culture;  // Relation avec culture (mutable pour association)
  String? _produitNom;  // Nom du produit stocké temporairement pour affichage immédiat

  Stock({
    this.id,
    this.userId,
    required this.produit,
    required this.quantite,
    required this.unite,
    required this.dateEntree,
    this.dateExpiration,
    this.dateSortie,
    required this.disponibilite,
    this.statut,
    this.user,
    Culture? culture,
    String? produitNom,
  }) : _culture = culture,
       _produitNom = produitNom;

  /// Getter pour la culture
  Culture? get culture => _culture;

  /// Setter pour associer une culture après création
  set culture(Culture? value) {
    _culture = value;
  }

  /// Getter pour le nom du produit
  String? get produitNomValue => _produitNom;
  
  /// Setter pour définir le nom du produit temporairement
  set produitNomValue(String? value) {
    _produitNom = value;
  }

  // Propriété calculée pour l'affichage du produit
  String get produitNom {
    // Priorité 1: Si _produitNom existe (défini temporairement lors de la création)
    if (_produitNom != null && _produitNom!.isNotEmpty) {
      return _produitNom!;
    }
    // Priorité 2: Si culture.nom existe et n'est pas vide
    if (culture?.nom != null && culture!.nom.isNotEmpty) {
      return culture!.nom;
    }
    // Priorité 3: Sinon afficher "Stock #ID"
    return 'Stock #${id ?? produit}';
  }

  // Propriété pour vérifier si le stock a une expiration
  bool get hasExpiration => dateExpiration != null;

  // Propriété pour obtenir l'intervalle entre date de stockage et date d'expiration (en jours)
  int? get intervalleJours {
    if (dateExpiration == null) return null;
    return dateExpiration!.difference(dateEntree).inDays;
  }

  // Propriété pour obtenir les jours restants avant expiration (basé sur la date du jour)
  int? get joursRestants {
    if (dateExpiration == null) return null;
    if (isExpired) return null;
    return dateExpiration!.difference(DateTime.now()).inDays;
  }

  // Propriété pour vérifier si le stock est expiré (basé sur la date du jour vs date d'expiration)
  bool get isExpired {
    if (dateExpiration == null) return false;
    return DateTime.now().isAfter(dateExpiration!) || 
           DateTime.now().isAtSameMomentAs(dateExpiration!);
  }

  // Propriété pour vérifier si le stock est presque expiré (intervalle entre 15 et 1 jour)
  bool get isNearExpiration {
    if (dateExpiration == null) return false;
    final joursRestants = this.joursRestants;
    if (joursRestants == null) return false;
    return joursRestants >= 1 && joursRestants <= 15;
  }

  // Propriété pour vérifier si le stock est en bon état (plus de 15 jours restants)
  bool get isGoodState {
    if (dateExpiration == null) return true;
    final joursRestants = this.joursRestants;
    if (joursRestants == null) return true; // Pas d'expiration = toujours bon état
    return joursRestants > 15;
  }

  /// Propriété calculée pour le STATUT DE PÉREMPTION (calculé dynamiquement, non stocké en base)
  /// Logique:
  /// - "Bon état" : si pas d'expiration ou intervalle > 15 jours
  /// - "Presque expiré" : intervalle entre 15 jours et 1 jour
  /// - "Expiré" : date du jour >= date d'expiration
  String get peremptionStatut {
    if (dateExpiration == null) {
      return 'Bon état'; // Pas d'expiration = toujours en bon état
    }
    
    // Vérifier si expiré (date du jour >= date d'expiration)
    if (isExpired) {
      return 'Expiré';
    }
    
    // Calculer les jours restants
    final joursRestants = this.joursRestants ?? 0;
    
    if (joursRestants <= 15) {
      return 'Presque expiré';
    } else {
      return 'Bon état';
    }
  }

  // Propriété pour l'affichage de la disponibilité (valeur stockée en base)
  String get disponibiliteDisplay {
    return disponibilite;
  }

  // Méthode helper pour parser les nombres en gérant différents formats
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String && value.isNotEmpty) {
      final normalized = value.replaceAll(',', '.').trim();
      final parsed = double.tryParse(normalized);
      if (parsed != null) return parsed;
      return double.tryParse(value.replaceAll(' ', '').trim()) ?? 0.0;
    }
    return 0.0;
  }

// Méthode helper pour parser le produit (cultureId) avec gestion des clés alternatives
  static int _parseProduit(Map<String, dynamic> json) {
    if (json['produit'] != null) {
      if (json['produit'] is int) {
        return json['produit'];
      }
      if (json['produit'] is String) {
        final parsed = int.tryParse(json['produit']);
        if (parsed != null) return parsed;
        // Si c'est une chaîne non-numérique, essayer de parser le premier nombre
        final match = RegExp(r'\d+').firstMatch(json['produit']);
        if (match != null) {
          return int.parse(match.group(0)!);
        }
        return 0;
      }
      if (json['produit'] is Map) {
        // Le backend retourne {produit: {id: 1, nom: "..."}}
        final produitMap = json['produit'] as Map<String, dynamic>;
        if (produitMap['id'] != null) {
          if (produitMap['id'] is int) {
            return produitMap['id'];
          }
          if (produitMap['id'] is String) {
            return int.tryParse(produitMap['id']) ?? 0;
          }
        }
      }
    }
    // Clés alternatives
    if (json['culture_id'] != null) {
      if (json['culture_id'] is int) return json['culture_id'];
      if (json['culture_id'] is String) return int.tryParse(json['culture_id']) ?? 0;
    }
    if (json['product_id'] != null) {
      if (json['product_id'] is int) return json['product_id'];
      if (json['product_id'] is String) return int.tryParse(json['product_id']) ?? 0;
    }
    return 0;
  }

  // Méthode helper pour parser la quantité
  static double _parseQuantite(Map<String, dynamic> json) {
    if (json['quantite'] != null) {
      try {
        return double.parse(json['quantite'].toString());
      } catch (e) {
        return _parseDouble(json['quantite']);
      }
    }
    if (json['quantity'] != null) {
      return _parseDouble(json['quantity']);
    }
    return 0.0;
  }

  // Méthode helper pour parser la disponibilité avec gestion des clés alternatives
  static String _parseDisponibilite(Map<String, dynamic> json) {
    String? value;
    
    // Essayer 'disponibilite' en snake_case (nouveau champ)
    if (json['disponibilite'] != null) {
      value = json['disponibilite'] as String;
    }
    // Tomberback sur 'statut' pour compatibilité avec anciennes données
    else if (json['statut'] != null) {
      value = json['statut'] as String;
    }
    // Si pas de valeur, retourner la valeur par défaut
    if (value == null || value.isEmpty) {
      return 'Disponible';
    }
    
    // Normaliser la valeur pour correspondre aux attentes de l'interface
    // Le backend peut retourner "disponible", "DISPONIBLE", etc.
    final normalizedValue = value.toLowerCase().trim();
    
    // Mapper les valeurs du backend aux valeurs attendues par l'interface
    if (normalizedValue == 'disponible' || normalizedValue == 'dispo') {
      return 'Disponible';
    }
    if (normalizedValue == 'réservé' || normalizedValue == 'reserve' || normalizedValue == 'reserve') {
      return 'Réservé';
    }
    if (normalizedValue == 'sortie' || normalizedValue == 'sorti') {
      return 'Sortie';
    }
    
    // Valeur inconnue, retourner tel quel (sera affiché comme "Inconnu" dans l'interface)
    return value;
  }

  factory Stock.fromJson(Map<String, dynamic> json) {
    print('🔍 === DEBUG Stock.fromJson ===');
    print('🔍 Clés disponibles: ${json.keys.toList()}');
    
    // Debug pour chaque champ important
    print('🔍 date_entree: ${json['date_entree']}');
    print('🔍 date_expiration: ${json['date_expiration']}');
    print('🔍 disponibilite: ${json['disponibilite']}');
    print('🔍 statut: ${json['statut']}');
    
    final dateExpiration = json['date_expiration'] != null
      ? DateTime.parse(json['date_expiration'] as String) : null;
    
    final disponibilite = _parseDisponibilite(json);
    
    print('🔍 Parsed dateExpiration: $dateExpiration');
    print('🔍 Parsed disponibilite: $disponibilite');
    
    return Stock(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      produit: _parseProduit(json),
      quantite: _parseQuantite(json),
      unite: json['unite'] as String? ?? '',
      dateEntree: DateTime.parse(json['date_entree'] as String),
      dateExpiration: dateExpiration,
      dateSortie: json['date_sortie'] != null
        ? DateTime.parse(json['date_sortie'] as String) : null,
      disponibilite: disponibilite,
      statut: json['statut'] as String?,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
      culture: json['culture'] != null ? Culture.fromJson(json['culture'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      // Le backend attend 'produit' comme string (ID de la culture)
      'produit': produit.toString(),
      'quantite': quantite,
      'unite': unite,
      'date_entree': dateEntree.toIso8601String().split('T')[0],
      // NOTE: date_expiration n'est plus envoyé car le backend ne supporte pas ce champ
      if (dateSortie != null) 'date_sortie': dateSortie!.toIso8601String().split('T')[0],
      // Le backend attend 'disponibilite' et non 'statut'
      'disponibilite': disponibilite,
      if (statut != null) 'statut': statut,
    };
  }
}

