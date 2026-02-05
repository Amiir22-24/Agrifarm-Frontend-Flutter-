// lib/widgets/weather/weather_icon_widget.dart
// Widget d'affichage des icônes météo (OpenWeatherMap)

import 'package:flutter/material.dart';

class WeatherIconWidget extends StatelessWidget {
  final String? iconCode;
  final double size;
  final Color? color;
  final bool useNetworkImage;
  final String? fallbackDescription;

  const WeatherIconWidget({
    super.key,
    this.iconCode,
    this.size = 48,
    this.color,
    this.useNetworkImage = true,
    this.fallbackDescription,
  });

  @override
  Widget build(BuildContext context) {
    // Si pas d'icône OpenWeatherMap ou si désactivé, utiliser l'icône Flutter
    if (!useNetworkImage || iconCode == null || iconCode!.isEmpty) {
      return Icon(
        _getFallbackIcon(),
        size: size,
        color: color ?? _getDefaultColor(),
      );
    }

    // Construire l'URL de l'icône OpenWeatherMap
    final iconUrl = _buildIconUrl();

    return Image.network(
      iconUrl,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // En cas d'erreur, utiliser l'icône de fallback
        return Icon(
          _getFallbackIcon(),
          size: size,
          color: color ?? _getDefaultColor(),
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        // Afficher un progress indicator pendant le chargement
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? _getDefaultColor(),
            ),
          ),
        );
      },
    );
  }

  /// Construire l'URL de l'icône OpenWeatherMap
  String _buildIconUrl() {
    final baseUrl = 'https://openweathermap.org/img/wn';
    
    // OpenWeatherMap utilise des suffixes @2x, @4x pour la taille
    // @2x = 100x100 pixels environ
    final suffix = size >= 100 ? '@4x' : '@2x';
    
    return '$baseUrl/$iconCode$suffix.png';
  }

  /// Obtenir l'icône Flutter de fallback basée sur le code ou la description
  IconData _getFallbackIcon() {
    if (iconCode == null) return Icons.wb_sunny;

    // Codes icônes OpenWeatherMap:
    // 01x: Ciel dégagé
    // 02x: Quelques nuages
    // 03x: Nuages épars
    // 04x: Ciel couvert
    // 09x: Averses
    // 10x: Pluie
    // 11x: Orage
    // 13x: Neige
    // 50x: Brume/Bruillard

    final code = iconCode!.substring(0, 2);

    switch (code) {
      case '01': // Ciel dégagé
        return Icons.wb_sunny;
      case '02': // Quelques nuages
        return Icons.cloud;
      case '03': // Nuages épars
        return Icons.cloud;
      case '04': // Ciel couvert
        return Icons.cloud;
      case '09': // Averses
        return Icons.water_drop;
      case '10': // Pluie
        return Icons.water_drop;
      case '11': // Orage
        return Icons.flash_on;
      case '13': // Neige
        return Icons.ac_unit;
      case '50': // Brume
        return Icons.cloud;
      default:
        return Icons.wb_sunny;
    }
  }

  /// Obtenir la couleur par défaut
  Color _getDefaultColor() {
    if (color != null) return color!;

    // Couleur selon l'heure (jour/nuit)
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 18) {
      return Colors.orange;
    } else {
      return Colors.indigo;
    }
  }
}

/// Widget pour afficher l'emoji unicode de la météo
class WeatherEmojiWidget extends StatelessWidget {
  final String? description;
  final double size;

  const WeatherEmojiWidget({
    super.key,
    this.description,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      _getEmoji(),
      style: TextStyle(fontSize: size),
    );
  }

  String _getEmoji() {
    if (description == null) return '☀️';

    final desc = description!.toLowerCase();

    if (desc.contains('rain') || desc.contains('pluie')) return '🌧️';
    if (desc.contains('drizzle') || desc.contains('bruine')) return '🌦️';
    if (desc.contains('cloud') || desc.contains('nuage')) return '☁️';
    if (desc.contains('clear') || desc.contains('dégagé') || desc.contains('ensoleillé')) return '☀️';
    if (desc.contains('snow') || desc.contains('neige')) return '❄️';
    if (desc.contains('storm') || desc.contains('orage') || desc.contains('thunder')) return '⛈️';
    if (desc.contains('fog') || desc.contains('brouillard') || desc.contains('brume')) return '🌫️';
    if (desc.contains('wind') || desc.contains('vent')) return '💨';
    if (desc.contains('hail') || desc.contains('grêle')) return '🌨️';

    return '🌤️';
  }
}

/// Widget combiné qui affiche l'icône et l'emoji côte à côte
class WeatherIconWithEmoji extends StatelessWidget {
  final String? iconCode;
  final String? description;
  final double iconSize;
  final double emojiSize;
  final Color? iconColor;

  const WeatherIconWithEmoji({
    super.key,
    this.iconCode,
    this.description,
    this.iconSize = 48,
    this.emojiSize = 24,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WeatherIconWidget(
          iconCode: iconCode,
          size: iconSize,
          color: iconColor,
        ),
        const SizedBox(width: 4),
        WeatherEmojiWidget(
          description: description ?? description,
          size: emojiSize,
        ),
      ],
    );
  }
}

