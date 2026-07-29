import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/settings_entity.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsEntity>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsEntity> {
  late final StorageService _storageService;

  SettingsNotifier() : super(const SettingsEntity()) {
    _storageService = sl<StorageService>();
    _loadSettings();
  }

  void _loadSettings() {
    final data = _storageService.getSettings();
    if (data != null) {
      state = SettingsEntity.fromJson(data);
    }
  }

  Future<void> updateSettings(SettingsEntity newSettings) async {
    state = newSettings;
    await _storageService.saveSettings(newSettings.toJson());
  }

  Future<void> clearCache() async {
    // For now this is just a mockup operation since Hive is our main store.
    // We could clear recent searches here if desired.
    await Future.delayed(const Duration(seconds: 1));
  }
}
