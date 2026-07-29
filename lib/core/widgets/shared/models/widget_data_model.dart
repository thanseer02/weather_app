class WidgetDataModel {
  final String cityName;
  final double temperature;
  final String condition;
  final String iconCode;
  final DateTime lastUpdated;
  final double tempMin;
  final double tempMax;

  WidgetDataModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.lastUpdated,
    required this.tempMin,
    required this.tempMax,
  });

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'condition': condition,
      'iconCode': iconCode,
      'lastUpdated': lastUpdated.toIso8601String(),
      'tempMin': tempMin,
      'tempMax': tempMax,
    };
  }

  factory WidgetDataModel.fromJson(Map<String, dynamic> json) {
    return WidgetDataModel(
      cityName: json['cityName'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      iconCode: json['iconCode'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      tempMin: (json['tempMin'] as num).toDouble(),
      tempMax: (json['tempMax'] as num).toDouble(),
    );
  }
}
