import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather(double lat, double lon);
  Future<ForecastModel> getForecast(double lat, double lon);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final ApiClient apiClient;

  WeatherRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<WeatherModel> getCurrentWeather(double lat, double lon) async {
    final response = await apiClient.dio.get(
      'weather',
      queryParameters: {'lat': lat, 'lon': lon},
    );
    return WeatherModel.fromJson(response.data);
  }

  @override
  Future<ForecastModel> getForecast(double lat, double lon) async {
    final response = await apiClient.dio.get(
      'forecast',
      queryParameters: {'lat': lat, 'lon': lon},
    );
    return ForecastModel.fromJson(response.data);
  }
}
