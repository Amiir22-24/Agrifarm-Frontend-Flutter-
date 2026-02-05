// lib/widgets/weather/weather_details_widget.dart
// Widget d'affichage détaillé des conditions météo

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'weather_icon_widget.dart';
import '../../utils/weather_helper.dart';

class WeatherDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> weather;
  final bool showHeader;
  final bool showAgriculturalAdvice;
  final VoidCallback? onRetry;

  const WeatherDetailsWidget({
    super.key,
    required this.weather,
    this.showHeader = true,
    this.showAgriculturalAdvice = true,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              _buildHeader(context),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ],
            _buildMainConditions(),
            const SizedBox(height: 24),
            _buildDetailsGrid(),
            if (showAgriculturalAdvice) ...[
              const SizedBox(height: 20),
              _buildAgriculturalAdvice(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final city = weather['city'] ?? weather['ville'] ?? 'Ville inconnue';
    final timestamp = weather['timestamp'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                Text(
                  city,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (timestamp != null)
              Text(
                _formatTimestamp(timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        if (onRetry != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRetry,
            tooltip: 'Actualiser',
          ),
      ],
    );
  }

  Widget _buildMainConditions() {
    final temp = weather['temperature'];
    final feelsLike = weather['feels_like'];
    final description = weather['description'] ?? 'Aucune description';
    final iconCode = weather['icon'];

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                WeatherHelper.formatTemperature(temp),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description.capitalize(),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ressenti: ${WeatherHelper.formatTemperature(feelsLike)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        WeatherIconWidget(
          iconCode: iconCode,
          size: 80,
        ),
      ],
    );
  }

  Widget _buildDetailsGrid() {
    final details = [
      ('Humidité', weather['humidity'], '%', Icons.water_drop, Colors.blue),
      ('Vent', weather['wind_speed'], ' km/h', Icons.air, Colors.blueGrey),
      ('Pression', weather['pressure'], ' hPa', Icons.compress, Colors.purple),
      ('Visibilité', weather['visibility'], ' km', Icons.visibility, Colors.orange),
      ('Nuages', weather['clouds'], '%', Icons.cloud, Colors.grey),
      ('Précipitations', weather['rain_1h'] ?? weather['rain'], ' mm/h', Icons.water_drop, Colors.teal),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final (label, value, unit, icon, color) = details[index];
        return _buildDetailCard(
          icon: icon,
          label: label,
          value: '${value ?? '--'}$unit',
          color: color,
        );
      },
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAgriculturalAdvice() {
    final advice = WeatherHelper.getAgriculturalAdvice(weather);
    final conditionColor = WeatherHelper.getAgriculturalConditionColor(weather);

    return Container(
      decoration: BoxDecoration(
        color: conditionColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: conditionColor.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            conditionColor == Colors.green ? Icons.check_circle : Icons.info,
            color: conditionColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseil Agricole',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: conditionColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  advice,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp is String) {
        final date = DateTime.parse(timestamp);
        return 'Mis à jour ${_formatRelativeTime(date)}';
      } else if (timestamp is int) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        return 'Mis à jour ${_formatRelativeTime(date)}';
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'à l\'instant';
    if (difference.inMinutes < 60) return 'il y a ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'il y a ${difference.inHours}h';
    if (difference.inDays < 7) return 'il y a ${difference.inDays} jours';
    
    final formatter = DateFormat('dd MMM', 'fr_FR');
    return 'le ${formatter.format(date)}';
  }
}

/// Extension pour capitaliser les chaînes
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

/// Widget compact pour les détails météo (2x3 grid)
class WeatherDetailsCompact extends StatelessWidget {
  final Map<String, dynamic> weather;

  const WeatherDetailsCompact({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final details = [
      ('humidity', 'Humidité', '%', Icons.water_drop, Colors.blue),
      ('wind_speed', 'Vent', ' km/h', Icons.air, Colors.blueGrey),
      ('pressure', 'Pression', ' hPa', Icons.compress, Colors.purple),
      ('visibility', 'Visibilité', ' km', Icons.visibility, Colors.orange),
      ('clouds', 'Nuages', '%', Icons.cloud, Colors.grey),
      ('rain_1h', 'Précip.', ' mm/h', Icons.water_drop, Colors.teal),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.3,
      ),
      itemCount: details.length,
      itemBuilder: (context, index) {
        final (key, label, unit, icon, color) = details[index];
        final value = weather[key];
        
        return _buildCompactItem(
          icon: icon,
          label: label,
          value: '${value ?? '--'}$unit',
          color: color,
        );
      },
    );
  }

  Widget _buildCompactItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

