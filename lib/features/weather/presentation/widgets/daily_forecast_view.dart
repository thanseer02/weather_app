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
                
                return _DailyForecastItem(item: item, isToday: isToday);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyForecastItem extends StatefulWidget {
  final WeatherEntity item;
  final bool isToday;

  const _DailyForecastItem({required this.item, required this.isToday});

  @override
  State<_DailyForecastItem> createState() => _DailyForecastItemState();
}

class _DailyForecastItemState extends State<_DailyForecastItem> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    widget.isToday ? 'Today' : DateFormat('EEEE').format(item.date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (item.pop > 0)
                      Text(
                        '${(item.pop * 100).round()}% ',
                        style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    Image.network(
                      'https://openweathermap.org/img/wn/${item.iconCode}.png',
                      width: 30,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud, color: Colors.white),
                    ),
                  ],
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
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: _isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildDetailItem(Icons.water_drop, 'Rain', '${(item.pop * 100).round()}%'),
                            _buildDetailItem(Icons.air, 'Wind', '${item.windSpeed.round()}m/s'),
                            _buildDetailItem(Icons.wb_sunny, 'UV Index', 'Moderate'), // Mocked
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
