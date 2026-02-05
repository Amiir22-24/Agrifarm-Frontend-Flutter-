// lib/widgets/rapports/loading_spinner.dart
import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final bool isOverlay;

  const LoadingSpinner({
    Key? key,
    this.message,
    this.size,
    this.color,
    this.isOverlay = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spinner = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size ?? 40,
          height: size ?? 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isOverlay) {
      return Container(
        color: Colors.black54,
        child: Center(child: spinner),
      );
    }

    return Center(child: spinner);
  }
}

// Widget de loading pour les listes vides
class EmptyListLoading extends StatelessWidget {
  final String message;

  const EmptyListLoading({
    Key? key,
    this.message = 'Chargement des données...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de loading pour la génération de rapport
class GenerationLoading extends StatelessWidget {
  final String? message;

  const GenerationLoading({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Génération du rapport IA en cours...',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Cela peut prendre quelques instants',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
