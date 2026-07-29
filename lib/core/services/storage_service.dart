import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/weather/domain/entities/location_entity.dart';

class StorageService {
  static const String boxName = 'app_settings';
  static const String lastLocationKey = 'last_location';

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
}
