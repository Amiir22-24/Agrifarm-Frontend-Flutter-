// lib/widgets/rapports/success_message.dart
import 'package:flutter/material.dart';

class SuccessMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;
  final IconData? icon;
  final Color? iconColor;
  final Duration? duration;
  final bool autoClose;
  final String? subMessage;

  const SuccessMessage({
    Key? key,
    required this.message,
    this.onClose,
    this.icon,
    this.iconColor,
    this.duration,
    this.autoClose = true,
    this.subMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final successSnackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            icon ?? Icons.check_circle,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                if (subMessage != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      backgroundColor: iconColor ?? Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: duration ?? const Duration(seconds: 3),
      action: onClose != null
          ? SnackBarAction(
              label: 'Fermer',
              textColor: Colors.white,
              onPressed: onClose!,
            )
          : null,
    );

    return successSnackBar;
  }
}

// Widget de message de succès pour les actions
class SuccessActionMessage extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData? icon;

  const SuccessActionMessage({
    Key? key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon ?? Icons.check_circle,
              color: Colors.green[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: TextStyle(
                  color: Colors.green[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour les notifications de réussite en overlay
class SuccessOverlay extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;
  final IconData? icon;
  final Duration duration;

  const SuccessOverlay({
    Key? key,
    required this.message,
    this.onClose,
    this.icon,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              if (onClose != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onClose!,
                  child: const Text('Fermer'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Widget pour les messages de génération réussie
class GenerationSuccessMessage extends StatelessWidget {
  final VoidCallback? onViewReport;
  final VoidCallback? onGenerateAnother;

  const GenerationSuccessMessage({
    Key? key,
    this.onViewReport,
    this.onGenerateAnother,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 48,
              color: Colors.purple[600],
            ),
            const SizedBox(height: 12),
            Text(
              'Rapport généré avec succès !',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Votre rapport IA a été créé et est prêt à être consulté',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onViewReport != null) ...[
                  ElevatedButton.icon(
                    onPressed: onViewReport,
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Voir le rapport'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
                if (onGenerateAnother != null)
                  OutlinedButton.icon(
                    onPressed: onGenerateAnother,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nouveau rapport'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
