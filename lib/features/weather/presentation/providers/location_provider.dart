import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/location_entity.dart';
import 'search_provider.dart';

final locationProvider = AsyncNotifierProvider<LocationNotifier, LocationEntity>(
  LocationNotifier.new,
);

class LocationNotifier extends AsyncNotifier<LocationEntity> {
  late final LocationService _locationService;
  late final StorageService _storageService;

  @override
  Future<LocationEntity> build() async {
    _locationService = sl<LocationService>();
    _storageService = sl<StorageService>();
    
    final lastLocation = _storageService.getLastLocation();
    
    // We immediately return lastLocation if it exists to quickly show cached data, 
    // but we also asynchronously trigger a GPS fetch to update it in the background.
    _fetchCurrentLocation();
    
    return lastLocation ?? LocationService.defaultLocation;
  }

  Future<void> _fetchCurrentLocation() async {
    // We do not set loading state here if we already have a cached value, to prevent UI flickering.
    // If we have no cached value, we are technically loading from the default location which is fast.
    
    final result = await _locationService.getCurrentLocation();
    
    result.fold(
      (failure) {
        // If GPS fails, just stick to what we have (cached or default)
        final lastLocation = _storageService.getLastLocation();
        state = AsyncValue.data(lastLocation ?? LocationService.defaultLocation);
      },
      (location) {
        _storageService.saveLastLocation(location);
        state = AsyncValue.data(location);
      }
    );
  }

  Future<void> searchCity(String cityName) async {
    state = const AsyncValue.loading();
    final result = await _locationService.searchCity(cityName);
    
    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (location) {
        _storageService.saveLastLocation(location);
        ref.read(searchProvider.notifier).saveRecentCity(location);
        state = AsyncValue.data(location);
      }
    );
  }
}
