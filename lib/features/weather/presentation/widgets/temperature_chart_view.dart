import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/weather_entity.dart';
import 'package:intl/intl.dart';

class TemperatureChartView extends StatefulWidget {
  final ForecastEntity forecast;

  const TemperatureChartView({super.key, required this.forecast});

  @override
  State<TemperatureChartView> createState() => _TemperatureChartViewState();
}

class _TemperatureChartViewState extends State<TemperatureChartView> {
  @override
  Widget build(BuildContext context) {
    if (widget.forecast.hourly.isEmpty) return const SizedBox.shrink();

    final hourly = widget.forecast.hourly.take(8).toList();

    double minTemp = hourly.map((e) => e.temperature).reduce((a, b) => a < b ? a : b);
    double maxTemp = hourly.map((e) => e.temperature).reduce((a, b) => a > b ? a : b);
    if (minTemp == maxTemp) {
      minTemp -= 2;
      maxTemp += 2;
    }

    final spots = List.generate(
      hourly.length,
      (index) => FlSpot(index.toDouble(), hourly[index].temperature),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Temperature Trend'),
          const SizedBox(height: 16),
          GlassCard(
            height: 220,
            padding: const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
            child: LineChart(
              LineChartData(
                minY: minTemp - 2,
                maxY: maxTemp + 2,
                minX: 0,
                maxX: hourly.length.toDouble() - 1,
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (LineBarSpot touchedSpot) => Colors.black45,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        return LineTooltipItem(
                          '${touchedSpot.y.round()}°\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: DateFormat('h a').format(hourly[touchedSpot.x.toInt()].date),
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: Colors.white10,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 != 0 || value < 0 || value >= hourly.length) return const SizedBox.shrink();
                        final item = hourly[value.toInt()];
                        final isFirst = value == 0;
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            isFirst ? 'Now' : DateFormat('ha').format(item.date).toLowerCase(),
                            style: TextStyle(
                              color: isFirst ? Colors.white : Colors.white54,
                              fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}°',
                          style: const TextStyle(color: Colors.white54, fontSize: 10),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: index == 0 ? 5 : 3,
                          color: index == 0 ? Colors.amber : Colors.white,
                          strokeWidth: 2,
                          strokeColor: index == 0 ? Colors.white : Colors.blue.shade900,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 1000), // animated values
              curve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }
}
