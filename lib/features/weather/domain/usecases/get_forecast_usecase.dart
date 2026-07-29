import 'package:fpdart/fpdart.dart';
import '../../../../core/utils/error_handler.dart';
import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

class GetForecastUseCase {
  final WeatherRepository repository;

  GetForecastUseCase(this.repository);

  Future<Either<Failure, ForecastEntity>> call(double lat, double lon) {
    return repository.getForecast(lat, lon);
  }
}
