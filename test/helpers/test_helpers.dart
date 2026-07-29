import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:weather/core/services/location_service.dart';
import 'package:weather/core/services/storage_service.dart';
import 'package:weather/core/services/widget_service.dart';
import 'package:weather/features/weather/domain/repositories/weather_repository.dart';

class MockDio extends Mock implements Dio {}
class MockWeatherRepository extends Mock implements WeatherRepository {}
class MockLocationService extends Mock implements LocationService {}
class MockStorageService extends Mock implements StorageService {}
class MockWidgetService extends Mock implements WidgetService {}
