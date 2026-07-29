import 'dart:math';
import 'package:flutter/material.dart';
import 'weather_condition.dart';
import 'weather_particle.dart';

class ParticleSystem {
  List<WeatherParticle> particles = [];
  List<CloudParticle> clouds = [];
  double lightningFlash = 0.0;
  Size bounds = const Size(400, 800);
  bool _initialized = false;
  
  void init(WeatherCondition condition, Size size) {
    bounds = size;
    if (!_initialized) {
      _setupParticles(condition);
      _initialized = true;
    }
  }

  void changeCondition(WeatherCondition condition) {
    _setupParticles(condition);
  }

  void _setupParticles(WeatherCondition condition) {
    particles.clear();
    clouds.clear();
    lightningFlash = 0.0;

    int particleCount = 0;
    int cloudCount = 0;
    bool isSnow = false;
    bool isFog = false;

    switch (condition) {
      case WeatherCondition.rain:
      case WeatherCondition.thunder:
        particleCount = 150;
        cloudCount = 5;
        break;
      case WeatherCondition.snow:
        particleCount = 200;
        cloudCount = 3;
        isSnow = true;
        break;
      case WeatherCondition.cloudy:
      case WeatherCondition.windy:
        cloudCount = 8;
        break;
      case WeatherCondition.fog:
        cloudCount = 6;
        isFog = true;
        break;
      default:
        break;
    }

    for (int i = 0; i < particleCount; i++) {
      particles.add(WeatherParticle.generate(bounds, isSnow: isSnow));
    }

    for (int i = 0; i < cloudCount; i++) {
      clouds.add(CloudParticle.generate(bounds, isFog: isFog));
    }
  }

  void update(double dt, WeatherCondition condition) {
    for (var p in particles) {
      p.update(dt, bounds, isSnow: condition == WeatherCondition.snow);
    }
    for (var c in clouds) {
      c.update(dt, bounds);
    }

    if (condition == WeatherCondition.thunder) {
      if (Random().nextDouble() < 0.01) { // 1% chance each frame
        lightningFlash = 1.0;
      }
      if (lightningFlash > 0) {
        lightningFlash -= dt * 2; // Fade out quickly
      }
    } else {
      lightningFlash = 0.0;
    }
  }
}

class WeatherParticlesPainter extends CustomPainter {
  final ParticleSystem system;
  final WeatherCondition condition;

  WeatherParticlesPainter({
    required this.system,
    required this.condition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;
    
    // Ensure bounds are set correctly.
    if (system.bounds != size) {
      system.init(condition, size);
    }

    final paint = Paint()..style = PaintingStyle.fill;

    // Draw clouds/fog
    for (var c in system.clouds) {
      paint.color = Colors.white.withValues(alpha: c.opacity);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawOval(Rect.fromCenter(center: Offset(c.x, c.y), width: c.sizeX, height: c.sizeY), paint);
    }

    paint.maskFilter = null;

    // Draw lightning
    if (system.lightningFlash > 0) {
      paint.color = Colors.white.withValues(alpha: system.lightningFlash.clamp(0.0, 1.0));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant WeatherParticlesPainter oldDelegate) => true;
}
