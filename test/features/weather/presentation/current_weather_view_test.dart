import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:weather/features/weather/domain/entities/weather_entity.dart';
import 'package:weather/features/weather/presentation/widgets/current_weather_view.dart';

void main() {
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

  testWidgets('should display temperature, description and high/low stats', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrentWeatherView(weather: tWeather),
          ),
        ),
      );

      // Verify Temperature
      expect(find.text('15°'), findsOneWidget);
      
      // Verify Description (Uppercase)
      expect(find.text('BROKEN CLOUDS'), findsOneWidget);
      
      // Verify Min Max
      expect(find.text('H:17°  L:13°'), findsOneWidget);
    });
  });
}
