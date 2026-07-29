import 'dart:math';
import 'package:flutter/material.dart';

class RealisticSnowAnimation extends StatefulWidget {
  final int particleCount;
  final double windSpeed;

  const RealisticSnowAnimation({
    super.key,
    this.particleCount = 150,
    this.windSpeed = 1.0,
  });

  @override
  State<RealisticSnowAnimation> createState() => _RealisticSnowAnimationState();
}

class _RealisticSnowAnimationState extends State<RealisticSnowAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_SnowFlake> _flakes = [];
  final Random _random = Random();
  bool _initialized = false;
  Size _bounds = Size.zero;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_updateFlakes)
      ..repeat();
  }

  void _initFlakes(Size size) {
    if (_initialized && _bounds == size) return;
    _bounds = size;
    _flakes.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      _flakes.add(_createFlake(size, randomizeY: true));
    }
    _initialized = true;
  }

  _SnowFlake _createFlake(Size size, {bool randomizeY = false}) {
    // Depth factor: 0 is extremely close, 1 is far background
    final z = _random.nextDouble();
    final depth = z * z; // Push more flakes to the background volume
    
    final radius = (1 - depth) * 3.5 + 1.0;
    final opacity = (1 - depth) * 0.7 + 0.1;
    // Snow falls slowly compared to rain
    final speedY = (1 - depth) * 1.5 + 0.8; 
    
    return _SnowFlake(
      x: _random.nextDouble() * size.width,
      y: randomizeY ? _random.nextDouble() * size.height : -radius * 2 - (_random.nextDouble() * 20),
      z: depth,
      radius: radius,
      speedY: speedY,
      opacity: opacity,
      // Sway physics
      oscillationPhase: _random.nextDouble() * pi * 2,
      oscillationAmplitude: (1 - depth) * 1.5 + 0.2,
      oscillationSpeed: _random.nextDouble() * 0.03 + 0.01,
    );
  }

  void _updateFlakes() {
    if (!_initialized || _bounds == Size.zero) return;
    
    _time += 1.0;

    for (int i = 0; i < _flakes.length; i++) {
      final flake = _flakes[i];
      flake.y += flake.speedY;
      
      // Combine linear wind parallax with natural sine wave fluttering
      flake.x += (widget.windSpeed * (1 - flake.z)) + 
                 sin(flake.oscillationPhase + (_time * flake.oscillationSpeed)) * flake.oscillationAmplitude;

      // Recycle flake if it falls out of view
      if (flake.y > _bounds.height + flake.radius || flake.x > _bounds.width + 20 || flake.x < -20) {
        _flakes[i] = _createFlake(_bounds);
      }
    }
    setState(() {}); // Trigger repaint
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size.width > 0 && size.height > 0) {
          _initFlakes(size);
        }
        
        return RepaintBoundary(
          child: CustomPaint(
            size: size,
            painter: _SnowPainter(
              flakes: _flakes,
            ),
          ),
        );
      },
    );
  }
}

class _SnowFlake {
  double x;
  double y;
  final double z;
  final double radius;
  final double speedY;
  final double opacity;
  final double oscillationPhase;
  final double oscillationAmplitude;
  final double oscillationSpeed;

  _SnowFlake({
    required this.x,
    required this.y,
    required this.z,
    required this.radius,
    required this.speedY,
    required this.opacity,
    required this.oscillationPhase,
    required this.oscillationAmplitude,
    required this.oscillationSpeed,
  });
}

class _SnowPainter extends CustomPainter {
  final List<_SnowFlake> flakes;
  
  // We use static paints for maximum rendering performance
  static final Paint _frontPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _blurPaint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

  _SnowPainter({required this.flakes});

  @override
  void paint(Canvas canvas, Size size) {
    if (flakes.isEmpty) return;

    for (final flake in flakes) {
      // Simulate photographic depth of field: flakes far away are out of focus (blurred)
      final paint = flake.z > 0.6 ? _blurPaint : _frontPaint;
      paint.color = Colors.white.withValues(alpha: flake.opacity);
      canvas.drawCircle(Offset(flake.x, flake.y), flake.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowPainter oldDelegate) => true;
}
