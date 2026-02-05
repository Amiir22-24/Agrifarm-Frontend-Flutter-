// lib/utils/rapport_messages.dart
import 'package:flutter/material.dart';

/// Énumération des langues supportées
enum RapportLanguage {
  french,
  english,
}

/// Gestionnaire des messages centralisés pour la section rapports
class RapportMessages {
  static RapportLanguage _currentLanguage = RapportLanguage.french;
  
  /// Langue actuelle
  static RapportLanguage get currentLanguage => _currentLanguage;
  
  /// Changer la langue
  static void setLanguage(RapportLanguage language) {
    _currentLanguage = language;
  }

  /// Messages de succès
  static String get rapportGenere => _getMessage('rapport_genere');
  static String get rapportSupprime => _getMessage('rapport_supprime');
  static String get rapportTelecharge => _getMessage('rapport_telecharge');
  static String get rapportPartage => _getMessage('rapport_partage');
  static String get rapportCopie => _getMessage('rapport_copie');
  static String get rapportsSupprimes => _getMessage('rapports_supprimes');

  /// Messages d'erreur
  static String get generationEchouee => _getMessage('generation_echouee');
  static String get chargementEchoue => _getMessage('chargement_echoue');
  static String get suppressionEchouee => _getMessage('suppression_echouee');
  static String get telechargementEchoue => _getMessage('telechargement_echoue');
  static String get partageEchoue => _getMessage('partage_echoue');
  static String get copieEchoue => _getMessage('copie_echoue');
  static String get donneesInvalides => _getMessage('donnees_invalides');
  static String get authentificationRequise => _getMessage('authentification_requise');
  static String get erreurServeur => _getMessage('erreur_serveur');
  static String get timeout => _getMessage('timeout');

  /// Messages d'information
  static String get aucunRapport => _getMessage('aucun_rapport');
  static String get generationEnCours => _getMessage('generation_en_cours');
  static String get telechargementEnCours => _getMessage('telechargement_en_cours');
  static String get chargementRapports => _getMessage('chargement_rapports');
  static String get rechercheRapports => _getMessage('recherche_rapports');
  static String get aucunResultat => _getMessage('aucun_resultat');

  /// Messages de confirmation
  static String suppressionConfirmation(String itemName) => 
      _getMessage('suppression_confirmation', [itemName]);
  static String regenerationConfirmation(String periode) => 
      _getMessage('regeneration_confirmation', [periode]);
  static String telechargementConfirmation(String fileName) => 
      _getMessage('telechargement_confirmation', [fileName]);
  static String batchActionConfirmation(String action, int count) => 
      _getMessage('batch_action_confirmation', [action, count.toString()]);

  /// Labels et titres
  static String get rapportsIA => _getMessage('rapports_ia');
  static String get genererRapport => _getMessage('generer_rapport');
  static String get periode => _getMessage('periode');
  static String get titre => _getMessage('titre');
  static String get contenu => _getMessage('contenu');
  static String get actions => _getMessage('actions');
  static String get supprimer => _getMessage('supprimer');
  static String get telecharger => _getMessage('telecharger');
  static String get partager => _getMessage('partager');
  static String get copier => _getMessage('copier');
  static String get voir => _getMessage('voir');
  static String get recherche => _getMessage('recherche');
  static String get filtres => _getMessage('filtres');
  static String get tri => _getMessage('tri');

  /// Périodes
  static String get jour => _getMessage('jour');
  static String get semaine => _getMessage('semaine');
  static String get mois => _getMessage('mois');
  static String get tous => _getMessage('tous');

  /// Options avancées
  static String get optionsAvancees => _getMessage('options_avancees');
  static String get inclureMeteo => _getMessage('inclure_meteo');
  static String get inclureVentes => _getMessage('inclure_ventes');
  static String get inclureRecommandations => _getMessage('inclure_recommandations');

