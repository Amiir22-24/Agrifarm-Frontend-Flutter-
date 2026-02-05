
// lib/models/culture.dart
class Culture {
  final int? id;
  final int? userId;
  final String nom;
  final String type;
  final double surface;
  final DateTime datePlantation;
  final String etat;
  final String? ville;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Culture({
    this.id,
    this.userId,
    required this.nom,
    required this.type,
    required this.surface,
    required this.datePlantation,
    required this.etat,
    this.ville,
    this.createdAt,
    this.updatedAt,
  });


  factory Culture.fromJson(Map<String, dynamic> json) {
    return Culture(
      id: json['id']?.toInt(),
      userId: json['user_id']?.toInt(),
      nom: json['nom']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      surface: double.parse(json['surface']?.toString() ?? '0'),
      datePlantation: DateTime.parse(json['date_plantation']?.toString() ?? DateTime.now().toIso8601String()),
      etat: json['etat']?.toString() ?? '',
      ville: json['ville']?.toString(),
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'type': type,
      'surface': surface,
      'date_plantation': datePlantation.toIso8601String().split('T')[0],
      'etat': etat,
      'user_id': userId, // ⭐ OBLIGATOIRE pour le backend
      if (ville != null) 'ville': ville,
    };
  }
}
