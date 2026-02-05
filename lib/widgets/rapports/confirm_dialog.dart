// lib/widgets/rapports/confirm_dialog.dart
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final Color? cancelColor;
  final IconData? icon;
  final bool isDangerous;
  final String? subMessage;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'Confirmer',
    this.cancelText = 'Annuler',
    this.confirmColor,
    this.cancelColor,
    this.icon,
    this.isDangerous = false,
    this.subMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          Icon(
            icon ?? (isDangerous ? Icons.warning : Icons.help_outline),
            color: isDangerous ? Colors.red : Colors.blue,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDangerous ? Colors.red[800] : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          if (subMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDangerous ? Colors.red[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDangerous ? Colors.red[200]! : Colors.blue[200]!,
                ),
              ),
              child: Text(
                subMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDangerous ? Colors.red[700] : Colors.blue[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: TextStyle(
              color: cancelColor ?? Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? (isDangerous ? Colors.red : Colors.blue),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            confirmText,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// Dialogue de confirmation spécialisé pour la suppression
class DeleteConfirmDialog extends StatelessWidget {
  final String itemName;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const DeleteConfirmDialog({
    Key? key,
    required this.itemName,
    required this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: 'Supprimer le rapport',
      message: 'Êtes-vous sûr de vouloir supprimer "$itemName" ?',
      subMessage: 'Cette action est irréversible.',
      icon: Icons.delete_forever,
      isDangerous: true,
      confirmText: 'Supprimer',
      confirmColor: Colors.red,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}

// Dialogue de confirmation pour les actions en lot
class BatchActionConfirmDialog extends StatelessWidget {
  final String action;
  final int itemCount;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const BatchActionConfirmDialog({
    Key? key,
    required this.action,
    required this.itemCount,
    required this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: 'Confirmer l\'action',
      message: 'Voulez-vous $action $itemCount rapport${itemCount > 1 ? 's' : ''} ?',
      subMessage: 'Cette action affectera plusieurs éléments.',
      icon: Icons.select_all,
      confirmText: action,
      confirmColor: Colors.orange,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}

// Dialogue de confirmation pour la génération de rapport
class GenerateConfirmDialog extends StatelessWidget {
  final String periode;
  final String? titre;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const GenerateConfirmDialog({
    Key? key,
    required this.periode,
    this.titre,
    required this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final periodeDisplay = {
      'jour': 'quotidien',
      'semaine': 'hebdomadaire',
      'mois': 'mensuel',
    }[periode] ?? periode;

    return ConfirmDialog(
      title: 'Générer un rapport IA',
      message: 'Créer un rapport $periodeDisplay${titre != null ? ' personnalisé' : ''} ?',
      subMessage: titre != null ? 'Titre: "$titre"' : 'Le rapport sera généré automatiquement avec un titre par défaut.',
      icon: Icons.auto_awesome,
      confirmText: 'Générer',
      confirmColor: Colors.purple,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}

// Dialogue de confirmation pour le téléchargement
class DownloadConfirmDialog extends StatelessWidget {
  final String fileName;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const DownloadConfirmDialog({
    Key? key,
    required this.fileName,
    required this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: 'Télécharger le rapport',
      message: 'Télécharger le fichier "$fileName" ?',
      subMessage: 'Le fichier sera enregistré dans votre dossier de téléchargements.',
      icon: Icons.download,
      confirmText: 'Télécharger',
      confirmColor: Colors.green,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}
