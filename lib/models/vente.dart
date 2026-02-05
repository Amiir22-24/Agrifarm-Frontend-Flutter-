// 🟡 CORRECTION - lib/models/vente.dart
import 'stock.dart';
import 'user.dart';

class Vente {
  final int? id;
  final int? userId;
  final int stockId;
  final double quantite;
  final double prixUnitaire;
  final String? client;  // ✅ CORRIGÉ: optionnel (nullable)
  final String statut;
  final DateTime dateVente;
  final double? montant;
  final Stock? stock;
  final User? user;
  final DateTime? createdAt;

  Vente({
    this.id,
    this.userId,
    required this.stockId,
    required this.quantite,
    required this.prixUnitaire,
    this.client,  // ✅ CORRIGÉ: optionnel
    required this.statut,
    required this.dateVente,
    this.montant,
    this.stock,
    this.user,
    this.createdAt,
  });

  factory Vente.fromJson(Map<String, dynamic> json) {
    return Vente(
      id: json['id'],
      userId: json['user_id'],  // ⭐ SYNCHRONISÉ
      stockId: json['stock_id'],
      quantite: double.parse(json['quantite'].toString()),
      prixUnitaire: double.parse(json['prix_unitaire'].toString()),
      client: json['client'],
      statut: json['statut'],
      dateVente: DateTime.parse(json['date_vente']),
      montant: json['montant'] != null 
        ? double.parse(json['montant'].toString()) : null,
      stock: json['stock'] != null ? Stock.fromJson(json['stock']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,  // ⭐ RELATION
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      'stock_id': stockId,
      'quantite': quantite,
      'prix_unitaire': prixUnitaire,
      'client': client,
      'montant': montant ?? (quantite * prixUnitaire), // Calcul automatique si null
      'statut': statut,
      'date_vente': dateVente.toIso8601String().split('T')[0],
    };
  }
}