  /// Messages contextuels
  static String get selectionMultiple => _getMessage('selection_multiple');
  static String get toutSelectionner => _getMessage('tout_selectionner');
  static String get deselectionner => _getMessage('deselectionner');
  static String get export => _getMessage('export');
  static String get pdf => _getMessage('pdf');
  static String get word => _getMessage('word');
  static String get html => _getMessage('html');

  /// Méthode interne pour obtenir un message
  static String _getMessage(String key, [List<String>? args]) {
    String message;
    
    switch (_currentLanguage) {
      case RapportLanguage.french:
        message = _frenchMessages[key] ?? key;
        break;
      case RapportLanguage.english:
        message = _englishMessages[key] ?? key;
        break;
    }
    
    // Remplacer les placeholders {0}, {1}, etc.
    if (args != null) {
      for (int i = 0; i < args.length; i++) {
        message = message.replaceAll('{$i}', args[i]);
      }
    }
    
    return message;
  }

  /// Messages en français
  static const Map<String, String> _frenchMessages = {
    // Succès
    'rapport_genere': '✅ Rapport généré avec succès !',
    'rapport_supprime': '✅ Rapport supprimé avec succès !',
    'rapport_telecharge': '✅ Téléchargement démarré !',
    'rapport_partage': '✅ Rapport partagé !',
    'rapport_copie': '✅ Contenu copié dans le presse-papiers !',
    'rapports_supprimes': '✅ {0} rapport(s) supprimé(s) avec succès !',

    // Erreurs
    'generation_echouee': '❌ Erreur lors de la génération du rapport',
    'chargement_echoue': '❌ Erreur lors du chargement des rapports',
    'suppression_echouee': '❌ Erreur lors de la suppression',
    'telechargement_echoue': '❌ Erreur lors du téléchargement',
    'partage_echoue': '❌ Erreur lors du partage',
    'copie_echoue': '❌ Erreur lors de la copie',
    'donnees_invalides': '❌ Données invalides: {0}',
    'authentification_requise': '❌ Authentification requise',
    'erreur_serveur': '❌ Erreur serveur. Réessayez plus tard.',
    'timeout': '❌ Délai d\'attente dépassé. Vérifiez votre connexion.',

    // Information
    'aucun_rapport': '📋 Aucun rapport disponible',
    'generation_en_cours': '🤖 Génération du rapport IA en cours...',
    'telechargement_en_cours': '⬇️ Préparation du téléchargement...',
    'chargement_rapports': 'Chargement des rapports...',
    'recherche_rapports': 'Recherche dans les rapports...',
    'aucun_resultat': 'Aucun résultat trouvé',

    // Confirmation
    'suppression_confirmation': 'Êtes-vous sûr de vouloir supprimer "{0}" ?',
    'regeneration_confirmation': 'Voulez-vous générer un nouveau rapport {0} ?',
    'telechargement_confirmation': 'Télécharger le fichier "{0}" ?',
    'batch_action_confirmation': 'Voulez-vous {0} {1} élément(s) ?',

    // Labels
    'rapports_ia': 'Rapports IA',
    'generer_rapport': 'Générer un Rapport IA',
    'periode': 'Période',
    'titre': 'Titre',
    'contenu': 'Contenu',
    'actions': 'Actions',
    'supprimer': 'Supprimer',
    'telecharger': 'Télécharger',
    'partager': 'Partager',
    'copier': 'Copier',
    'voir': 'Voir',
    'recherche': 'Rechercher',
    'filtres': 'Filtres',
    'tri': 'Trier',

    // Périodes
    'jour': 'Jour',
    'semaine': 'Semaine',
    'mois': 'Mois',
    'tous': 'Tous',

    // Options avancées
    'options_avancees': 'Options avancées',
    'inclure_meteo': 'Inclure les données météo',
    'inclure_ventes': 'Inclure les ventes',
    'inclure_recommandations': 'Inclure les recommandations',

    // Messages contextuels
    'selection_multiple': '{0} sélectionné(s)',
    'tout_selectionner': 'Tout sélectionner',
    'deselectionner': 'Désélectionner',
    'export': 'Exporter',
    'pdf': 'PDF',
    'word': 'Word',
    'html': 'HTML',
  };

