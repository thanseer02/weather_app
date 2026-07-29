import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'features/weather/presentation/providers/weather_provider.dart';

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
    WindowOptions windowOptions = WindowOptions(
      size: const Size(1200, 800),
      minimumSize: const Size(400, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: PlatformService.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal,
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget app = MaterialApp.router(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      scrollBehavior: AppScrollBehavior(),
      routerConfig: appRouter,
    );

    if (PlatformService.isMacOS) {
      return PlatformMenuBar(
        menus: [
          PlatformMenu(
            label: 'Weather App',
            menus: [
              PlatformMenuItemGroup(
                members: [
                  PlatformMenuItem(
                    label: 'About Weather App',
                    onSelected: () {
                      appRouter.push('/settings');
                    },
                  ),
                ],
              ),
              PlatformMenuItemGroup(
                members: [
                  PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.quit,
                  ),
                ],
              ),
            ],
          ),
          PlatformMenu(
            label: 'Weather',
            menus: [
              PlatformMenuItem(
                label: 'Refresh Weather',
                shortcut: const SingleActivator(LogicalKeyboardKey.keyR, meta: true),
                onSelected: () {
                  ref.read(weatherProvider.notifier).refresh();
                },
              ),
              PlatformMenuItem(
                label: 'Search City',
                shortcut: const SingleActivator(LogicalKeyboardKey.keyF, meta: true),
                onSelected: () {
                  appRouter.push('/search');
                },
              ),
              PlatformMenuItem(
                label: 'Settings',
                shortcut: const SingleActivator(LogicalKeyboardKey.comma, meta: true),
                onSelected: () {
                  appRouter.push('/settings');
                },
              ),
            ],
          ),
        ],
        child: app,
      );
    }
    return app;
  }
}
