import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'core/di/dependency_injection.dart';
import 'core/services/notification_service.dart';
import 'core/services/background_task_service.dart';
import 'package:home_widget/home_widget.dart' hide callbackDispatcher;
import 'package:window_manager/window_manager.dart';
import 'core/theme/app_scroll_behavior.dart';
import 'core/services/platform_service.dart';

@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri?.host == 'refresh') {
    // A simplified trigger to run the weather background fetch
    callbackDispatcher(); 
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await setupLocator();
  
  // Initialize Push Notifications
  await sl<NotificationService>().init();
  
  // Initialize Background Tasks
  await BackgroundTaskService.init();
  await BackgroundTaskService.scheduleWeatherChecks();

  if (PlatformService.isDesktop) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(400, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  if (PlatformService.isMobile) {
    HomeWidget.registerInteractivityCallback(backgroundCallback);
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      scrollBehavior: AppScrollBehavior(),
      routerConfig: appRouter,
    );
  }
}
