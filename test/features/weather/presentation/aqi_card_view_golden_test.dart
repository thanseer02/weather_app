import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:weather/core/theme/app_theme.dart';
import 'package:weather/features/weather/domain/entities/weather_entity.dart';
import 'package:weather/features/weather/presentation/widgets/aqi_card_view.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  final tWeather = WeatherEntity(
    cityName: 'London',
    description: 'broken clouds',
    iconCode: '04d',
    temperature: 15.0,
    feelsLike: 14.5,
    tempMin: 13.0,
    tempMax: 17.0,
    humidity: 76,
    pressure: 1012,
    windSpeed: 4.1,
    windDirection: 220,
    windGust: 8.0,
    pop: 0.0,
    visibility: 10000,
    sunrise: 1722230000,
    sunset: 1722280000,
    date: DateTime.now(),
  );

  testGoldens('AqiCardView renders correctly', (tester) async {
    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(devices: [
        Device.phone,
        Device.iphone11,
      ])
      ..addScenario(
        widget: Theme(
          data: AppTheme.darkTheme,
          child: Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AqiCardView(aqi: 45),
            ),
          ),
        ),
        name: 'default_dark_theme',
      );

    await tester.pumpDeviceBuilder(builder);

    await screenMatchesGolden(tester, 'aqi_card_view_golden');
  });
}
