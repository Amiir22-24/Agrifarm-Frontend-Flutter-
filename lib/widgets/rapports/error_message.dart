// lib/widgets/rapports/error_message.dart
import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? iconColor;
  final String? retryText;
  final bool showIcon;

  const ErrorMessage({
    Key? key,
    required this.error,
    this.onRetry,
    this.icon,
    this.iconColor,
    this.retryText,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: iconColor ?? Colors.red[400],
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Oups ! Une erreur est survenue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red[200]!,
                ),
              ),
              child: Text(
                error,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(retryText ?? 'Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget d'erreur pour les listes vides
class EmptyListError extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;

  const EmptyListError({
    Key? key,
    required this.message,
    this.details,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Réessayer'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget d'erreur pour les opérations réseau
class NetworkError extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onGoOffline;

  const NetworkError({
    Key? key,
    this.onRetry,
    this.onGoOffline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 64,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Problème de connexion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vérifiez votre connexion internet et réessayez',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onRetry != null) ...[
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[500],
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (onGoOffline != null)
                  OutlinedButton.icon(
                    onPressed: onGoOffline,
                    icon: const Icon(Icons.offline_bolt, size: 18),
                    label: const Text('Mode hors ligne'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange[600],
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
