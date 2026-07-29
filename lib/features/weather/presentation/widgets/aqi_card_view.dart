import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/section_header.dart';
import 'dart:math';

class AqiCardView extends StatefulWidget {
  final int aqi; 

  const AqiCardView({super.key, required this.aqi});

  @override
  State<AqiCardView> createState() => _AqiCardViewState();
}

class _AqiCardViewState extends State<AqiCardView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AqiCardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.aqi != widget.aqi) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getAqiCategory(int aqi) {
    switch (aqi) {
      case 1: return 'Good';
      case 2: return 'Fair';
      case 3: return 'Moderate';
      case 4: return 'Poor';
      case 5: return 'Very Poor';
      default: return 'Good';
    }
  }

  Color getAqiColor(int aqi) {
    switch (aqi) {
      case 1: return Colors.greenAccent;
      case 2: return Colors.lightGreenAccent;
      case 3: return Colors.amber;
      case 4: return Colors.deepOrangeAccent;
      case 5: return Colors.redAccent;
      default: return Colors.greenAccent;
    }
  }

  String getHealthSuggestion(int aqi) {
    switch (aqi) {
      case 1: return 'Air quality is satisfactory, and air pollution poses little or no risk.';
      case 2: return 'Air quality is acceptable; however, there may be a moderate health concern for some.';
      case 3: return 'Sensitive groups may experience health effects. The public is not likely to be affected.';
      case 4: return 'Everyone may begin to experience health effects; sensitive groups may experience serious effects.';
      case 5: return 'Health warnings of emergency conditions. The entire population is likely to be affected.';
      default: return 'Air quality is satisfactory, and air pollution poses little or no risk.';
    }
  }

  @override
  Widget build(BuildContext context) {
    // For demo purposes, we clamp the AQI to ensure it doesn't break the gauge
    final aqi = widget.aqi.clamp(1, 5); 
    final category = getAqiCategory(aqi);
    final color = getAqiColor(aqi);
    final suggestion = getHealthSuggestion(aqi);

    final targetProgress = aqi / 5.0;

    return Semantics(
      label: 'Air quality index is $aqi, which is $category. $suggestion',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Air Quality'),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.masks, color: color, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              category.toUpperCase(),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        suggestion,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final currentProgress = _animation.value * targetProgress;
                      return AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(
                          painter: AqiGaugePainter(
                            progress: currentProgress,
                            color: color,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  aqi.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'AQI',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class AqiGaugePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;

  AqiGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 12.0;

    final bgPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = 3 * pi / 4;
    const totalSweepAngle = 3 * pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweepAngle,
      false,
      bgPaint,
    );

    final progressPaint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    progressPaint.shader = SweepGradient(
      colors: [color.withValues(alpha: 0.3), color],
      startAngle: startAngle,
      endAngle: startAngle + totalSweepAngle,
      transform: const GradientRotation(startAngle),
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweepAngle * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant AqiGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
