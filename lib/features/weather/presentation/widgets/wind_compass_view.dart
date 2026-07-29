import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/section_header.dart';
import 'dart:math' as math;

class WindCompassView extends StatefulWidget {
  final int windDirection;
  final double windSpeed;
  final double windGust;

  const WindCompassView({
    super.key,
    required this.windDirection,
    required this.windSpeed,
    required this.windGust,
  });

  @override
  State<WindCompassView> createState() => _WindCompassViewState();
}

class _WindCompassViewState extends State<WindCompassView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    
    final targetRadians = widget.windDirection * (math.pi / 180);
    _animation = Tween<double>(begin: 0, end: targetRadians).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant WindCompassView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.windDirection != widget.windDirection) {
      final oldRadians = oldWidget.windDirection * (math.pi / 180);
      final newRadians = widget.windDirection * (math.pi / 180);
      _animation = Tween<double>(begin: oldRadians, end: newRadians).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  String _getCardinalDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'];
    return directions[((degrees % 360) / 45).round()];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Wind'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Animated Compass
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // N, E, S, W markers
                            const Positioned(top: 0, child: Text('N', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                            const Positioned(bottom: 0, child: Text('S', style: TextStyle(color: Colors.white54))),
                            const Positioned(left: 0, child: Text('W', style: TextStyle(color: Colors.white54))),
                            const Positioned(right: 0, child: Text('E', style: TextStyle(color: Colors.white54))),
                            
                            // Compass circle
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white24, width: 2),
                              ),
                            ),
                            
                            // Speed in center
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.windSpeed.round().toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'm/s',
                                  style: TextStyle(color: Colors.white54, fontSize: 10),
                                ),
                              ],
                            ),
                            
                            // Animated Needle
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _animation.value,
                                  child: child,
                                );
                              },
                              child: const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    top: 10,
                                    child: Icon(Icons.navigation, color: Colors.amber, size: 20),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.explore, color: Colors.lightBlueAccent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Direction', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                Text(
                                  '${widget.windDirection}° ${_getCardinalDirection(widget.windDirection)}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.air, color: Colors.amber),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Gusts', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                Text(
                                  '${widget.windGust.round()} m/s',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
