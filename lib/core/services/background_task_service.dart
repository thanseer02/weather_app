import 'package:workmanager/workmanager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../di/dependency_injection.dart';
import 'storage_service.dart';
import 'notification_service.dart';
import 'widget_service.dart';
import '../../features/weather/domain/repositories/weather_repository.dart';
import 'platform_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // 1. Initialize core background dependencies
      await dotenv.load(fileName: ".env");
      await setupLocator(); 
      final storageService = sl<StorageService>();
      final weatherRepository = sl<WeatherRepository>();
      final notificationService = sl<NotificationService>();
      final widgetService = sl<WidgetService>();
      
      await notificationService.init();
      await widgetService.init();

      // 2. Fetch last known location
      final location = storageService.getLastLocation();
      if (location == null) return Future.value(true);

      // 3. Check settings to see if notifications are even enabled
      final settingsJson = storageService.getSettings();
      if (settingsJson != null) {
         if (settingsJson['notificationsEnabled'] == false) {
           return Future.value(true);
         }
      }

      // 4. Fetch Weather Data for alerts
      final weatherResult = await weatherRepository.getCurrentWeather(location.lat, location.lon);
      
      weatherResult.fold(
        (failure) {},
        (weather) async {
          // Push to Home Widgets
          await widgetService.updateWidgetData(weather: weather, cityName: location.cityName);

          final temp = weather.temperature;
          final condition = weather.description.toLowerCase();
          final wind = weather.windSpeed;
          
          String? alertTitle;
          String? alertBody;

          // Extreme Heat
          if (temp >= 35.0) {
            alertTitle = 'Extreme Heat Alert \u{1F525}';
            alertBody = 'It is currently ${temp.round()}°C in ${location.cityName}. Stay hydrated and avoid prolonged sun exposure.';
          }
          // Cold Warning
          else if (temp <= 0.0) {
            alertTitle = 'Freezing Warning \u{2744}';
            alertBody = 'Temperatures have dropped to ${temp.round()}°C in ${location.cityName}. Bundle up!';
          }
          // Storm Alert
          else if (condition.contains('thunder') || condition.contains('storm') || wind > 20.0) {
            alertTitle = 'Severe Storm Warning \u{26C8}';
            alertBody = 'A storm is currently hitting ${location.cityName}. Seek shelter!';
          }
          // Rain Alert
          else if (condition.contains('rain') || condition.contains('drizzle')) {
            alertTitle = 'Rain Alert \u{1F327}';
            alertBody = 'It is raining in ${location.cityName}. Don\'t forget your umbrella!';
          }

          if (alertTitle != null && alertBody != null) {
             notificationService.showWeatherAlert(
               id: 100, 
               title: alertTitle, 
               body: alertBody
             );
          }
        }
      );

      // 5. Morning Forecast logic
      // In a robust app, we'd check if the current time is ~ 8:00 AM. 
      // For this demo, we assume the scheduled task handles timing.
      
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

class BackgroundTaskService {
  static const String weatherCheckTask = 'weather_check_task';

  static Future<void> init() async {
    if (!PlatformService.isMobile) return;

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> scheduleWeatherChecks() async {
    if (!PlatformService.isMobile) return;

    // Schedule a periodic task every 3 hours. 
    // Note: Android minimum periodic interval is 15 minutes.
    await Workmanager().registerPeriodicTask(
      '1',
      weatherCheckTask,
      frequency: const Duration(hours: 3),
      constraints: Constraints(
        networkType: NetworkType.connected, // Only run when internet is available
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }
}
