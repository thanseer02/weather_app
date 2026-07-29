import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = 3});

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    var extra = err.requestOptions.extra;
    var retries = (extra['retries'] ?? 0) as int;
    
    if (_shouldRetry(err) && retries < maxRetries) {
      extra['retries'] = retries + 1;
      
      // Exponential backoff
      await Future.delayed(Duration(milliseconds: (1000 * (retries + 1))));
      
      try {
        final options = err.requestOptions;
        options.extra = extra;
        final response = await dio.request(
          options.path,
          options: Options(
            method: options.method,
            headers: options.headers,
            extra: options.extra,
          ),
          data: options.data,
          queryParameters: options.queryParameters,
        );
        return handler.resolve(response);
      } catch (e) {
        return super.onError(err, handler);
      }
    }
    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.type == DioExceptionType.badResponse && err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // We assume the .env file has OPENWEATHER_API_KEY
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? 'YOUR_API_KEY';
    options.queryParameters['appid'] = apiKey;
    options.queryParameters['units'] = 'metric';
    super.onRequest(options, handler);
  }
}
