class WidgetDataModel {
  final String cityName;
  final double temperature;
  final String condition;
  final String iconCode;
  final DateTime lastUpdated;

  WidgetDataModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'condition': condition,
      'iconCode': iconCode,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory WidgetDataModel.fromJson(Map<String, dynamic> json) {
    return WidgetDataModel(
      cityName: json['cityName'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      iconCode: json['iconCode'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
