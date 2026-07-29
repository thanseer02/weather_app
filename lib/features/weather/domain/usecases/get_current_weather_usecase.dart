import 'package:fpdart/fpdart.dart';
import '../../../../core/utils/error_handler.dart';
import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

class GetCurrentWeatherUseCase {
  final WeatherRepository repository;

  GetCurrentWeatherUseCase(this.repository);

  Future<Either<Failure, WeatherEntity>> call(double lat, double lon) {
    return repository.getCurrentWeather(lat, lon);
  }
}
