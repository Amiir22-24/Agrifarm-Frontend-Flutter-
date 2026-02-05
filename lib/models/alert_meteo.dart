// lib/models/alert_meteo.dart
class AlertMeteo {
  final int? id;
  final String type; // 'orage', 'gel', 'secheresse', 'vent_fort'
  final String niveau; // 'info', 'warning', 'critical'
  final String message;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final String? ville;
  final bool active;

  AlertMeteo({
    this.id,
    required this.type,
    required this.niveau,
    required this.message,
    required this.dateDebut,
    this.dateFin,
    this.ville,
    this.active = true,
  });

  factory AlertMeteo.fromJson(Map<String, dynamic> json) {
    return AlertMeteo(
      id: json['id'],
      type: json['type'],
      niveau: json['niveau'],
      message: json['message'],
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: json['date_fin'] != null ? DateTime.parse(json['date_fin']) : null,
      ville: json['ville'],
      active: json['active'] == 1 || json['active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'niveau': niveau,
      'message': message,
      'date_debut': dateDebut.toIso8601String(),
      if (dateFin != null) 'date_fin': dateFin!.toIso8601String(),
      if (ville != null) 'ville': ville,
      'active': active ? 1 : 0,
    };
  }

  // Utilitaires pour l'affichage
  String get typeDisplay {
    switch (type) {
      case 'orage':
        return 'Orage';
      case 'gel':
        return 'Gel';
      case 'secheresse':
        return 'Sécheresse';
      case 'vent_fort':
        return 'Vent fort';
      default:
        return 'Alerte météo';
    }
  }

  String get niveauDisplay {
    switch (niveau) {
      case 'info':
        return 'Information';
      case 'warning':
        return 'Attention';
      case 'critical':
        return 'Critique';
      default:
        return 'Alerte';
    }
  }

  // Icônes et couleurs selon le type
  String get icon {
    switch (type) {
      case 'orage':
        return '⛈️';
      case 'gel':
        return '❄️';
      case 'secheresse':
        return '🌵';
      case 'vent_fort':
        return '💨';
      default:
        return '⚠️';
    }
  }

  // Couleurs selon le niveau
  String get colorHex {
    switch (niveau) {
      case 'info':
        return '#2196F3'; // Bleu
      case 'warning':
        return '#FF9800'; // Orange
      case 'critical':
        return '#F44336'; // Rouge
      default:
        return '#9E9E9E'; // Gris
    }
  }

  bool get isActive => active && (dateFin == null || dateFin!.isAfter(DateTime.now()));
  
  String get duree {
    if (dateFin == null) return 'En cours';
    
    final diff = dateFin!.difference(DateTime.now());
    if (diff.inDays > 0) {
      return 'Restant ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
    } else if (diff.inHours > 0) {
      return 'Restant ${diff.inHours} heure${diff.inHours > 1 ? 's' : ''}';
    } else {
      return 'Bientôt terminé';
    }
  }
}
