// lib/screens/meteo_screen.dart
// Écran météo refondu - Données réelles depuis le backend + Style AgriFarm

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/alert_meteo.dart';
import '../models/meteo.dart';
import '../utils/weather_helper.dart';

class MeteoScreen extends StatefulWidget {
  const MeteoScreen({Key? key}) : super(key: key);

  @override
  State<MeteoScreen> createState() => _MeteoScreenState();
}

class _MeteoScreenState extends State<MeteoScreen> {
  final TextEditingController _cityController = TextEditingController();
  bool _showCitySelector = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeatherData();
    });
  }

  void _loadWeatherData() {
    Provider.of<WeatherProvider>(context, listen: false).loadDefaultWeather();
  }

  void _onCityChanged() {
    if (_cityController.text.trim().isNotEmpty) {
      Provider.of<WeatherProvider>(context, listen: false)
          .changeCity(_cityController.text.trim());
      setState(() {
        _showCitySelector = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, _) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(weatherProvider),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Alertes Météo (réelles)
                      _buildAlertesSection(weatherProvider),
                      const SizedBox(height: 24),
                      
                      // Météo Actuelle
                      _buildCurrentWeatherSection(weatherProvider),
                      const SizedBox(height: 24),
                      
                      // Prévisions (réelles)
                      _buildForecastSection(weatherProvider),
                      const SizedBox(height: 24),
                      
                      // Historique (réel)
                      _buildHistorySection(weatherProvider),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadWeatherData,
        backgroundColor: const Color(0xFF21A84D),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildSliverAppBar(WeatherProvider weatherProvider) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF21A84D),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Météo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF21A84D),
                const Color(0xFF1B5E20),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        weatherProvider.currentCity,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (weatherProvider.currentWeather != null)
                        Text(
                          weatherProvider.weatherDescription,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
                if (weatherProvider.currentWeather != null)
                  Text(
                    weatherProvider.temperatureFormatted,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            setState(() {
              _showCitySelector = !_showCitySelector;
            });
          },
        ),
      ],
    );
  }

  // ===== SECTION ALERTES (DONNÉES RÉELLES) =====
  Widget _buildAlertesSection(WeatherProvider weatherProvider) {
    final alerts = weatherProvider.alerts;

    if (weatherProvider.isLoading && alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filtrer uniquement les alertes actives
    final activeAlerts = alerts.where((a) => a.isActive).toList();

    if (activeAlerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Alertes Météo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
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
                '${activeAlerts.length}',
                style: TextStyle(
                  color: Colors.orange[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...activeAlerts.map((alerte) => _buildAlertCard(alerte)),
      ],
    );
  }

  Widget _buildAlertCard(AlertMeteo alerte) {
    final bgColor = _getAlertBackgroundColor(alerte.niveau);
    final borderColor = _getAlertBorderColor(alerte.niveau);

    return Container(
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
            // Bandeau latéral
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          alerte.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alerte.typeDisplay,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              _buildBadge(alerte.niveau),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      alerte.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          alerte.duree,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        if (alerte.ville != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            alerte.ville!,
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

  // ===== SECTION MÉTÉO ACTUELLE =====
  Widget _buildCurrentWeatherSection(WeatherProvider weatherProvider) {
    if (weatherProvider.isLoading && weatherProvider.currentWeather == null) {
      return _buildLoadingCard('Chargement des données météo...');
    }

    if (weatherProvider.error != null && weatherProvider.currentWeather == null) {
      return _buildErrorCard(weatherProvider.error!);
    }

    if (weatherProvider.currentWeather == null) {
      return _buildEmptyCard('Aucune donnée météo disponible');
    }

    final weather = weatherProvider.currentWeather!;
    
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21A84D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.wb_sunny, color: Color(0xFF21A84D), size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Conditions Actuelles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weatherProvider.temperatureFormatted,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      Text(
                        weatherProvider.weatherDescription,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (weather['feels_like'] != null)
                        Text(
                          'Ressenti ${(weather['feels_like'] as num).toStringAsFixed(1)}°C',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF21A84D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getWeatherIcon(weather['description'] ?? ''),
                    size: 64,
                    color: const Color(0xFF21A84D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildWeatherDetail(Icons.water_drop, 'Humidité', weatherProvider.humidityFormatted)),
                Expanded(child: _buildWeatherDetail(Icons.air, 'Vent', '${weather['wind_speed'] ?? 0} km/h')),
                Expanded(child: _buildWeatherDetail(Icons.thermostat, 'Pression', '${weather['pressure'] ?? 0} hPa')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildWeatherDetail(Icons.visibility, 'Visibilité', '${(weather['visibility'] ?? 0) ~/ 1000} km')),
                Expanded(child: _buildWeatherDetail(Icons.cloud, 'Couverture', '${weather['clouds'] ?? 0}%')),
                Expanded(child: _buildWeatherDetail(Icons.water_drop, 'Précipitations', weather['rain_1h'] != null ? '${weather['rain_1h']} mm/h' : '0 mm/h')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== SECTION PRÉVISIONS (DONNÉES RÉELLES) =====
  Widget _buildForecastSection(WeatherProvider weatherProvider) {
    if (weatherProvider.isLoading && weatherProvider.weatherForecast == null) {
      return _buildLoadingCard('Chargement des prévisions...');
    }

    final forecast = weatherProvider.weatherForecast;
    if (forecast == null || forecast.daily.isEmpty) {
      return _buildEmptyCard('Prévisions non disponibles');
    }

    final nextDays = forecast.getNextDays(5);
    
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_today, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Prévisions 5 Jours',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const Spacer(),
                if (forecast.city != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 12, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          forecast.city!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: nextDays.length,
                itemBuilder: (context, index) {
                  final day = nextDays[index];
                  final isToday = index == 0;
                  return _buildRealForecastDay(day, isToday);
                },
              ),
            ),
            const SizedBox(height: 20),
            // Résumé des prévisions
            _buildForecastSummary(forecast),
          ],
        ),
      ),
    );
  }

  Widget _buildRealForecastDay(dynamic day, bool isToday) {
    final dayName = _getDayName(day.date);
    final tempMax = WeatherHelper.formatTemperature(day.tempMax);
    final tempMin = WeatherHelper.formatTemperature(day.tempMin);
    final precipProb = day.precipProb ?? 0;
    final iconCode = day.icon;

    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        gradient: isToday
            ? LinearGradient(
                colors: [const Color(0xFF21A84D), const Color(0xFF1B5E20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isToday ? null : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? const Color(0xFF21A84D) : Colors.grey[200]!,
          width: isToday ? 2 : 1,
        ),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: const Color(0xFF21A84D).withOpacity(0.3),
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
          _buildWeatherIcon(iconCode, isToday),
          const SizedBox(height: 8),
          Text(
            tempMax,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isToday ? Colors.white : Colors.grey[800],
            ),
          ),
          Text(
            tempMin,
            style: TextStyle(
              fontSize: 14,
              color: isToday ? Colors.white70 : Colors.grey[500],
            ),
          ),
          if (precipProb > 0) ...[
            const SizedBox(height: 8),
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
        ],
      ),
    );
  }

  Widget _buildForecastSummary(dynamic forecast) {
    final avgMax = forecast.getAverageMaxTemp();
    final avgMin = forecast.getAverageMinTemp();
    final rainyDays = forecast.getRainyDaysCount();

    return Container(
      padding: const EdgeInsets.all(16),
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

  // ===== SECTION HISTORIQUE (DONNÉES RÉELLES) =====
  Widget _buildHistorySection(WeatherProvider weatherProvider) {
    final history = weatherProvider.meteoHistory;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.history, color: Colors.purple, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Historique Météo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const Spacer(),
                if (history.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${history.length} jours',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Si historique réel disponible
            if (history.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length.clamp(0, 7),
                itemBuilder: (context, index) {
                  return _buildRealHistoryItem(history[index]);
                },
              )
            // État vide si pas d'historique
            else if (!weatherProvider.isLoading)
              _buildEmptyHistory()
            // Loading
            else
              _buildLoadingHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildRealHistoryItem(Meteo meteo) {
    final dateFormatted = _formatDate(meteo.date);
    final dayName = _getRelativeDayName(meteo.date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Date
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  dateFormatted,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Icône
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF21A84D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              meteo.weatherIcon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 12),
          // Température
          Text(
            meteo.tempCelsius,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF21A84D),
            ),
          ),
          const SizedBox(width: 12),
          // Description
          Expanded(
            flex: 3,
            child: Text(
              meteo.description ?? 'N/A',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun historique disponible',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les données historiques apparaîtront ici',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Chargement de l\'historique...',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== WIDGETS UTILITAIRES =====
  
  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
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
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard(String message) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(color: Color(0xFF21A84D)),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Erreur météo',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Provider.of<WeatherProvider>(context, listen: false).clearError();
                    _loadWeatherData();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Réessayer'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // ===== UTILITAIRES =====
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getRelativeDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = today.difference(target).inDays;

    if (difference == 0) return 'Aujourd\'hui';
    if (difference == 1) return 'Hier';
    if (difference == 2) return 'Avant-hier';
    if (difference < 7) return 'Il y a $difference jours';
    return _formatDate(date);
  }

  String _getDayName(DateTime date) {
    if (WeatherHelper.isToday(date)) return 'Aujourd\'hui';
    if (WeatherHelper.isTomorrow(date)) return 'Demain';

    final frenchDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return frenchDays[date.weekday - 1];
  }

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('rain') || desc.contains('pluie')) return Icons.water_drop;
    if (desc.contains('cloud') || desc.contains('nuage')) return Icons.cloud;
    if (desc.contains('clear') || desc.contains('dégagé')) return Icons.wb_sunny;
    if (desc.contains('snow') || desc.contains('neige')) return Icons.ac_unit;
    if (desc.contains('storm') || desc.contains('orage')) return Icons.flash_on;
    return Icons.wb_sunny;
  }

  Widget _buildWeatherIcon(String? iconCode, bool isToday) {
    // Mapper les codes OpenWeatherMap vers icônes
    if (iconCode == null) {
      return Icon(
        Icons.wb_sunny,
        size: 40,
        color: isToday ? Colors.white : null,
      );
    }

    // Codes OpenWeatherMap
    final desc = iconCode.toLowerCase();
    IconData icon;
    if (desc.contains('01')) icon = Icons.wb_sunny; // Clear
    else if (desc.contains('02')) icon = Icons.wb_cloudy; // Few clouds
    else if (desc.contains('03') || desc.contains('04')) icon = Icons.cloud; // Clouds
    else if (desc.contains('09')) icon = Icons.umbrella; // Shower rain
    else if (desc.contains('10')) icon = Icons.water_drop; // Rain
    else if (desc.contains('11')) icon = Icons.flash_on; // Thunderstorm
    else if (desc.contains('13')) icon = Icons.ac_unit; // Snow
    else if (desc.contains('50')) icon = Icons.foggy; // Mist
    else icon = Icons.wb_sunny;

    return Icon(
      icon,
      size: 40,
      color: isToday ? Colors.white : null,
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}

