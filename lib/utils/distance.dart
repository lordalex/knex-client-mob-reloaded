import 'dart:math';

/// Calculates the distance between two GPS coordinates using the Haversine
/// formula and returns a human-readable formatted string.
///
/// [lat1], [lon1]: Latitude and longitude of the first point (in degrees).
/// [lat2], [lon2]: Latitude and longitude of the second point (in degrees).
/// [unit]: Either `'mi'` for miles or `'km'` for kilometers.
///
/// Returns a string like `"2.3 mi"` or `"3.7 km"`.
String calculateDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
  String unit,
) {
  const double earthRadiusKm = 6371.0;
  const double kmPerMile = 1.60934;

  final dLat = _degreesToRadians(lat2 - lat1);
  final dLon = _degreesToRadians(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final distanceKm = earthRadiusKm * c;

  if (unit == 'mi') {
    final distanceMi = distanceKm / kmPerMile;
    return '${distanceMi.toStringAsFixed(1)} mi';
  }

  return '${distanceKm.toStringAsFixed(1)} km';
}

double _degreesToRadians(double degrees) => degrees * pi / 180;
