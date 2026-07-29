import 'dart:math';
import 'package:flutter/material.dart';

class WeatherParticle {
  double x;
  double y;
  double speedX;
  double speedY;
  double size;
  double opacity;

  WeatherParticle({
    required this.x,
    required this.y,
    required this.speedX,
    required this.speedY,
    required this.size,
    required this.opacity,
  });

  factory WeatherParticle.generate(Size bounds, {bool isRain = true, bool isSnow = false}) {
    final random = Random();
    double size = isSnow ? random.nextDouble() * 3 + 2 : random.nextDouble() * 2 + 1;
    double speedY = isSnow ? random.nextDouble() * 50 + 50 : random.nextDouble() * 400 + 400; // Snow is slower than rain
    double speedX = isSnow ? random.nextDouble() * 40 - 20 : random.nextDouble() * 20 - 10;
    
    // For clouds / fog, properties will be heavily modified later
    return WeatherParticle(
      x: random.nextDouble() * bounds.width,
      y: random.nextDouble() * bounds.height - bounds.height, // start above screen
      speedX: speedX,
      speedY: speedY,
      size: size,
      opacity: isSnow ? random.nextDouble() * 0.5 + 0.3 : random.nextDouble() * 0.3 + 0.1,
    );
  }

  void update(double dt, Size bounds, {bool isRain = true, bool isSnow = false}) {
    x += speedX * dt;
    y += speedY * dt;

    // Reset if it goes off screen
    if (y > bounds.height) {
      y = -size;
      x = Random().nextDouble() * bounds.width;
    }
    if (x > bounds.width) x = 0;
    if (x < 0) x = bounds.width;
  }
}

// Clouds are managed differently as they are fewer and move horizontally
class CloudParticle {
  double x;
  double y;
  double sizeX;
  double sizeY;
  double speedX;
  double opacity;

  CloudParticle({
    required this.x,
    required this.y,
    required this.sizeX,
    required this.sizeY,
    required this.speedX,
    required this.opacity,
  });

  factory CloudParticle.generate(Size bounds, {bool isFog = false}) {
    final random = Random();
    double scale = isFog ? 2.0 : 1.0;
    return CloudParticle(
      x: random.nextDouble() * bounds.width,
      y: isFog ? bounds.height - (random.nextDouble() * 200) : random.nextDouble() * bounds.height * 0.5,
      sizeX: (random.nextDouble() * 150 + 100) * scale,
      sizeY: (random.nextDouble() * 50 + 40) * scale,
      speedX: random.nextDouble() * 20 + (isFog ? 10 : 5),
      opacity: isFog ? 0.2 : random.nextDouble() * 0.3 + 0.1,
    );
  }

  void update(double dt, Size bounds) {
    x += speedX * dt;
    if (x > bounds.width + sizeX) {
      x = -sizeX;
      y = Random().nextDouble() * bounds.height * 0.5;
    }
  }
}
