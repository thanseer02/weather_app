import '../models/widget_data_model.dart';
import 'package:home_widget/home_widget.dart';
import '../../../services/platform_service.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

abstract class WidgetUpdater {
  Future<void> update(WidgetDataModel data);
}

class MobileWidgetUpdater implements WidgetUpdater {
  static const String androidWidgetName = 'WeatherWidgetProvider';
  final Logger _logger = Logger();

  @override
  Future<void> update(WidgetDataModel data) async {
    if (!PlatformService.isMobile) return;
    try {
      await HomeWidget.saveWidgetData('temperature', '${data.temperature.round()}°');
      await HomeWidget.saveWidgetData('cityName', data.cityName);
      await HomeWidget.saveWidgetData('condition', data.condition);
      
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: 'WeatherWidget',
      );
      _logger.i('Mobile Home Widget updated successfully.');
    } catch (e) {
      _logger.e('Failed to update Mobile Home Widget: $e');
    }
  }
}

class DesktopWidgetUpdater implements WidgetUpdater {
  final Logger _logger = Logger();

  @override
  Future<void> update(WidgetDataModel data) async {
    if (!PlatformService.isDesktop) return;
    try {
      // Stub: Save payload into a local JSON cache file or notify desktop layout
      // Desktop widgets can read this state exported by the main application
      _logger.i('Desktop Widget state exported: ${jsonEncode(data.toJson())}');
    } catch (e) {
      _logger.e('Failed to export Desktop Widget state: $e');
    }
  }
}

class WebWidgetUpdater implements WidgetUpdater {
  final Logger _logger = Logger();

  @override
  Future<void> update(WidgetDataModel data) async {
    if (!PlatformService.isWeb) return;
    try {
      // Stub: Publish message via window.postMessage for iframe embed widgets
      _logger.i('Web Widget state updated: ${jsonEncode(data.toJson())}');
    } catch (e) {
      _logger.e('Failed to update Web Widget state: $e');
    }
  }
}
