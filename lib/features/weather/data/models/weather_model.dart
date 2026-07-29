import '../../domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.cityName,
    required super.description,
    required super.iconCode,
    required super.temperature,
    required super.feelsLike,
    required super.tempMin,
    required super.tempMax,
    required super.humidity,
    required super.pressure,
    required super.windSpeed,
    required super.pop,
    required super.visibility,
    required super.sunrise,
    required super.sunset,
    required super.date,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final weatherList = json['weather'] as List?;
    final weatherData = weatherList?.isNotEmpty == true ? weatherList![0] : {};
    final mainData = json['main'] ?? {};
    final windData = json['wind'] ?? {};
    final sysData = json['sys'] ?? {};

    return WeatherModel(
      cityName: json['name'] ?? '',
      description: weatherData['description'] ?? '',
      iconCode: weatherData['icon'] ?? '01d',
      temperature: (mainData['temp'] ?? 0).toDouble(),
      feelsLike: (mainData['feels_like'] ?? 0).toDouble(),
      tempMin: (mainData['temp_min'] ?? 0).toDouble(),
      tempMax: (mainData['temp_max'] ?? 0).toDouble(),
      humidity: mainData['humidity'] ?? 0,
      pressure: mainData['pressure'] ?? 0,
      windSpeed: (windData['speed'] ?? 0).toDouble(),
      pop: (json['pop'] ?? 0).toDouble(),
      visibility: json['visibility'] ?? 0,
      sunrise: sysData['sunrise'] ?? 0,
      sunset: sysData['sunset'] ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000, isUtc: true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'weather': [
        {'description': description, 'icon': iconCode}
      ],
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'humidity': humidity,
        'pressure': pressure,
      },
      'wind': {'speed': windSpeed},
      'pop': pop,
      'visibility': visibility,
      'sys': {'sunrise': sunrise, 'sunset': sunset},
      'dt': date.millisecondsSinceEpoch ~/ 1000,
    };
  }
}

class ForecastModel extends ForecastEntity {
  const ForecastModel({
    required super.daily,
    required super.hourly,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List?;
    if (list == null) return const ForecastModel(daily: [], hourly: []);

    final allItems = list.map((item) => WeatherModel.fromJson(item)).toList();
    
    // Using OpenWeatherMap 5 day/3 hour forecast as base
    final hourly = allItems.take(8).toList();
    
    final Map<int, WeatherModel> dailyMap = {};
    for (var item in allItems) {
      final day = item.date.day;
      if (!dailyMap.containsKey(day)) {
        dailyMap[day] = item;
      }
    }
    final daily = dailyMap.values.toList();

    return ForecastModel(daily: daily, hourly: hourly);
  }

  Map<String, dynamic> toJson() {
    final combinedList = [...hourly, ...daily]
        .map((e) => (e as WeatherModel).toJson())
        .toList();
      
    return {
      'list': combinedList,
    };
  }
}
