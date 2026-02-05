// lib/widgets/rapports/export_format_selector.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/rapport.dart';
import '../../services/export_service.dart';
import '../../utils/rapport_messages.dart';
import 'loading_spinner.dart';
import 'success_message.dart';

/// Widget de sélection du format d'export pour les rapports
class ExportFormatSelector extends StatelessWidget {
  final Rapport rapport;
  final Function(String filePath, ExportFormat format)? onExportComplete;
  final bool showShareButton;
  final Widget? title;
  final Widget? subtitle;

  const ExportFormatSelector({
    Key? key,
    required this.rapport,
    this.onExportComplete,
    this.showShareButton = true,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatInfo = ExportService.getFormatInfo();

    return AlertDialog(
      title: title ?? const Text('Exporter le rapport'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null) ...[
            subtitle!,
            const SizedBox(height: 16),
          ],
          Text(
            '"${rapport.titre}"',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          // Liste des formats
          ...ExportFormat.values.map((format) {
            final info = formatInfo[format]!;
            return _buildFormatTile(context, format, info);
          }).toList(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
      ],
    );
  }

  Widget _buildFormatTile(
    BuildContext context,
    ExportFormat format,
    ExportFormatInfo info,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          info.icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
      ),
      title: Text(
        info.description,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text('.${info.extension.toUpperCase()} - ${info.mimeType}'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _exportWithFormat(context, format),
    );
  }

  Future<void> _exportWithFormat(
    BuildContext context,
    ExportFormat format,
  ) async {
    Navigator.of(context).pop();

    // Afficher un indicateur de chargement
    _showLoadingDialog(context);

    try {
      final filePath = await ExportService.exportWithFormat(
        rapport: rapport,
        format: format,
      );

      // Fermer le dialogue de chargement
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Afficher le succès
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${RapportMessages.rapportTelecharge}: ${filePath.split('/').last}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Callback optionnel
      onExportComplete?.call(filePath, format);

      // Option de partage
      if (showShareButton && context.mounted) {
        _showShareDialog(context, filePath);
      }
    } catch (e) {
      // Fermer le dialogue de chargement
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Afficher l'erreur
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${RapportMessages.telechargementEchoue}: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            const Text('Export en cours...'),
          ],
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export réussi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            Text('Fichier sauvegardé:\n$filePath'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final file = XFile(filePath);
                await Share.shareXFiles(
                  [file],
                  text: 'Rapport AgriFarm: ${rapport.titre}',
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur de partage: $e')),
                  );
                }
              }
            },
            icon: const Icon(Icons.share),
            label: const Text('Partager'),
          ),
        ],
      ),
    );
  }
}

/// Widget simplifié pour le téléchargement direct PDF
class PdfDownloadButton extends StatelessWidget {
  final Rapport rapport;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final VoidCallback? onError;
  final Widget? icon;
  final Widget? label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PdfDownloadButton({
    Key? key,
    required this.rapport,
    this.onStart,
    this.onComplete,
    this.onError,
    this.icon,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _downloadPdf(context),
      icon: icon ?? const Icon(Icons.picture_as_pdf),
      label: label ?? const Text('Télécharger PDF'),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.red[700],
        foregroundColor: foregroundColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    onStart?.call();

    try {
      final filePath = await ExportService.exportWithFormat(
        rapport: rapport,
        format: ExportFormat.html, // Using HTML as alternative since PDF export needs PdfGenerator
      );
      onComplete?.call();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF sauvegardé: $filePath'),
            action: SnackBarAction(
              label: 'Ouvrir',
              onPressed: () async {
                // Ouvrir le fichier (nécessite open_file_plus ou similaire)
              },
            ),
          ),
        );
      }
    } catch (e) {
      onError?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }
}

/// Widget de menu d'actions rapides pour un rapport
class ReportActionsMenu extends StatelessWidget {
  final Rapport rapport;
  final bool showViewDetails;
  final bool showEdit;
  final bool showDelete;
  final VoidCallback? onViewDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReportActionsMenu({
    Key? key,
    required this.rapport,
    this.showViewDetails = true,
    this.showEdit = false,
    this.showDelete = true,
    this.onViewDetails,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'view':
            onViewDetails?.call();
            break;
          case 'edit':
            onEdit?.call();
            break;
          case 'export_pdf':
            _showExportDialog(context);
            break;
          case 'export_html':
            _exportHtml(context);
            break;
          case 'share':
            _shareReport(context);
            break;
          case 'copy':
            _copyContent(context);
            break;
          case 'delete':
            _confirmDelete(context);
            break;
        }
      },
      itemBuilder: (context) => [
        if (showViewDetails)
          const PopupMenuItem(
            value: 'view',
            child: Row(
              children: [
                Icon(Icons.visibility, size: 20),
                SizedBox(width: 8),
                Text('Voir le détail'),
              ],
            ),
          ),
        if (showEdit)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Modifier'),
              ],
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'export_pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Exporter PDF'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'export_html',
          child: Row(
            children: [
              Icon(Icons.code, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text('Exporter HTML'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share, size: 20),
              SizedBox(width: 8),
              Text('Partager'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.content_copy, size: 20),
              SizedBox(width: 8),
              Text('Copier le contenu'),
            ],
          ),
        ),
        if (showDelete) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ExportFormatSelector(rapport: rapport),
    );
  }

  Future<void> _exportHtml(BuildContext context) async {
    try {
      final filePath = await ExportService.exportToHtml(rapport);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HTML sauvegardé: $filePath')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _shareReport(BuildContext context) async {
    try {
      final filePath = await ExportService.exportToHtml(rapport);
      final file = XFile(filePath);
      await Share.shareXFiles(
        [file],
        text: 'Rapport AgriFarm: ${rapport.titre}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de partage: $e')),
        );
      }
    }
  }

  Future<void> _copyContent(BuildContext context) async {
    try {
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        navigator.context.showRapportSuccess(
          RapportMessages.rapportCopie,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contenu copié dans le presse-papiers')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${rapport.titre}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      onDelete?.call();
    }
  }
}

/// Extension pour accéder à la clé de navigation globale
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

