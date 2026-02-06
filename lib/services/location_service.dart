import 'dart:developer' as developer;

import 'package:location/location.dart';

/// Service for accessing the device's GPS location.
///
/// Wraps the `location` package and handles permission requests.
class LocationService {
  final Location _location = Location();

  /// Attempts to get the user's current GPS coordinates.
  ///
  /// Returns a record of (latitude, longitude) on success, or null if location
  /// services are unavailable or permissions were denied.
  Future<(double, double)?> getCurrentLocation() async {
    try {
      var serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return null;
      }

      var permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission == PermissionStatus.denied ||
            permission == PermissionStatus.deniedForever) {
          return null;
        }
      }

      if (permission == PermissionStatus.deniedForever) {
        return null;
      }

      final locationData = await _location.getLocation();
      final lat = locationData.latitude;
      final lng = locationData.longitude;

      if (lat != null && lng != null) {
        return (lat, lng);
      }
      return null;
    } catch (e) {
      developer.log('Failed to get location: $e', name: 'LocationService');
      return null;
    }
  }

  /// Checks whether location permissions have been granted.
  Future<bool> hasPermission() async {
    try {
      final permission = await _location.hasPermission();
      return permission == PermissionStatus.granted ||
          permission == PermissionStatus.grantedLimited;
    } catch (e) {
      developer.log(
        'Failed to check permission: $e',
        name: 'LocationService',
      );
      return false;
    }
  }

  /// Requests location permissions from the user.
  Future<bool> requestPermission() async {
    try {
      final permission = await _location.requestPermission();
      return permission == PermissionStatus.granted ||
          permission == PermissionStatus.grantedLimited;
    } catch (e) {
      developer.log(
        'Failed to request permission: $e',
        name: 'LocationService',
      );
      return false;
    }
  }
}