  /// Messages en anglais
  static const Map<String, String> _englishMessages = {
    // Success
    'rapport_genere': '✅ Report generated successfully!',
    'rapport_supprime': '✅ Report deleted successfully!',
    'rapport_telecharge': '✅ Download started!',
    'rapport_partage': '✅ Report shared!',
    'rapport_copie': '✅ Content copied to clipboard!',
    'rapports_supprimes': '✅ {0} report(s) deleted successfully!',

    // Errors
    'generation_echouee': '❌ Error during report generation',
    'chargement_echoue': '❌ Error loading reports',
    'suppression_echouee': '❌ Error during deletion',
    'telechargement_echoue': '❌ Error during download',
    'partage_echoue': '❌ Error during sharing',
    'copie_echoue': '❌ Error during copy',
    'donnees_invalides': '❌ Invalid data: {0}',
    'authentification_requise': '❌ Authentication required',
    'erreur_serveur': '❌ Server error. Try again later.',
    'timeout': '❌ Timeout exceeded. Check your connection.',

    // Information
    'aucun_rapport': '📋 No reports available',
    'generation_en_cours': '🤖 AI report generation in progress...',
    'telechargement_en_cours': '⬇️ Preparing download...',
    'chargement_rapports': 'Loading reports...',
    'recherche_rapports': 'Searching reports...',
    'aucun_resultat': 'No results found',

    // Confirmation
    'suppression_confirmation': 'Are you sure you want to delete "{0}"?',
    'regeneration_confirmation': 'Do you want to generate a new {0} report?',
    'telechargement_confirmation': 'Download file "{0}"?',
    'batch_action_confirmation': 'Do you want to {0} {1} item(s)?',

    // Labels
    'rapports_ia': 'AI Reports',
    'generer_rapport': 'Generate AI Report',
    'periode': 'Period',
    'titre': 'Title',
    'contenu': 'Content',
    'actions': 'Actions',
    'supprimer': 'Delete',
    'telecharger': 'Download',
    'partager': 'Share',
    'copier': 'Copy',
    'voir': 'View',
    'recherche': 'Search',
    'filtres': 'Filters',
    'tri': 'Sort',

    // Periods
    'jour': 'Day',
    'semaine': 'Week',
    'mois': 'Month',
    'tous': 'All',

    // Advanced options
    'options_avancees': 'Advanced options',
    'inclure_meteo': 'Include weather data',
    'inclure_ventes': 'Include sales',
    'inclure_recommandations': 'Include recommendations',

    // Contextual messages
    'selection_multiple': '{0} selected',
    'tout_selectionner': 'Select all',
    'deselectionner': 'Deselect',
    'export': 'Export',
    'pdf': 'PDF',
    'word': 'Word',
    'html': 'HTML',
  };
}

/// Widget pour afficher les messages avec style
class RapportMessageWidget extends StatelessWidget {
  final String message;
  final MessageType type;
  final VoidCallback? onDismiss;

  const RapportMessageWidget({
    Key? key,
    required this.message,
    this.type = MessageType.info,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case MessageType.success:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case MessageType.error:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        icon = Icons.error;
        break;
      case MessageType.warning:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        icon = Icons.warning;
        break;
      case MessageType.info:
      default:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        icon = Icons.info;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: type == MessageType.error
              ? Colors.red.shade200
              : backgroundColor,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.close, size: 16, color: textColor),
              onPressed: onDismiss,
            ),
          ],
        ],
      ),
    );
  }
}

/// Types de messages
enum MessageType {
  success,
  error,
  warning,
  info,
}

/// Extension pour les SnackBars avec messages centralisés
extension RapportSnackBar on BuildContext {
  void showRapportSuccess(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: RapportMessageWidget(message: message, type: MessageType.success),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showRapportError(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: RapportMessageWidget(message: message, type: MessageType.error),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void showRapportInfo(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: RapportMessageWidget(message: message, type: MessageType.info),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
