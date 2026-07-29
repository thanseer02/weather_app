import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/weather/domain/entities/location_entity.dart';

class StorageService {
  static const String boxName = 'app_settings';
  static const String lastLocationKey = 'last_location';
  static const String recentCitiesKey = 'recent_cities';
  static const String favoriteCitiesKey = 'favorite_cities';

  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(boxName);
  }

  Future<void> saveLastLocation(LocationEntity location) async {
    await _box.put(lastLocationKey, jsonEncode(location.toJson()));
  }

  LocationEntity? getLastLocation() {
    final data = _box.get(lastLocationKey);
    if (data != null) {
      return LocationEntity.fromJson(jsonDecode(data));
    }
    return null;
  }

  // --- Recent Cities ---

  Future<void> saveRecentCity(LocationEntity location) async {
    final recents = getRecentCities();
    // Remove if exists to move it to the top
    recents.removeWhere((c) => c.cityName == location.cityName);
    recents.insert(0, location);
    // Keep only top 10
    if (recents.length > 10) {
      recents.removeLast();
    }
    final jsonList = recents.map((e) => jsonEncode(e.toJson())).toList();
    await _box.put(recentCitiesKey, jsonList);
  }

  List<LocationEntity> getRecentCities() {
    final data = _box.get(recentCitiesKey) as List<dynamic>?;
    if (data == null) return [];
    return data.map((e) => LocationEntity.fromJson(jsonDecode(e.toString()))).toList();
  }

  // --- Favorite Cities ---

  Future<void> toggleFavoriteCity(LocationEntity location) async {
    final favorites = getFavoriteCities();
    final index = favorites.indexWhere((c) => c.cityName == location.cityName);
    
    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.add(location);
    }
    
    final jsonList = favorites.map((e) => jsonEncode(e.toJson())).toList();
    await _box.put(favoriteCitiesKey, jsonList);
  }

  List<LocationEntity> getFavoriteCities() {
    final data = _box.get(favoriteCitiesKey) as List<dynamic>?;
    if (data == null) return [];
    return data.map((e) => LocationEntity.fromJson(jsonDecode(e.toString()))).toList();
  }
}
