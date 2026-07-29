import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather/features/weather/data/datasources/weather_remote_data_source.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late WeatherRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = WeatherRemoteDataSourceImpl(mockDio);
  });

  group('WeatherRemoteDataSource', () {
    final tLat = 51.5074;
    final tLon = -0.1278;
    
    test('should perform a GET request on a URL with correct parameters', () async {
      // arrange
      final fixtureString = File('test/fixtures/weather.json').readAsStringSync();
      final jsonMap = json.decode(fixtureString);
      final response = Response(
        data: jsonMap,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );
      
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => response);

      // act
      final result = await dataSource.getCurrentWeather(tLat, tLon);

      // assert
      verify(() => mockDio.get(
        '/weather',
        queryParameters: {
          'lat': tLat,
          'lon': tLon,
        },
      )).called(1);
      
      expect(result.cityName, equals('London'));
      expect(result.temperature, equals(15.0));
      expect(result.description, equals('broken clouds'));
    });

    test('should throw a DioException when the response code is 404 or other error', () async {
      // arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')),
          ));

      // act
      final call = dataSource.getCurrentWeather;

      // assert
      expect(() => call(tLat, tLon), throwsA(isA<DioException>()));
    });
  });
}
