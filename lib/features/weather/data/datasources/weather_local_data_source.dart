import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/weather_model.dart';

abstract class WeatherLocalDataSource {
  Future<WeatherModel?> getLastWeather();
  Future<void> cacheWeather(WeatherModel weather);
  
  Future<ForecastModel?> getLastForecast();
  Future<void> cacheForecast(ForecastModel forecast);
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  static const String boxName = 'weather_cache';
  static const String weatherKey = 'cached_weather';
  static const String forecastKey = 'cached_forecast';

  final Box box;

  WeatherLocalDataSourceImpl(this.box);

  @override
  Future<WeatherModel?> getLastWeather() async {
    final jsonString = box.get(weatherKey);
    if (jsonString != null) {
      return WeatherModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  @override
  Future<void> cacheWeather(WeatherModel weather) async {
    await box.put(weatherKey, jsonEncode(weather.toJson()));
  }

  @override
  Future<ForecastModel?> getLastForecast() async {
    final jsonString = box.get(forecastKey);
    if (jsonString != null) {
      return ForecastModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  @override
  Future<void> cacheForecast(ForecastModel forecast) async {
    await box.put(forecastKey, jsonEncode(forecast.toJson()));
  }
}
