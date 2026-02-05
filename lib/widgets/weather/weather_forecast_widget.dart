// lib/widgets/weather/weather_forecast_widget.dart
// Widget d'affichage des prévisions météo sur plusieurs jours

import 'package:flutter/material.dart';
import '../../models/weather_forecast.dart';
import 'weather_icon_widget.dart';
import '../../utils/weather_helper.dart';

class WeatherForecastWidget extends StatelessWidget {
  final WeatherForecast forecast;
  final int daysCount;
  final bool showHeader;
  final bool showDetails;
  final VoidCallback? onDayTap;

  const WeatherForecastWidget({
    super.key,
    required this.forecast,
    this.daysCount = 5,
    this.showHeader = true,
    this.showDetails = true,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    if (forecast.daily.isEmpty) {
      return _buildEmptyState();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              _buildHeader(),
              const SizedBox(height: 16),
            ],
            _buildHorizontalList(),
            if (showDetails) ...[
              const SizedBox(height: 20),
              _buildSummary(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Prévisions Météo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        if (forecast.city != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 12, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  forecast.city!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHorizontalList() {
    final days = forecast.getNextDays(daysCount);

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          return _buildForecastDay(days[index], index == 0);
        },
      ),
    );
  }

  Widget _buildForecastDay(DailyForecast day, bool isToday) {
    final dayName = _getDayName(day.date);
    final tempMax = WeatherHelper.formatTemperature(day.tempMax);
    final tempMin = WeatherHelper.formatTemperature(day.tempMin);
    final precipProb = day.precipProb ?? 0;

    return GestureDetector(
      onTap: onDayTap != null ? () => onDayTap!() : null,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: isToday
              ? LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isToday ? null : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday ? Colors.green : Colors.grey[200]!,
            width: isToday ? 2 : 1,
          ),
          boxShadow: isToday
              ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Jour
            Text(
              isToday ? 'Aujourd\'hui' : dayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),

            // Icône météo
            WeatherIconWidget(
              iconCode: day.icon,
              size: 40,
              color: isToday ? Colors.white : null,
            ),
            const SizedBox(height: 8),

            // Température max
            Text(
              tempMax,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : Colors.grey[800],
              ),
            ),

            // Température min
            Text(
              tempMin,
              style: TextStyle(
                fontSize: 14,
                color: isToday ? Colors.white70 : Colors.grey[500],
              ),
            ),

            const SizedBox(height: 8),

            // Probabilité de pluie
            if (precipProb > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.water_drop,
                    size: 12,
                    color: isToday ? Colors.white70 : Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$precipProb%',
                    style: TextStyle(
                      fontSize: 11,
                      color: isToday ? Colors.white70 : Colors.blue,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final avgMax = forecast.getAverageMaxTemp();
    final avgMin = forecast.getAverageMinTemp();
    final rainyDays = forecast.getRainyDaysCount();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            icon: Icons.thermostat,
            label: 'Moy. Max',
            value: WeatherHelper.formatTemperature(avgMax),
            color: Colors.orange,
          ),
          _buildSummaryItem(
            icon: Icons.thermostat,
            label: 'Moy. Min',
            value: WeatherHelper.formatTemperature(avgMin),
            color: Colors.blue,
          ),
          _buildSummaryItem(
            icon: Icons.water_drop,
            label: 'Jours pluvieux',
            value: rainyDays.toString(),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
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
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.calendar_today,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Prévisions non disponibles',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Veuillez réessayer plus tard',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(DateTime date) {
    if (WeatherHelper.isToday(date)) return 'Aujourd\'hui';
    if (WeatherHelper.isTomorrow(date)) return 'Demain';

    final frenchDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return frenchDays[date.weekday - 1];
  }
}

/// Widget de prévisions quotidiennes détaillé
class DailyForecastCard extends StatelessWidget {
  final DailyForecast forecast;
  final bool isExpanded;

  const DailyForecastCard({
    super.key,
    required this.forecast,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        title: _buildTitle(),
        children: isExpanded ? [_buildExpandedContent()] : [],
      ),
    );
  }

  Widget _buildTitle() {
    final dayName = _getDayName();
    final dateStr = WeatherHelper.formatDate(forecast.date, pattern: 'dd MMM');

    return Row(
      children: [
        WeatherIconWidget(
          iconCode: forecast.icon,
          size: 40,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              WeatherHelper.formatTemperature(forecast.tempMax),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              WeatherHelper.formatTemperature(forecast.tempMin),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    final details = [
      ('Matin', WeatherHelper.formatTemperature(forecast.tempMorn)),
      ('Après-midi', WeatherHelper.formatTemperature(forecast.tempDay)),
      ('Soir', WeatherHelper.formatTemperature(forecast.tempEve)),
      ('Nuit', WeatherHelper.formatTemperature(forecast.tempNight)),
      ('Humidité', '${forecast.humidity ?? '--'}%'),
      ('Précipitation', '${forecast.precipProb ?? 0}%'),
      ('Vent', '${forecast.windSpeed?.toStringAsFixed(1) ?? '--'} km/h'),
      ('Pression', '${forecast.pressure ?? '--'} hPa'),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.2,
        ),
        itemCount: details.length,
        itemBuilder: (context, index) {
          final (label, value) = details[index];
          return _buildDetailItem(label, value);
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getDayName() {
    if (WeatherHelper.isToday(forecast.date)) return 'Aujourd\'hui';
    if (WeatherHelper.isTomorrow(forecast.date)) return 'Demain';

    final frenchDays = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return frenchDays[forecast.date.weekday - 1];
  }
}

