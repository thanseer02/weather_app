import 'package:fpdart/fpdart.dart';
import '../../../../core/utils/error_handler.dart';
import '../entities/weather_entity.dart';

abstract class WeatherRepository {
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(double lat, double lon);
  Future<Either<Failure, ForecastEntity>> getForecast(double lat, double lon);
}
