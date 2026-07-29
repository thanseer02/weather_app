import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/weather_entity.dart';
import 'package:intl/intl.dart';

class WeatherDetailsGrid extends StatelessWidget {
  final WeatherEntity weather;

  const WeatherDetailsGrid({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    // OpenWeatherMap standard AQI endpoint is separate, we'll mock AQI logic for now as planned
    const aqi = 'Good';

    final sunriseStr = DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(weather.sunrise * 1000));
    final sunsetStr = DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(weather.sunset * 1000));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: [
          _buildDetailCard(context, 'Feels Like', '${weather.feelsLike.round()}°', Icons.thermostat),
          _buildDetailCard(context, 'Humidity', '${weather.humidity}%', Icons.water_drop_outlined),
          _buildDetailCard(context, 'Pressure', '${weather.pressure} hPa', Icons.speed),
          _buildDetailCard(context, 'Wind', '${weather.windSpeed} m/s', Icons.air),
          _buildDetailCard(context, 'Visibility', '${(weather.visibility / 1000).toStringAsFixed(1)} km', Icons.visibility_outlined),
          _buildDetailCard(context, 'Air Quality', aqi, Icons.masks_outlined),
          _buildDetailCard(context, 'Sunrise/Sunset', '$sunriseStr / $sunsetStr', Icons.wb_twilight),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, String title, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
