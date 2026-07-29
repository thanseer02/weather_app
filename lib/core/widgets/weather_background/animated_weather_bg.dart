import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'weather_condition.dart';
import 'weather_particles_painter.dart';
import 'weather_colors.dart';
import 'realistic_rain_animation.dart';
import 'realistic_snow_animation.dart';
import 'realistic_thunder_animation.dart';

class AnimatedWeatherBg extends StatefulWidget {
  final WeatherCondition condition;
  final Widget child;

  const AnimatedWeatherBg({
    super.key,
    required this.condition,
    required this.child,
  });

  @override
  State<AnimatedWeatherBg> createState() => _AnimatedWeatherBgState();
}

class _AnimatedWeatherBgState extends State<AnimatedWeatherBg> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final ParticleSystem _particleSystem = ParticleSystem();
  
  Color? _currentColor1;
  Color? _currentColor2;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant AnimatedWeatherBg oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.condition != widget.condition) {
      _particleSystem.changeCondition(widget.condition);
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    
    final dt = (elapsed.inMilliseconds - _lastTick.inMilliseconds) / 1000.0;
    _lastTick = elapsed;
    
    if (dt > 0.1) return; // Cap dt for massive frame drops or backgrounding

    setState(() {
      _particleSystem.update(dt, widget.condition);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetColors = WeatherColors.getColors(widget.condition);
    
    return TweenAnimationBuilder<Color?>(
      duration: const Duration(milliseconds: 800),
      tween: ColorTween(begin: _currentColor1 ?? targetColors[0], end: targetColors[0]),
      onEnd: () => _currentColor1 = targetColors[0],
      builder: (context, color1, _) {
        return TweenAnimationBuilder<Color?>(
          duration: const Duration(milliseconds: 800),
          tween: ColorTween(begin: _currentColor2 ?? targetColors[1], end: targetColors[1]),
          onEnd: () => _currentColor2 = targetColors[1],
          builder: (context, color2, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color1 ?? targetColors[0], color2 ?? targetColors[1]],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: WeatherParticlesPainter(
                      system: _particleSystem,
                      condition: widget.condition,
                    ),
                  ),
                  if (widget.condition == WeatherCondition.rain || widget.condition == WeatherCondition.thunder)
                    const RealisticRainAnimation(
                      particleCount: 200,
                      windSpeed: 4.0,
                    ),
                  if (widget.condition == WeatherCondition.snow)
                    const RealisticSnowAnimation(
                      particleCount: 150,
                      windSpeed: 1.5,
                    ),
                  if (widget.condition == WeatherCondition.thunder)
                    const RealisticThunderAnimation(),
                  widget.child,
                ],
              ),
            );
          },
        );
      },
    );
  }
}
