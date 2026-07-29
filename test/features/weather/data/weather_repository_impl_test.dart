import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:dio/dio.dart';
import 'package:weather/core/utils/error_handler.dart';
import 'package:weather/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:weather/features/weather/data/datasources/weather_local_data_source.dart';
import 'package:weather/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:weather/features/weather/data/models/weather_model.dart';
import 'package:weather/features/weather/domain/entities/weather_entity.dart';

class MockWeatherRemoteDataSource extends Mock implements WeatherRemoteDataSource {}
class MockWeatherLocalDataSource extends Mock implements WeatherLocalDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(WeatherModel(
      cityName: 'Dummy',
      description: 'Dummy',
      iconCode: '04d',
      temperature: 0.0,
      feelsLike: 0.0,
      tempMin: 0.0,
      tempMax: 0.0,
      humidity: 0,
      pressure: 0,
      windSpeed: 0.0,
      windDirection: 0,
      windGust: 0.0,
      pop: 0.0,
      visibility: 0,
      sunrise: 0,
      sunset: 0,
      date: DateTime.now(),
    ));
  });

  late WeatherRepositoryImpl repository;
  late MockWeatherRemoteDataSource mockRemoteDataSource;
  late MockWeatherLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockWeatherRemoteDataSource();
    mockLocalDataSource = MockWeatherLocalDataSource();
    repository = WeatherRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('getCurrentWeather', () {
    final tLat = 51.5074;
    final tLon = -0.1278;
    final tWeatherModel = WeatherModel(
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
      date: DateTime.now(), // Ignored in equality because it's dynamic
    );

    test('should return remote data when the call to remote data source is successful', () async {
      // arrange
      when(() => mockLocalDataSource.cacheWeather(any())).thenAnswer((_) async {});
      when(() => mockRemoteDataSource.getCurrentWeather(any(), any()))
          .thenAnswer((_) async => tWeatherModel);
      
      // act
      final result = await repository.getCurrentWeather(tLat, tLon);
      
      // assert
      verify(() => mockRemoteDataSource.getCurrentWeather(tLat, tLon));
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should be Right'),
        (r) {
          expect(r.cityName, equals('London'));
          expect(r.temperature, equals(15.0));
        },
      );
    });

    test('should return server failure when the call to remote data source is unsuccessful', () async {
      // arrange
      when(() => mockRemoteDataSource.getCurrentWeather(any(), any()))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '')));
      
      // act
      final result = await repository.getCurrentWeather(tLat, tLon);
      
      // assert
      verify(() => mockRemoteDataSource.getCurrentWeather(tLat, tLon));
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Should be Left'),
      );
    });
  });
}
