// lib/models/recolte.dart
import 'culture.dart';

class Recolte {
  final int? id;
  final int cultureId;
  final int? userId;
  final DateTime dateRecolte;
  final double quantite;
  final String unite;
  final String qualite;
  final String? observation;
  final double? prixVente;
  final String? destination;
  final Culture? culture;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Recolte({
    this.id,
    required this.cultureId,
    this.userId,
    required this.dateRecolte,
    required this.quantite,
    this.unite = 'kg',
    required this.qualite,
    this.observation,
    this.prixVente,
    this.destination,
    this.culture,
    this.createdAt,
    this.updatedAt,
  });

  factory Recolte.fromJson(Map<String, dynamic> json) {
    return Recolte(
      id: json['id'],
      cultureId: json['culture_id'],
      userId: json['user_id'],
      dateRecolte: DateTime.parse(json['date_recolte']),
      quantite: double.parse(json['quantite'].toString()),
      qualite: json['qualite'],
      observation: json['observation'],
      culture: json['culture'] != null 
        ? Culture.fromJson(json['culture']) 
        : null,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      // ✅ CORRECTION: Ne pas envoyer user_id s'il est null - le backend le récupère du token
      if (userId != null) 'user_id': userId,
      'culture_id': cultureId,
      'date_recolte': dateRecolte.toIso8601String().split('T')[0],
      'quantite': quantite,
      'qualite': qualite,
      'unite': unite, // ✅ CORRECTION: Toujours envoyer unite - le backend le requiert
      if (observation != null && observation!.isNotEmpty) 'observation': observation!,
      if (prixVente != null) 'prix_vente': prixVente,
      if (destination != null && destination!.isNotEmpty) 'destination': destination!,
    };
  }

  String get qualiteIcon {
    switch (qualite.toLowerCase()) {
      case 'excellente':
        return '⭐⭐⭐';
      case 'bonne':
        return '⭐⭐';
      case 'moyenne':
        return '⭐';
      default:
        return '•';
    }
  }

  Recolte copyWith({
    int? id,
    int? cultureId,
    DateTime? dateRecolte,
    double? quantite,
    String? qualite,
    String? observation,
  }) {
    return Recolte(
      id: id ?? this.id,
      cultureId: cultureId ?? this.cultureId,
      dateRecolte: dateRecolte ?? this.dateRecolte,
      quantite: quantite ?? this.quantite,
      qualite: qualite ?? this.qualite,
      observation: observation ?? this.observation,
    );
  }
}