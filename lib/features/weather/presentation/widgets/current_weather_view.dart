import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_card.dart';

class CurrentWeatherView extends StatelessWidget {
  const CurrentWeatherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.wb_cloudy_rounded, // Dummy icon
          size: 120,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        Text(
          '24°',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 80,
              ),
        ),
        Text(
          'Partly Cloudy',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'H: 28°   L: 18°',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ],
    );
  }
}
