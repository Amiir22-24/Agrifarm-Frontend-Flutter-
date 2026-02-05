// lib/widgets/weather/weather_alert_widget.dart
// Widget d'affichage des alertes météorologiques

import 'package:flutter/material.dart';
import '../../models/alert_meteo.dart';

class WeatherAlertWidget extends StatelessWidget {
  final List<AlertMeteo> alerts;
  final bool showHeader;
  final bool allowDismiss;
  final Function(AlertMeteo)? onAlertTap;
  final Function(AlertMeteo)? onDismiss;

  const WeatherAlertWidget({
    super.key,
    required this.alerts,
    this.showHeader = true,
    this.allowDismiss = true,
    this.onAlertTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // Filtrer uniquement les alertes actives
    final activeAlerts = alerts.where((a) => a.isActive).toList();

    if (activeAlerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          _buildHeader(activeAlerts.length),
          const SizedBox(height: 12),
        ],
        ...activeAlerts.map((alert) => _buildAlertCard(alert, context)),
      ],
    );
  }

  Widget _buildHeader(int alertCount) {
    return Row(
      children: [
        const Icon(Icons.warning_amber, color: Colors.orange, size: 24),
        const SizedBox(width: 8),
        Text(
          'Alertes Météo',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$alertCount',
            style: TextStyle(
              color: Colors.orange[800],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(AlertMeteo alert, BuildContext context) {
    final bgColor = _getAlertBackgroundColor(alert.niveau);
    final borderColor = _getAlertBorderColor(alert.niveau);
    final iconColor = _getAlertIconColor(alert.niveau);

    return GestureDetector(
      onTap: onAlertTap != null ? () => onAlertTap!(alert) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bandeau de couleur latéral
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
              ),
              // Contenu de l'alerte
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre et niveau
                      Row(
                        children: [
                          Text(
                            alert.icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert.typeDisplay,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                _buildBadge(alert.niveau),
                              ],
                            ),
                          ),
                          if (allowDismiss && onDismiss != null)
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white70,
                                size: 20,
                              ),
                              onPressed: () => onDismiss!(alert),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Message
                      Text(
                        alert.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Pied d'alerte
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            alert.duree,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          if (alert.ville != null) ...[
                            const SizedBox(width: 16),
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              alert.ville!,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String niveau) {
    final color = _getAlertBorderColor(niveau);
    final text = switch (niveau) {
      'info' => 'Information',
      'warning' => 'Attention',
      'critical' => 'Critique',
      _ => 'Alerte',
    };

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getAlertBackgroundColor(String niveau) {
    return switch (niveau) {
      'info' => Colors.blue[400]!.withOpacity(0.9),
      'warning' => Colors.orange[400]!.withOpacity(0.9),
      'critical' => Colors.red[400]!.withOpacity(0.9),
      _ => Colors.grey[400]!.withOpacity(0.9),
    };
  }

  Color _getAlertBorderColor(String niveau) {
    return switch (niveau) {
      'info' => Colors.blue[600]!,
      'warning' => Colors.orange[600]!,
      'critical' => Colors.red[600]!,
      _ => Colors.grey[600]!,
    };
  }

  Color _getAlertIconColor(String niveau) {
    return switch (niveau) {
      'info' => Colors.blue[100]!,
      'warning' => Colors.orange[100]!,
      'critical' => Colors.red[100]!,
      _ => Colors.grey[200]!,
    };
  }
}

/// Widget compact pour une seule alerte
class WeatherAlertCard extends StatelessWidget {
  final AlertMeteo alert;
  final bool compact;

  const WeatherAlertCard({
    super.key,
    required this.alert,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactCard();
    }
    return _buildFullCard();
  }

  Widget _buildCompactCard() {
    final bgColor = _getAlertBackgroundColor(alert.niveau);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(alert.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            '${alert.typeDisplay}: ${alert.niveauDisplay}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullCard() {
    final bgColor = _getAlertBackgroundColor(alert.niveau);
    final borderColor = _getAlertBorderColor(alert.niveau);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(alert.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        alert.typeDisplay,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      _buildCompactBadge(alert.niveau),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alert.duree,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactBadge(String niveau) {
    final color = _getAlertBorderColor(niveau);
    final text = switch (niveau) {
      'info' => 'Info',
      'warning' => '⚠️',
      'critical' => '🔴',
      _ => '',
    };

    return Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  Color _getAlertBackgroundColor(String niveau) {
    return switch (niveau) {
      'info' => Colors.blue[100]!,
      'warning' => Colors.orange[100]!,
      'critical' => Colors.red[100]!,
      _ => Colors.grey[200]!,
    };
  }

  Color _getAlertBorderColor(String niveau) {
    return switch (niveau) {
      'info' => Colors.blue,
      'warning' => Colors.orange,
      'critical' => Colors.red,
      _ => Colors.grey,
    };
  }
}

/// Liste des alertes avec animation de défilement
class WeatherAlertsList extends StatelessWidget {
  final List<AlertMeteo> alerts;
  final Function(AlertMeteo)? onTap;

  const WeatherAlertsList({
    super.key,
    required this.alerts,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.check_circle, size: 48, color: Colors.green),
              SizedBox(height: 12),
              Text(
                'Aucune alerte active',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        return WeatherAlertCard(
          alert: alerts[index],
          compact: false,
        );
      },
    );
  }
}

