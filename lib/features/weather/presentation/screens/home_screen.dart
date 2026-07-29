import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/weather_background/animated_weather_bg.dart';
import '../../../../core/widgets/weather_background/weather_condition.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../providers/weather_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/current_weather_view.dart';
import '../widgets/temperature_chart_view.dart';
import '../widgets/daily_forecast_view.dart';
import '../widgets/hourly_forecast_view.dart';
import '../widgets/weather_details_grid.dart';
import '../widgets/aqi_card_view.dart';
import '../widgets/wind_compass_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Simple mapping from OpenWeather icon code to our WeatherCondition
  WeatherCondition _mapIconToCondition(String iconCode) {
    if (iconCode.contains('01')) return WeatherCondition.sunny;
    if (iconCode.contains('02') || iconCode.contains('03') || iconCode.contains('04')) return WeatherCondition.cloudy;
    if (iconCode.contains('09') || iconCode.contains('10')) return WeatherCondition.rain;
    if (iconCode.contains('11')) return WeatherCondition.thunder;
    if (iconCode.contains('13')) return WeatherCondition.snow;
    if (iconCode.contains('50')) return WeatherCondition.fog;
    return WeatherCondition.sunny; // Default
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherProvider);
    final locationAsync = ref.watch(locationProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Hero(
            tag: 'search_bar',
            child: Icon(Icons.search, color: Colors.white),
          ),
          onPressed: () {
            context.push('/search');
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              locationAsync.valueOrNull?.cityName ?? 'Loading...',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              context.push('/settings');
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.read(weatherProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation.drive(Tween(begin: 0.95, end: 1.0)),
              child: child,
            ),
          );
        },
        child: weatherAsync.when(
          data: (weatherState) {
          final condition = _mapIconToCondition(weatherState.current.iconCode);
          return AnimatedWeatherBg(
            condition: condition,
            child: SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: () => ref.read(weatherProvider.notifier).refresh(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      CurrentWeatherView(weather: weatherState.current),
                      const SizedBox(height: 48),
                      TemperatureChartView(forecast: weatherState.forecast),
                      const SizedBox(height: 48),
                      HourlyForecastView(forecast: weatherState.forecast),
                      const SizedBox(height: 32),
                      DailyForecastView(forecast: weatherState.forecast),
                      const SizedBox(height: 32),
                      const AqiCardView(aqi: 2), // Mocked AQI
                      const SizedBox(height: 32),
                      WindCompassView(
                        windDirection: weatherState.current.windDirection,
                        windSpeed: weatherState.current.windSpeed,
                        windGust: weatherState.current.windGust,
                      ),
                      const SizedBox(height: 32),
                      WeatherDetailsGrid(weather: weatherState.current),
                      const SizedBox(height: 60), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ),
          );
        },
        loading: () => AnimatedWeatherBg(
          condition: WeatherCondition.sunny,
          child: const LoadingWidget(message: 'Fetching weather...'),
        ),
        error: (err, stack) => AnimatedWeatherBg(
          condition: WeatherCondition.cloudy,
          child: CustomErrorWidget(
            message: err.toString().replaceAll('Exception: ', ''),
            onRetry: () => ref.read(weatherProvider.notifier).refresh(),
          ),
        ),
        ),
      ),
    );
  }
}
