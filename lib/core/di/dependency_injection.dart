import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:hive/hive.dart';
import '../api/api_client.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';
import '../../features/weather/data/datasources/weather_local_data_source.dart';
import '../../features/weather/data/datasources/weather_remote_data_source.dart';
import '../../features/weather/data/repositories/weather_repository_impl.dart';
import '../../features/weather/domain/repositories/weather_repository.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Core Services
  sl.registerLazySingleton(() => Logger());
  sl.registerLazySingleton(() => ApiClient(logger: sl()));
  
  final storageService = StorageService();
  await storageService.init();
  sl.registerSingleton<StorageService>(storageService);
  
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<WidgetService>(() => WidgetService());
  
  sl.registerLazySingleton(() => LocationService());

  // Data Sources
  await Hive.openBox(WeatherLocalDataSourceImpl.boxName);
  final weatherBox = Hive.box(WeatherLocalDataSourceImpl.boxName);
  
  sl.registerLazySingleton<WeatherLocalDataSource>(
      () => WeatherLocalDataSourceImpl(weatherBox));
      
  sl.registerLazySingleton<WeatherRemoteDataSource>(
      () => WeatherRemoteDataSourceImpl(apiClient: sl()));

  // Repository
  sl.registerLazySingleton<WeatherRepository>(
      () => WeatherRepositoryImpl(
            remoteDataSource: sl(),
            localDataSource: sl(),
          ));
}
