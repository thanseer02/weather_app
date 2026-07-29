import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_card.dart';

class WeatherDetailsGrid extends StatelessWidget {
  const WeatherDetailsGrid({super.key});

  @override
  Widget build(BuildContext context) {
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
          _buildDetailCard(context, 'Feels Like', '26°', Icons.thermostat),
          _buildDetailCard(context, 'Humidity', '65%', Icons.water_drop_outlined),
          _buildDetailCard(context, 'Pressure', '1012 hPa', Icons.speed),
          _buildDetailCard(context, 'Wind', '12 km/h', Icons.air),
          _buildDetailCard(context, 'UV Index', '5 (Moderate)', Icons.wb_sunny_outlined),
          _buildDetailCard(context, 'Visibility', '10 km', Icons.visibility_outlined),
          _buildDetailCard(context, 'Air Quality', 'Good', Icons.masks_outlined),
          _buildDetailCard(context, 'Sunrise/Sunset', '06:12 / 19:45', Icons.wb_twilight),
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
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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
