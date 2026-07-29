import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/weather_entity.dart';

class CurrentWeatherView extends StatelessWidget {
  final WeatherEntity weather;

  const CurrentWeatherView({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CachedNetworkImage(
          imageUrl: 'https://openweathermap.org/img/wn/${weather.iconCode}@4x.png',
          width: 150,
          height: 150,
          errorWidget: (context, url, error) => const SizedBox(
            width: 150,
            height: 150,
            child: Icon(Icons.cloud, size: 100, color: Colors.white),
          ),
        ),
        Text(
          '${weather.temperature.round()}°',
          style: AppTypography.getTextTheme(context).displayLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          weather.description.toUpperCase(),
          style: AppTypography.getTextTheme(context).titleLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'H:${weather.tempMax.round()}°  L:${weather.tempMin.round()}°',
          style: AppTypography.getTextTheme(context).bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
