import '../../features/weather/domain/entities/weather_entity.dart';
import '../widgets/shared/models/widget_data_model.dart';
import '../widgets/shared/services/widget_update_orchestrator.dart';
import '../di/dependency_injection.dart';

class WidgetService {
  static const String appGroupId = 'group.com.example.weather'; // iOS App Group
  static const String androidWidgetName = 'WeatherWidgetProvider'; // Android Class Name

  Future<void> init() async {
    // Left for backward compatibility or direct calls
  }

  Future<void> updateWidgetData({
    required WeatherEntity weather,
    required String cityName,
  }) async {
    try {
      await sl<WidgetUpdateOrchestrator>().dispatchUpdate(
        WidgetDataModel(
          cityName: cityName,
          temperature: weather.temperature,
          condition: weather.description,
          iconCode: weather.iconCode,
          lastUpdated: DateTime.now(),
          tempMin: weather.tempMin,
          tempMax: weather.tempMax,
        ),
      );
    } catch (_) {}
  }
}
