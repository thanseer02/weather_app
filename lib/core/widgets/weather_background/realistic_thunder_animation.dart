import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class RealisticThunderAnimation extends StatefulWidget {
  const RealisticThunderAnimation({super.key});

  @override
  State<RealisticThunderAnimation> createState() => _RealisticThunderAnimationState();
}

class _RealisticThunderAnimationState extends State<RealisticThunderAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  
  final List<_LightningBolt> _bolts = [];
  double _screenFlash = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_updateThunder)
      ..repeat();
  }

  void _updateThunder() {
    bool needsRepaint = false;

    // Fade out screen flash rapidly
    if (_screenFlash > 0) {
      _screenFlash -= 0.06;
      if (_screenFlash < 0) _screenFlash = 0.0;
      needsRepaint = true;
    }

    // Random chance to strike (roughly 1.5% chance per frame if no active bolts)
    // Decreased chance if a bolt is already on screen to avoid overwhelming
    if (_random.nextDouble() < (_bolts.isEmpty ? 0.015 : 0.002)) {
      _generateStrike();
      needsRepaint = true;
    }

    // Update active bolts
    for (int i = _bolts.length - 1; i >= 0; i--) {
      // Bolts flicker and fade quickly
      _bolts[i].opacity -= 0.07;
      if (_bolts[i].opacity <= 0) {
        _bolts.removeAt(i);
      }
      needsRepaint = true;
    }

    if (needsRepaint) {
      setState(() {}); // Trigger repaint
    }
  }

  void _generateStrike() {
    final size = MediaQuery.of(context).size;
    
    // Starting point at the top, somewhere random horizontally
    final startX = _random.nextDouble() * size.width;
    final startY = -20.0; // Slightly above screen

    _bolts.add(_LightningBolt(
      path: _generateJaggedPath(startX, startY, size.width, size.height),
      opacity: 1.0,
      startX: startX,
      startY: startY,
    ));

    // Flash the screen intensely
    _screenFlash = 0.5; // Max opacity of flash
  }

  Path _generateJaggedPath(double startX, double startY, double width, double height) {
    final path = Path();
    path.moveTo(startX, startY);

    double currentX = startX;
    double currentY = startY;

    // Bolt goes downwards in jagged segments
    while (currentY < height) {
      currentY += _random.nextDouble() * 40 + 20; // Move down
      currentX += (_random.nextDouble() * 100) - 50; // Move left/right
      
      path.lineTo(currentX, currentY);
      
      // Forking chance (add a small sub-branch that diverges)
      if (_random.nextDouble() < 0.25) {
        final forkPath = Path();
        forkPath.moveTo(currentX, currentY);
        double forkX = currentX + (_random.nextDouble() * 80) - 40;
        double forkY = currentY + (_random.nextDouble() * 60) + 20;
        forkPath.lineTo(forkX, forkY);
        path.addPath(forkPath, Offset.zero);
      }
    }

    return path;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ThunderPainter(
            bolts: _bolts,
            screenFlash: _screenFlash,
          ),
        ),
      ),
    );
  }
}

class _LightningBolt {
  final Path path;
  double opacity;
  final double startX;
  final double startY;

  _LightningBolt({
    required this.path,
    required this.opacity,
    required this.startX,
    required this.startY,
  });
}

class _ThunderPainter extends CustomPainter {
  final List<_LightningBolt> bolts;
  final double screenFlash;

  _ThunderPainter({required this.bolts, required this.screenFlash});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw global screen flash (hardware accelerated alpha blend)
    if (screenFlash > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white.withOpacity(screenFlash),
      );
    }

    if (bolts.isEmpty) return;

    final boltPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    for (final bolt in bolts) {
      if (bolt.opacity <= 0) continue;

      // Cloud Illumination at the top origin of the strike
      final illuminationPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(bolt.startX, 0),
          250, // Radius of illumination
          [
            Colors.deepPurpleAccent.withOpacity(bolt.opacity * 0.4),
            Colors.white.withOpacity(bolt.opacity * 0.2),
            Colors.transparent,
          ],
          [0.0, 0.3, 1.0],
        );

      // Draw the cloud illumination flash
      canvas.drawCircle(Offset(bolt.startX, 0), 300, illuminationPaint);

      // Draw the ambient glow around the bolt
      glowPaint.color = Colors.blueAccent.withOpacity(bolt.opacity * 0.7);
      canvas.drawPath(bolt.path, glowPaint);

      // Draw the core white bolt
      boltPaint.color = Colors.white.withOpacity(bolt.opacity);
      canvas.drawPath(bolt.path, boltPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThunderPainter oldDelegate) => true;
}
