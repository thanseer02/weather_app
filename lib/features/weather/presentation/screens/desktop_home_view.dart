import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_split_view/multi_split_view.dart';
import '../providers/weather_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/current_weather_view.dart';
import '../widgets/temperature_chart_view.dart';
import '../widgets/daily_forecast_view.dart';
import '../widgets/hourly_forecast_view.dart';
import '../widgets/weather_details_grid.dart';
import '../widgets/aqi_card_view.dart';
import '../widgets/wind_compass_view.dart';
import '../../../../core/widgets/glass_card.dart';

import '../../../../core/services/platform_service.dart';
import 'package:window_manager/window_manager.dart';

class DesktopHomeView extends ConsumerStatefulWidget {
  const DesktopHomeView({super.key});

  @override
  ConsumerState<DesktopHomeView> createState() => _DesktopHomeViewState();
}

class _DesktopHomeViewState extends ConsumerState<DesktopHomeView> {
  int _selectedIndex = 0;
  final MultiSplitViewController _splitController = MultiSplitViewController(
    areas: [
      Area(flex: 0.3, min: 0.25),
      Area(flex: 0.4, min: 0.3),
      Area(flex: 0.3, min: 0.2),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherProvider);
    final locationAsync = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          // Sidebar Navigation Rail
          NavigationRail(
            backgroundColor: Colors.black.withValues(alpha: 0.2),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
              if (index == 1) context.push('/search');
              if (index == 3) context.push('/settings');
            },
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            selectedIconTheme: const IconThemeData(color: Colors.white),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Home')),
              NavigationRailDestination(icon: Icon(Icons.search), label: Text('Search')),
              NavigationRailDestination(icon: Icon(Icons.map), label: Text('Map')),
              NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
            ],
          ),
          
          Expanded(
            child: Shortcuts(
              shortcuts: {
                LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyR): const RefreshIntent(),
                LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR): const RefreshIntent(),
                LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyF): const SearchIntent(),
                LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF): const SearchIntent(),
                LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.comma): const SettingsIntent(),
                LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.comma): const SettingsIntent(),
              },
              child: Actions(
                actions: {
                  RefreshIntent: CallbackAction<RefreshIntent>(onInvoke: (_) => ref.read(weatherProvider.notifier).refresh()),
                  SearchIntent: CallbackAction<SearchIntent>(onInvoke: (_) => context.push('/search')),
                  SettingsIntent: CallbackAction<SettingsIntent>(onInvoke: (_) => context.push('/settings')),
                },
                child: Focus(
                  autofocus: true,
                  child: weatherAsync.when(
                    data: (weatherState) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Desktop Toolbar inside DragToMoveArea for macOS window dragging
                            DragToMoveArea(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      if (PlatformService.isMacOS) const SizedBox(width: 80), // Prevent traffic light overlap
                                      const Icon(Icons.location_on, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(
                                        locationAsync.valueOrNull?.cityName ?? 'Loading...',
                                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh, color: Colors.white),
                                    onPressed: () => ref.read(weatherProvider.notifier).refresh(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Multi Split View
                            Expanded(
                              child: MultiSplitViewTheme(
                                data: MultiSplitViewThemeData(
                                  dividerThickness: 8,
                                  dividerPainter: DividerPainters.grooved1(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    highlightedColor: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: GestureDetector(
                                  onSecondaryTapUp: (details) {
                                    final position = details.globalPosition;
                                    showMenu(
                                      context: context,
                                      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
                                      color: Colors.grey.shade900.withValues(alpha: 0.9),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      items: [
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.refresh, color: Colors.white70, size: 16),
                                              SizedBox(width: 8),
                                              Text('Refresh', style: TextStyle(color: Colors.white, fontSize: 13)),
                                            ],
                                          ),
                                          onTap: () => ref.read(weatherProvider.notifier).refresh(),
                                        ),
                                        PopupMenuItem(
                                          child: const Row(
                                            children: [
                                              Icon(Icons.settings, color: Colors.white70, size: 16),
                                              SizedBox(width: 8),
                                              Text('Settings', style: TextStyle(color: Colors.white, fontSize: 13)),
                                            ],
                                          ),
                                          onTap: () => context.push('/settings'),
                                        ),
                                      ],
                                    );
                                  },
                                  child: MultiSplitView(
                                    controller: _splitController,
                                    builder: (context, area) {
                                      final index = area.index;
                                      if (index == 0) return _buildPanel1(weatherState.current);
                                      if (index == 1) return _buildPanel2(weatherState.forecast, weatherState.current);
                                      if (index == 2) return _buildPanel3(weatherState.forecast);
                                      return const SizedBox();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                    error: (err, stack) => Center(child: Text(err.toString(), style: const TextStyle(color: Colors.white))),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel1(dynamic current) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          CurrentWeatherView(weather: current),
          const SizedBox(height: 24),
          WindCompassView(
            windDirection: current.windDirection,
            windSpeed: current.windSpeed,
            windGust: current.windGust,
          ),
          const SizedBox(height: 24),
          const AqiCardView(aqi: 2),
        ],
      ),
    );
  }

  Widget _buildPanel2(dynamic forecast, dynamic current) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          TemperatureChartView(forecast: forecast),
          const SizedBox(height: 24),
          HourlyForecastView(forecast: forecast),
          const SizedBox(height: 24),
          WeatherDetailsGrid(weather: current),
        ],
      ),
    );
  }

  Widget _buildPanel3(dynamic forecast) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          DailyForecastView(forecast: forecast),
          const SizedBox(height: 24),
          GlassCard(
            height: 300,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 64, color: Colors.white54),
                  SizedBox(height: 16),
                  Text('Interactive Map', style: TextStyle(color: Colors.white70, fontSize: 18)),
                  Text('(Coming Soon)', style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RefreshIntent extends Intent {
  const RefreshIntent();
}
class SearchIntent extends Intent {
  const SearchIntent();
}
class SettingsIntent extends Intent {
  const SettingsIntent();
}
