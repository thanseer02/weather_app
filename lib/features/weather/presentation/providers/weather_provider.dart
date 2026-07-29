import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import 'location_provider.dart';
import '../../../../core/services/widget_service.dart';

class WeatherState extends Equatable {
  final WeatherEntity current;
  final ForecastEntity forecast;

  const WeatherState({required this.current, required this.forecast});

  @override
  List<Object?> get props => [current, forecast];
}

final weatherProvider = AsyncNotifierProvider<WeatherNotifier, WeatherState>(
  WeatherNotifier.new,
);

class WeatherNotifier extends AsyncNotifier<WeatherState> {
  late final WeatherRepository _repository;

  @override
  Future<WeatherState> build() async {
    _repository = sl<WeatherRepository>();
    
    // Automatically watch location changes. If location updates, this will re-run.
    final location = await ref.watch(locationProvider.future);
    
    return _fetchWeather(location.lat, location.lon);
  }

  Future<WeatherState> _fetchWeather(double lat, double lon) async {
    final weatherResult = await _repository.getCurrentWeather(lat, lon);
    final forecastResult = await _repository.getForecast(lat, lon);

    return weatherResult.fold(
      (failure) => throw Exception(failure.message),
      (weather) => forecastResult.fold(
        (failure) => throw Exception(failure.message),
        (forecast) {
          final cityName = sl<StorageService>().getLastLocation()?.cityName ?? 'Unknown';
          sl<WidgetService>().updateWidgetData(weather: weather, cityName: cityName);
          return WeatherState(current: weather, forecast: forecast);
        },
      ),
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final location = await ref.read(locationProvider.future);
    state = await AsyncValue.guard(() => _fetchWeather(location.lat, location.lon));
  }
}
