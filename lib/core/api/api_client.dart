import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'dio_interceptors.dart';

class ApiClient {
  late final Dio dio;
  final Logger logger;

  ApiClient({required this.logger}) {
    dio = Dio(BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.addAll([
      AuthInterceptor(),
      RetryInterceptor(dio: dio),
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        logPrint: (object) => logger.d(object.toString()),
      ),
    ]);
  }
}
