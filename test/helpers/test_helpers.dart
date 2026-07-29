import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:weather/core/api/api_client.dart';
import 'package:weather/core/services/location_service.dart';
import 'package:weather/core/services/storage_service.dart';
import 'package:weather/core/services/widget_service.dart';
import 'package:weather/features/weather/domain/repositories/weather_repository.dart';
import 'package:weather/features/weather/data/datasources/weather_local_data_source.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockWeatherLocalDataSource extends Mock implements WeatherLocalDataSource {}
class MockDio extends Mock implements Dio {}
class MockWeatherRepository extends Mock implements WeatherRepository {}
class MockLocationService extends Mock implements LocationService {}
class MockStorageService extends Mock implements StorageService {}
class MockWidgetService extends Mock implements WidgetService {}
