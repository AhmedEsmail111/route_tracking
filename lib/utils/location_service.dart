import 'package:location/location.dart';

class LocationService {
  final _location = Location();

  // check if the location service is enabled or not and request to activate if not enabled
  Future<void> checkAndRequestLocationService() async {
    var serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw LocationServiceException();
      }
    }
  }

  // check if the location permission is granted or not and request the user to give the permission if not
  Future<void> checkAndRequestLocationPermission() async {
    var permissionStatus = await _location.hasPermission();

    if (permissionStatus == PermissionStatus.deniedForever) {
      throw LocationPermissionException();
    }
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();

      if (permissionStatus != PermissionStatus.granted) {
        throw LocationPermissionException();
      }
    }
  }

  // listens to the user's location every second and sends new data if the user has moved at least two meeters
  Future<void> fetchLocationDataStream(
      void Function(LocationData)? onLocationUpdated) async {
    await checkAndRequestLocationService();
    await checkAndRequestLocationPermission();

    await _location.changeSettings(distanceFilter: 5);
    _location.onLocationChanged.listen(onLocationUpdated);
  }

  Future<LocationData> fetchCurrentUserLocation() async {
    await checkAndRequestLocationService();
    await checkAndRequestLocationPermission();

    return await _location.getLocation();
  }
}

class LocationServiceException implements Exception {}

class LocationPermissionException implements Exception {}
