import 'package:flutter/material.dart';
import '../../../../core/widgets/weather_background/animated_weather_bg.dart';
import '../../../../core/widgets/weather_background/weather_condition.dart';
import 'widgets/current_weather_view.dart';
import 'widgets/daily_forecast_view.dart';
import 'widgets/hourly_forecast_view.dart';
import 'widgets/weather_details_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WeatherCondition _currentCondition = WeatherCondition.rain;

  void _cycleCondition() {
    setState(() {
      final nextIndex = (_currentCondition.index + 1) % WeatherCondition.values.length;
      _currentCondition = WeatherCondition.values[nextIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () {},
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.location_on, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'New York',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.change_circle_outlined, color: Colors.white),
            tooltip: 'Change Weather',
            onPressed: _cycleCondition, // Added to easily test all weather conditions
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: AnimatedWeatherBg(
        condition: _currentCondition,
        child: const SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 20),
                CurrentWeatherView(),
                SizedBox(height: 48),
                HourlyForecastView(),
                SizedBox(height: 32),
                DailyForecastView(),
                SizedBox(height: 32),
                WeatherDetailsGrid(),
                SizedBox(height: 60), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}
