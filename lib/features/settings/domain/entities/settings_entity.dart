enum TemperatureUnit { celsius, fahrenheit, kelvin }
enum WindUnit { ms, kmh, mph }
enum PressureUnit { hpa, inhg }
enum ThemeModeType { light, dark, system }
enum AnimationQuality { low, medium, high }

class SettingsEntity {
  final ThemeModeType themeMode;
  final TemperatureUnit temperatureUnit;
  final WindUnit windUnit;
  final PressureUnit pressureUnit;
  final bool notificationsEnabled;
  final AnimationQuality animationQuality;
  final String language;

  const SettingsEntity({
    this.themeMode = ThemeModeType.system,
    this.temperatureUnit = TemperatureUnit.celsius,
    this.windUnit = WindUnit.kmh,
    this.pressureUnit = PressureUnit.hpa,
    this.notificationsEnabled = false,
    this.animationQuality = AnimationQuality.high,
    this.language = 'en',
  });

  SettingsEntity copyWith({
    ThemeModeType? themeMode,
    TemperatureUnit? temperatureUnit,
    WindUnit? windUnit,
    PressureUnit? pressureUnit,
    bool? notificationsEnabled,
    AnimationQuality? animationQuality,
    String? language,
  }) {
    return SettingsEntity(
      themeMode: themeMode ?? this.themeMode,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      windUnit: windUnit ?? this.windUnit,
      pressureUnit: pressureUnit ?? this.pressureUnit,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      animationQuality: animationQuality ?? this.animationQuality,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'temperatureUnit': temperatureUnit.name,
      'windUnit': windUnit.name,
      'pressureUnit': pressureUnit.name,
      'notificationsEnabled': notificationsEnabled,
      'animationQuality': animationQuality.name,
      'language': language,
    };
  }

  factory SettingsEntity.fromJson(Map<String, dynamic> json) {
    return SettingsEntity(
      themeMode: ThemeModeType.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ThemeModeType.system,
      ),
      temperatureUnit: TemperatureUnit.values.firstWhere(
        (e) => e.name == json['temperatureUnit'],
        orElse: () => TemperatureUnit.celsius,
      ),
      windUnit: WindUnit.values.firstWhere(
        (e) => e.name == json['windUnit'],
        orElse: () => WindUnit.kmh,
      ),
      pressureUnit: PressureUnit.values.firstWhere(
        (e) => e.name == json['pressureUnit'],
        orElse: () => PressureUnit.hpa,
      ),
      notificationsEnabled: json['notificationsEnabled'] ?? false,
      animationQuality: AnimationQuality.values.firstWhere(
        (e) => e.name == json['animationQuality'],
        orElse: () => AnimationQuality.high,
      ),
      language: json['language'] ?? 'en',
    );
  }
}
