import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/utils/error_handler.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_local_data_source.dart';
import '../datasources/weather_remote_data_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherLocalDataSource localDataSource;

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(double lat, double lon) async {
    try {
      final remoteWeather = await remoteDataSource.getCurrentWeather(lat, lon);
      await localDataSource.cacheWeather(remoteWeather);
      return Right(remoteWeather);
    } on DioException catch (e) {
      if (_shouldFallbackToCache(e)) {
        final localWeather = await localDataSource.getLastWeather();
        if (localWeather != null) {
          return Right(localWeather);
        }
      }
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, ForecastEntity>> getForecast(double lat, double lon) async {
    try {
      final remoteForecast = await remoteDataSource.getForecast(lat, lon);
      await localDataSource.cacheForecast(remoteForecast);
      return Right(remoteForecast);
    } on DioException catch (e) {
      if (_shouldFallbackToCache(e)) {
        final localForecast = await localDataSource.getLastForecast();
        if (localForecast != null) {
          return Right(localForecast);
        }
      }
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return const Left(ServerFailure('An unexpected error occurred.'));
    }
  }

  bool _shouldFallbackToCache(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
           e.type == DioExceptionType.sendTimeout ||
           e.type == DioExceptionType.receiveTimeout ||
           e.type == DioExceptionType.connectionError ||
           (e.response?.statusCode != null && e.response!.statusCode! >= 500);
  }
}
