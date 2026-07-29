import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fpdart/fpdart.dart';
import '../utils/error_handler.dart';
import '../../features/weather/domain/entities/location_entity.dart';

class LocationService {
  // Default fallback if permissions are denied entirely.
  static const LocationEntity defaultLocation = LocationEntity(
    lat: 51.5074, 
    lon: -0.1278, 
    cityName: 'London',
  );

  /// Checks and requests location permission.
  Future<Either<Failure, bool>> _handlePermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const Left(ServerFailure('Location services are disabled.'));
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const Left(ServerFailure('Location permissions are denied.'));
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const Left(ServerFailure('Location permissions are permanently denied, we cannot request permissions.'));
    }

    return const Right(true);
  }

  /// Gets current location and reverse geocodes it to a city name.
  Future<Either<Failure, LocationEntity>> getCurrentLocation() async {
    final permissionResult = await _handlePermissions();
    return permissionResult.fold(
      (failure) => Left(failure),
      (_) async {
        try {
          final Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          
          String city = 'Unknown Location';
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
            if (placemarks.isNotEmpty) {
              city = placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? 'Unknown Location';
            }
          } catch (e) {
            // Geocoding failed, but we still have coords
          }

          return Right(LocationEntity(
            lat: position.latitude,
            lon: position.longitude,
            cityName: city,
          ));
        } catch (e) {
          return const Left(ServerFailure('Failed to get current position.'));
        }
      }
    );
  }

  /// Forward Geocoding: City name to coordinates
  Future<Either<Failure, LocationEntity>> searchCity(String cityName) async {
    try {
      List<Location> locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        
        // Reverse geocode to get the formatted city name
        String formattedCity = cityName;
        try {
           List<Placemark> placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
           if (placemarks.isNotEmpty) {
              formattedCity = placemarks.first.locality ?? cityName;
           }
        } catch(e) {}

        return Right(LocationEntity(
          lat: loc.latitude,
          lon: loc.longitude,
          cityName: formattedCity,
        ));
      }
      return const Left(ServerFailure('City not found.'));
    } catch (e) {
      return const Left(ServerFailure('Failed to search city.'));
    }
  }
}
