import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/location_entity.dart';

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

class SearchState {
  final List<LocationEntity> recentCities;
  final List<LocationEntity> favoriteCities;

  SearchState({
    required this.recentCities,
    required this.favoriteCities,
  });

  SearchState copyWith({
    List<LocationEntity>? recentCities,
    List<LocationEntity>? favoriteCities,
  }) {
    return SearchState(
      recentCities: recentCities ?? this.recentCities,
      favoriteCities: favoriteCities ?? this.favoriteCities,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  late final StorageService _storageService;

  SearchNotifier() : super(SearchState(recentCities: [], favoriteCities: [])) {
    _storageService = sl<StorageService>();
    loadData();
  }

  void loadData() {
    state = state.copyWith(
      recentCities: _storageService.getRecentCities(),
      favoriteCities: _storageService.getFavoriteCities(),
    );
  }

  Future<void> saveRecentCity(LocationEntity city) async {
    await _storageService.saveRecentCity(city);
    loadData();
  }

  Future<void> toggleFavoriteCity(LocationEntity city) async {
    await _storageService.toggleFavoriteCity(city);
    loadData();
  }
  
  bool isFavorite(LocationEntity city) {
    return state.favoriteCities.any((c) => c.cityName == city.cityName);
  }
}
