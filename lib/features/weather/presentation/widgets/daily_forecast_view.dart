import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/weather_entity.dart';
import 'package:intl/intl.dart';

class DailyForecastView extends StatelessWidget {
  final ForecastEntity forecast;

  const DailyForecastView({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    if (forecast.daily.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: '7-Day Forecast'),
          const SizedBox(height: 16),
          GlassCard(
            padding: EdgeInsets.zero,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: forecast.daily.length,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.white24,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final item = forecast.daily[index];
                final isToday = index == 0;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          isToday ? 'Today' : DateFormat('EEEE').format(item.date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Image.network(
                        'https://openweathermap.org/img/wn/${item.iconCode}.png',
                        width: 30,
                        height: 30,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud, color: Colors.white),
                      ),
                      Row(
                        children: [
                          Text(
                            '${item.tempMin.round()}°',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${item.tempMax.round()}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
