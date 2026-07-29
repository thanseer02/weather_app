import 'package:flutter/material.dart';
import 'weather_condition.dart';

class WeatherColors {
  static List<Color> getColors(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return const [Color(0xFF4FC3F7), Color(0xFF0288D1)]; // Light blue to dark blue
      case WeatherCondition.cloudy:
        return const [Color(0xFF90A4AE), Color(0xFF546E7A)]; // Grey tones
      case WeatherCondition.rain:
        return const [Color(0xFF5C6BC0), Color(0xFF283593)]; // Deep blue/grey
      case WeatherCondition.thunder:
        return const [Color(0xFF37474F), Color(0xFF212121)]; // Dark grey to black
      case WeatherCondition.snow:
        return const [Color(0xFFE0E0E0), Color(0xFF9E9E9E)]; // Light grey
      case WeatherCondition.fog:
        return const [Color(0xFFB0BEC5), Color(0xFF78909C)]; // Misty grey
      case WeatherCondition.windy:
        return const [Color(0xFF81D4FA), Color(0xFF0097A7)]; // Teal/blue
      case WeatherCondition.night:
        return const [Color(0xFF1A237E), Color(0xFF000000)]; // Deep indigo to black
    }
  }
}
