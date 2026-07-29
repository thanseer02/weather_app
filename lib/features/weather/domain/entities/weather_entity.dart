import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  final String cityName;
  final String description;
  final String iconCode;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int windDirection;
  final double windGust;
  final double pop; // Probability of precipitation (0.0 to 1.0)
  final int visibility;
  final int sunrise;
  final int sunset;
  final DateTime date;

  const WeatherEntity({
    required this.cityName,
    required this.description,
    required this.iconCode,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    required this.windGust,
    required this.pop,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
    required this.date,
  });

  @override
  List<Object?> get props => [
        cityName,
        description,
        iconCode,
        temperature,
        feelsLike,
        tempMin,
        tempMax,
        humidity,
        pressure,
        windSpeed,
        windDirection,
        windGust,
        pop,
        visibility,
        sunrise,
        sunset,
        date,
      ];
}

class ForecastEntity extends Equatable {
  final List<WeatherEntity> daily;
  final List<WeatherEntity> hourly;

  const ForecastEntity({
    required this.daily,
    required this.hourly,
  });

  @override
  List<Object?> get props => [daily, hourly];
}
