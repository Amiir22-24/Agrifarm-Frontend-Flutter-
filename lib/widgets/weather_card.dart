
// lib/widgets/weather_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/auth_provider.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({Key? key}) : super(key: key);

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeatherWithUserCity();
    });
  }

  void _loadWeatherWithUserCity() {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 🔧 CORRECTION : Récupérer la ville de l'utilisateur depuis son profil
    // La propriété est dans profile.defaultWeatherCity, pas directement sur user
    final userWeatherCity = authProvider.user?.profile?.defaultWeatherCity;
    
    if (userWeatherCity != null && userWeatherCity.isNotEmpty) {
      // Utiliser la ville de l'utilisateur
      weatherProvider.loadCurrentWeather(userWeatherCity: userWeatherCity);
    } else {
      // Utiliser la ville par défaut du provider
      weatherProvider.loadCurrentWeather();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final weather = provider.currentWeather;
        if (weather == null) return const SizedBox.shrink();

        return Card(
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather['city'] ?? provider.currentCity,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          weather['description'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.wb_sunny,
                      color: Colors.white,
                      size: 48,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfo(Icons.thermostat, 
                      '${weather['temperature'] ?? '--'}°C'),
                    _buildInfo(Icons.water_drop, 
                      '${weather['humidity'] ?? '--'}%'),
                    _buildInfo(Icons.air, 
                      '${weather['wind_speed'] ?? '--'} km/h'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
