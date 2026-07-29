import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/weather_entity.dart';
import 'package:intl/intl.dart';

class HourlyForecastView extends StatefulWidget {
  final ForecastEntity forecast;

  const HourlyForecastView({super.key, required this.forecast});

  @override
  State<HourlyForecastView> createState() => _HourlyForecastViewState();
}

class _HourlyForecastViewState extends State<HourlyForecastView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant HourlyForecastView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.forecast != widget.forecast) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forecast.hourly.isEmpty) return const SizedBox.shrink();

    final hourly = widget.forecast.hourly;
    const double itemWidth = 70.0;
    const double graphHeight = 80.0;
    const double totalHeight = 240.0;

    double minTemp = hourly.map((e) => e.temperature).reduce((a, b) => a < b ? a : b);
    double maxTemp = hourly.map((e) => e.temperature).reduce((a, b) => a > b ? a : b);
    if (minTemp == maxTemp) {
      minTemp -= 2;
      maxTemp += 2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: SectionHeader(title: 'Hourly Forecast'),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - _animation.value), 0),
              child: Opacity(
                opacity: _animation.value,
                child: child,
              ),
            );
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: itemWidth * hourly.length,
              height: totalHeight,
              child: Stack(
                children: [
                  // Highlight for current hour (Glass Card overlay behind content)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IgnorePointer(
                      child: GlassCard(
                        width: itemWidth,
                        height: totalHeight,
                        padding: EdgeInsets.zero,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Temperature Graph Layer
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    height: graphHeight,
                    child: CustomPaint(
                      painter: TemperatureGraphPainter(
                        hourly: hourly,
                        minTemp: minTemp,
                        maxTemp: maxTemp,
                        itemWidth: itemWidth,
                        progress: _animation.value,
                      ),
                    ),
                  ),
                  // Foreground Content Layer
                  Row(
                    children: List.generate(hourly.length, (index) {
                      final item = hourly[index];
                      final isFirst = index == 0;
                      
                      return SizedBox(
                        width: itemWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Time
                              Text(
                                isFirst ? 'Now' : DateFormat('ha').format(item.date).toLowerCase(),
                                style: TextStyle(
                                  color: isFirst ? Colors.white : Colors.white70,
                                  fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              // Icon
                              Image.network(
                                'https://openweathermap.org/img/wn/${item.iconCode}.png',
                                width: 40,
                                height: 40,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.cloud, color: Colors.white),
                              ),
                              // Gap for the graph
                              const SizedBox(height: graphHeight),
                              // Rain Probability
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.water_drop, color: Colors.lightBlueAccent, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${(item.pop * 100).round()}%',
                                    style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Wind
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.air, color: Colors.white54, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${item.windSpeed.round()}m/s',
                                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TemperatureGraphPainter extends CustomPainter {
  final List<WeatherEntity> hourly;
  final double minTemp;
  final double maxTemp;
  final double itemWidth;
  final double progress;

  TemperatureGraphPainter({
    required this.hourly,
    required this.minTemp,
    required this.maxTemp,
    required this.itemWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (hourly.isEmpty) return;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [Colors.white.withValues(alpha: 0.4), Colors.white.withValues(alpha: 0.0)],
      );

    final path = Path();
    final fillPath = Path();

    final range = maxTemp - minTemp;
    if (range == 0) return;

    final List<Offset> points = [];

    for (int i = 0; i < hourly.length; i++) {
      final item = hourly[i];
      // Normalize Y and add padding
      final normalizedY = 1 - ((item.temperature - minTemp) / range);
      final y = 20 + (normalizedY * (size.height - 40));
      
      final x = (i * itemWidth) + (itemWidth / 2);
      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      path.moveTo(points.first.dx, points.first.dy);
      fillPath.moveTo(points.first.dx, size.height);
      fillPath.lineTo(points.first.dx, points.first.dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = i > 0 ? points[i - 1] : points[i];
        final p1 = points[i];
        final p2 = points[i + 1];
        final p3 = i != points.length - 2 ? points[i + 2] : p2;

        final controlPoint1 = Offset(p1.dx + (p2.dx - p0.dx) / 6, p1.dy + (p2.dy - p0.dy) / 6);
        final controlPoint2 = Offset(p2.dx - (p3.dx - p1.dx) / 6, p2.dy - (p3.dy - p1.dy) / 6);

        path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
        fillPath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
      }
      
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();

      // Implement drawing animation clip
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));

      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, paint);

      final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
      for (var point in points) {
        canvas.drawCircle(point, 4, Paint()..color = Colors.white);
        canvas.drawCircle(point, 2.5, Paint()..color = Colors.blue.shade300);

        final index = points.indexOf(point);
        textPainter.text = TextSpan(
          text: '${hourly[index].temperature.round()}°',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(point.dx - (textPainter.width / 2), point.dy - 22));
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant TemperatureGraphPainter oldDelegate) {
    return oldDelegate.hourly != hourly || oldDelegate.progress != progress;
  }
}
