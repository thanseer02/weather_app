import 'package:home_widget/home_widget.dart';
import '../../features/weather/domain/entities/weather_entity.dart';
import 'package:logger/logger.dart';

class WidgetService {
  static const String appGroupId = 'group.com.example.weather'; // iOS App Group
  static const String androidWidgetName = 'WeatherWidgetProvider'; // Android Class Name

  final Logger _logger = Logger();

  Future<void> init() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  Future<void> updateWidgetData({
    required WeatherEntity weather,
    required String cityName,
  }) async {
    try {
      await HomeWidget.saveWidgetData('temperature', '${weather.temperature.round()}°');
      await HomeWidget.saveWidgetData('cityName', cityName);
      await HomeWidget.saveWidgetData('condition', weather.weatherCondition);
      
      // Request an update to all widgets on the home screen
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: 'WeatherWidget',
      );
      _logger.i('Successfully updated Home Widgets with latest weather data.');
    } catch (e) {
      _logger.e('Failed to update Home Widget: $e');
    }
  }
}
