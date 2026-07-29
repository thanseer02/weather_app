import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final double lat;
  final double lon;
  final String cityName;

  const LocationEntity({
    required this.lat,
    required this.lon,
    required this.cityName,
  });

  factory LocationEntity.fromJson(Map<String, dynamic> json) {
    return LocationEntity(
      lat: json['lat'] as double,
      lon: json['lon'] as double,
      cityName: json['cityName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
      'cityName': cityName,
    };
  }

  @override
  List<Object?> get props => [lat, lon, cityName];
}
