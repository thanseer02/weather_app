import 'package:flutter/material.dart';
import '../../../../core/widgets/animated_gradient_bg.dart';
import 'widgets/current_weather_view.dart';
import 'widgets/daily_forecast_view.dart';
import 'widgets/hourly_forecast_view.dart';
import 'widgets/weather_details_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: const AnimatedGradientBg(
        child: SafeArea(
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
