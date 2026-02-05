// lib/utils/unit_converter.dart
// Utilitaire pour la conversion d'unités (kg ↔ tonne)

class UnitConverter {
  // Unités supportées
  static const String uniteKg = 'kg';
  static const String uniteTonne = 'tonne';
  static const List<String> unitesValides = [uniteKg, uniteTonne];

  // Facteurs de conversion vers kg
  static const Map<String, double> facteursVersKg = {
    uniteKg: 1.0,
    uniteTonne: 1000.0,
  };

  /// Convertit une valeur d'une unité vers une autre
  /// Retourne null si les unités sont invalides
  static double? convert({
    required double valeur,
    required String uniteSource,
    required String uniteCible,
  }) {
    // Validation des unités
    if (!unitesValides.contains(uniteSource) ||
        !unitesValides.contains(uniteCible)) {
      return null;
    }

    // Si même unité, retourner la valeur
    if (uniteSource == uniteCible) {
      return valeur;
    }

    // Convertir en kg puis vers l'unité cible
    final valeurEnKg = valeur * facteursVersKg[uniteSource]!;
    return valeurEnKg / facteursVersKg[uniteCible]!;
  }

  /// Convertit une valeur vers kg
  static double? toKg({
    required double valeur,
    required String unite,
  }) {
    if (!unitesValides.contains(unite)) {
      return null;
    }
    return valeur * facteursVersKg[unite]!;
  }

  /// Convertit une valeur depuis kg vers l'unité spécifiée
  static double? fromKg({
    required double valeurEnKg,
    required String uniteCible,
  }) {
    if (!unitesValides.contains(uniteCible)) {
      return null;
    }
    return valeurEnKg / facteursVersKg[uniteCible]!;
  }

  /// Vérifie si deux unités sont compatibles (même système de mesure)
  static bool sontCompatibles(String unite1, String unite2) {
    return unitesValides.contains(unite1) && unitesValides.contains(unite2);
  }

  /// Formate une valeur avec son unité de manière lisible
  static String formater(double valeur, String unite) {
    // Arrondir à 2 décimales pour l'affichage
    final valeurArrondie = double.parse(valeur.toStringAsFixed(2));
    
    // Choisir le format approprié selon l'unité
    if (unite == uniteTonne && valeurArrondie >= 1) {
      return '$valeurArrondie $unite';
    } else if (unite == uniteKg) {
      return '$valeurArrondie $unite';
    }
    
    return '$valeurArrondie $unite';
  }

  /// Formate avec conversion automatique pour l'affichage le plus lisible
  static String formaterOptimise(double valeur, String unite) {
    // Convertir en kg pour l'affichage si c'est une tonne
    if (unite == uniteTonne) {
      final valeurEnKg = valeur * 1000;
      // Si la valeur en kg est >= 1000, afficher en tonne
      if (valeurEnKg >= 1000) {
        return '${double.parse(valeur.toStringAsFixed(2))} $unite';
      }
      // Sinon convertir en kg
      return '${double.parse(valeurEnKg.toStringAsFixed(2))} $uniteKg';
    }
    
    // Si c'est en kg et que la valeur >= 1000, proposer en tonne
    if (unite == uniteKg && valeur >= 1000) {
      final valeurEnTonne = valeur / 1000;
      return '${double.parse(valeurEnTonne.toStringAsFixed(2))} $uniteTonne';
    }
    
    return '${double.parse(valeur.toStringAsFixed(2))} $unite';
  }

  /// Calcule le stock disponible après une vente
  /// Retourne la nouvelle quantité et un booléen indiquant si l'opération est possible
  static Map<String, dynamic> calculerDecrement({
    required double stockActuel,
    required String uniteStock,
    required double quantiteVendue,
    required String uniteVente,
  }) {
    // Convertir les deux quantités en kg pour la comparaison
    final stockEnKg = toKg(valeur: stockActuel, unite: uniteStock) ?? 0;
    final venteEnKg = toKg(valeur: quantiteVendue, unite: uniteVente) ?? 0;

    // Vérifier si le stock est suffisant
    final stockSuffisant = stockEnKg >= venteEnKg;

    if (stockSuffisant) {
      // Calculer le nouveau stock en kg
      final nouveauStockEnKg = stockEnKg - venteEnKg;
      // Convertir vers l'unité originale du stock
      final nouvelleQuantite = fromKg(
        valeurEnKg: nouveauStockEnKg,
        uniteCible: uniteStock,
      ) ?? 0;

      return {
        'possible': true,
        'nouvelleQuantite': double.parse(nouvelleQuantite.toStringAsFixed(2)),
        'unite': uniteStock,
        'stockRestantKg': stockEnKg - venteEnKg,
      };
    }

    return {
      'possible': false,
      'stockActuel': stockActuel,
      'unite': uniteStock,
      'stockEnKg': stockEnKg,
      'venteEnKg': venteEnKg,
      'manquantKg': venteEnKg - stockEnKg,
    };
  }

  /// Calcule le stock maximum possible basé sur les récoltes
  static Map<String, dynamic> calculerStockMax({
    required double quantiteRecolte,
    required String uniteRecolte,
    required double stockActuel,
    required String uniteStock,
  }) {
    // Convertir la récolte en kg
    final recolteEnKg = toKg(valeur: quantiteRecolte, unite: uniteRecolte) ?? 0;
    
    // Convertir le stock actuel en kg
    final stockEnKg = toKg(valeur: stockActuel, unite: uniteStock) ?? 0;

    // Calculer le stock max possible (récolte - stock actuel)
    final stockMaxEnKg = recolteEnKg - stockEnKg;

    if (stockMaxEnKg <= 0) {
      return {
        'possible': false,
        'stockMax': 0,
        'unite': uniteStock,
        'message': 'Le stock actuel est déjà égal ou supérieur à la récolte',
        'stockActuel': stockActuel,
        'recolteTotale': quantiteRecolte,
      };
    }

    // Convertir vers l'unité du stock
    final stockMax = fromKg(valeurEnKg: stockMaxEnKg, uniteCible: uniteStock) ?? 0;

    return {
      'possible': true,
      'stockMax': double.parse(stockMax.toStringAsFixed(2)),
      'unite': uniteStock,
      'stockActuel': stockActuel,
      'recolteTotale': quantiteRecolte,
      'stockRestantApresStockage': double.parse(
        (stockMaxEnKg - stockMax).toStringAsFixed(2)
      ),
    };
  }
}
