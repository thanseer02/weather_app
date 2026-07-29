import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/weather_entity.dart';
import 'package:intl/intl.dart';

class HourlyForecastView extends StatelessWidget {
  final ForecastEntity forecast;

  const HourlyForecastView({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    if (forecast.hourly.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: SectionHeader(title: 'Hourly Forecast'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: forecast.hourly.length,
            itemBuilder: (context, index) {
              final item = forecast.hourly[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GlassCard(
                  width: 80,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        DateFormat('h a').format(item.date),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Image.network(
                        'https://openweathermap.org/img/wn/${item.iconCode}.png',
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud, color: Colors.white),
                      ),
                      Text(
                        '${item.temperature.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
