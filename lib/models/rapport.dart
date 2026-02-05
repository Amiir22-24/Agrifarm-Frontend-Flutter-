// lib/models/rapport.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Rapport {
  final int id;
  final int userId;
  final String titre;
  final String periode; // 'jour' | 'semaine' | 'mois'
  final String contenu;
  final double? temperature;
  final int? humidite;
  final String? conditions; // Conditions météo
  final String? fichier; // Nom du fichier HTML
  final DateTime? generatedAt; // Date de génération par IA
  final String? aiPrompt; // Prompt utilisé pour la génération
  final DateTime createdAt;
  final DateTime updatedAt;

  Rapport({
    required this.id,
    required this.userId,
    required this.titre,
    required this.periode,
    required this.contenu,
    this.temperature,
    this.humidite,
    this.conditions,
    this.fichier,
    this.generatedAt,
    this.aiPrompt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rapport.fromJson(Map<String, dynamic> json) {
    return Rapport(
      id: json['id'],
      userId: json['user_id'],
      titre: json['titre'],
      periode: json['periode'],
      contenu: json['contenu'],
      // ✅ CORRIGÉ: Le backend peut retourner temperature comme String ou Double
      temperature: json['temperature'] != null 
          ? (json['temperature'] is double 
              ? json['temperature'] 
              : double.tryParse(json['temperature'].toString()))
          : null,
      humidite: json['humidite'],
      conditions: json['conditions'],
      fichier: json['fichier'],
      generatedAt: json['generated_at'] != null 
          ? DateTime.parse(json['generated_at'])
          : null,
      aiPrompt: json['ai_prompt'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'titre': titre,
      'periode': periode,
      'contenu': contenu,
      if (temperature != null) 'temperature': temperature,
      if (humidite != null) 'humidite': humidite,
      if (conditions != null) 'conditions': conditions,
      if (fichier != null) 'fichier': fichier,
      if (generatedAt != null) 'generated_at': generatedAt!.toIso8601String(),
      if (aiPrompt != null) 'ai_prompt': aiPrompt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copier avec modifications
  Rapport copyWith({
    int? id,
    int? userId,
    String? titre,
    String? periode,
    String? contenu,
    double? temperature,
    int? humidite,
    String? conditions,
    String? fichier,
    DateTime? generatedAt,
    String? aiPrompt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Rapport(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titre: titre ?? this.titre,
      periode: periode ?? this.periode,
      contenu: contenu ?? this.contenu,
      temperature: temperature ?? this.temperature,
      humidite: humidite ?? this.humidite,
      conditions: conditions ?? this.conditions,
      fichier: fichier ?? this.fichier,
      generatedAt: generatedAt ?? this.generatedAt,
      aiPrompt: aiPrompt ?? this.aiPrompt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getters pour l'affichage
  String get dateFormatee => DateFormat('dd MMM yyyy').format(createdAt);
  String get heureFormatee => DateFormat('HH:mm').format(createdAt);
  String get dateCompleteFormatee => DateFormat('dd MMM yyyy à HH:mm').format(createdAt);
  
  String get apercuContenu => contenu.length > 100 
      ? '${contenu.substring(0, 100)}...' 
      : contenu;
      
  String get iconePeriode {
    switch (periode.toLowerCase()) {
      case 'jour':
        return '📅';
      case 'semaine':
        return '📊';
      case 'mois':
        return '📈';
      default:
        return '📄';
    }
  }
  
  // Alias pour compatibilité avec l'ancien code
  String get typeIcon => iconePeriode;
  
  Color get couleurPeriode {
    switch (periode.toLowerCase()) {
      case 'jour':
        return Colors.blue;
      case 'semaine':
        return Colors.green;
      case 'mois':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  String get periodeDisplay {
    switch (periode.toLowerCase()) {
      case 'jour':
        return '📅 Journalier';
      case 'semaine':
        return '📊 Hebdomadaire';
      case 'mois':
        return '📈 Mensuel';
      default:
        return '📄 ${periode.toUpperCase()}';
    }
  }
  
  String get iconeMeteo {
    if (conditions == null) return '🌤️';
    
    switch (conditions!.toLowerCase()) {
      case 'ensoleillé':
      case 'clair':
        return '☀️';
      case 'nuageux':
        return '☁️';
      case 'pluvieux':
      case 'pluie':
        return '🌧️';
      case 'neigeux':
      case 'neige':
        return '❄️';
      case 'orages':
      case 'orageux':
        return '⛈️';
      case 'brumeux':
      case 'brouillard':
        return '🌫️';
      default:
        return '🌤️';
    }
  }
  
  bool get aTelechargement => fichier != null && fichier!.isNotEmpty;
  bool get aDonneesMeteo => temperature != null || humidite != null || conditions != null;
  bool get aAiPrompt => aiPrompt != null && aiPrompt!.isNotEmpty;
  
  // Utilitaires
  bool get isEmpty => contenu.trim().isEmpty;
  bool get hasContent => contenu.trim().isNotEmpty;
  
  int get tailleContenu => contenu.length;
  
  String get statusDisplay {
    if (generatedAt != null) {
      return 'Généré par IA le ${DateFormat('dd/MM/yyyy à HH:mm').format(generatedAt!)}';
    }
    return 'Créé le ${dateCompleteFormatee}';
  }
}
