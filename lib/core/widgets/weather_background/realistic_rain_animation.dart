import 'dart:math';
import 'package:flutter/material.dart';

class RealisticRainAnimation extends StatefulWidget {
  final int particleCount;
  final double windSpeed;

  const RealisticRainAnimation({
    super.key,
    this.particleCount = 200,
    this.windSpeed = 3.0,
  });

  @override
  State<RealisticRainAnimation> createState() => _RealisticRainAnimationState();
}

class _RealisticRainAnimationState extends State<RealisticRainAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_RainDrop> _drops = [];
  final Random _random = Random();
  bool _initialized = false;
  Size _bounds = Size.zero;

  @override
  void initState() {
    super.initState();
    // Using a continuous animation controller to drive the particle system
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_updateDrops)
      ..repeat();
  }

  void _initDrops(Size size) {
    if (_initialized && _bounds == size) return;
    _bounds = size;
    _drops.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      _drops.add(_createDrop(size, randomizeY: true));
    }
    _initialized = true;
  }

  _RainDrop _createDrop(Size size, {bool randomizeY = false}) {
    // z is depth. 0 is closest to the viewer (fast, thick), 1 is farthest (slow, thin, faint).
    final z = _random.nextDouble();
    
    // Using quadratic easing on z to push more particles to the background for a realistic 3D volume effect
    final depth = z * z; 
    
    final length = (1 - depth) * 20 + 8; // Drops are between 8 and 28 logical pixels long
    final strokeWidth = (1 - depth) * 1.5 + 0.5; // Between 0.5 and 2.0 thickness
    final opacity = (1 - depth) * 0.4 + 0.1; // Between 0.1 and 0.5 opacity
    
    // Closer drops fall much faster
    final speedY = (1 - depth) * 18 + 12; 
    
    return _RainDrop(
      x: _random.nextDouble() * size.width,
      y: randomizeY ? _random.nextDouble() * size.height : -length - (_random.nextDouble() * 100), // Start above the screen
      z: depth,
      length: length,
      speedY: speedY,
      strokeWidth: strokeWidth,
      opacity: opacity,
    );
  }

  void _updateDrops() {
    if (!_initialized || _bounds == Size.zero) return;

    for (int i = 0; i < _drops.length; i++) {
      final drop = _drops[i];
      drop.y += drop.speedY;
      
      // Wind speed affects closer drops more than background drops (parallax wind)
      drop.x += widget.windSpeed * (1 - drop.z);

      // If particle falls out of bounds, recycle it to the top
      if (drop.y > _bounds.height + drop.length || drop.x > _bounds.width || drop.x < 0) {
        _drops[i] = _createDrop(_bounds);
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
          _initDrops(size);
        }
        
        return RepaintBoundary(
          child: CustomPaint(
            size: size,
            painter: _RainPainter(
              drops: _drops,
              windSpeed: widget.windSpeed,
            ),
          ),
        );
      },
    );
  }
}

class _RainDrop {
  double x;
  double y;
  final double z; // Depth
  final double length;
  final double speedY;
  final double strokeWidth;
  final double opacity;

  _RainDrop({
    required this.x,
    required this.y,
    required this.z,
    required this.length,
    required this.speedY,
    required this.strokeWidth,
    required this.opacity,
  });
}

class _RainPainter extends CustomPainter {
  final List<_RainDrop> drops;
  final double windSpeed;
  
  _RainPainter({required this.drops, required this.windSpeed});

  @override
  void paint(Canvas canvas, Size size) {
    if (drops.isEmpty) return;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final drop in drops) {
      paint.color = Colors.white.withValues(alpha: drop.opacity);
      paint.strokeWidth = drop.strokeWidth;
      
      // Calculate tail position based on length and wind speed parallax
      final tailX = drop.x - (windSpeed * (1 - drop.z) * 1.5);
      final tailY = drop.y - drop.length;
      
      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(tailX, tailY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) {
    return true; // We always repaint when updated by the ticker
  }
}
