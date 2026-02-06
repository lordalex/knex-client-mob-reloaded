/// Model representing a valet parking location in the KNEX system.
///
/// Named [ValetLocation] to avoid conflicts with `dart:ui` and the `location`
/// package, both of which export a `Location` class.
///
/// The [rawData] map contains all additional fields returned by the API
/// including coordinates, company info, photos, bio, pricing, and contact
/// details. Convenience getters are provided for the most commonly accessed
/// fields.
class ValetLocation {
  final String id;
  final String name;
  final String? address;
  final Map<String, dynamic> rawData;

  const ValetLocation({
    required this.id,
    required this.name,
    this.address,
    this.rawData = const {},
  });

  // ---------------------------------------------------------------------------
  // Convenience getters for commonly used rawData fields
  // ---------------------------------------------------------------------------

  /// Latitude from the rawData coordinates, if available.
  double? get latitude {
    final coords = rawData['coordinates'];
    if (coords is Map) {
      return _toDouble(coords['lat'] ?? coords['latitude']);
    }
    return _toDouble(rawData['lat'] ?? rawData['latitude']);
  }

  /// Longitude from the rawData coordinates, if available.
  double? get longitude {
    final coords = rawData['coordinates'];
    if (coords is Map) {
      return _toDouble(coords['lng'] ?? coords['longitude']);
    }
    return _toDouble(rawData['lng'] ?? rawData['longitude']);
  }

  /// Company name associated with this location.
  ///
  /// The API may return `company` as a String or as a Map with a `name` key.
  String? get company {
    final raw = rawData['company'];
    if (raw is String) return raw;
    if (raw is Map) return raw['name'] as String?;
    return rawData['companyId'] as String?;
  }

  /// Contact phone number for this location.
  ///
  /// Falls back to checking `phoneNumber` key if `phone` is absent.
  String? get phone {
    final raw = rawData['phone'] ?? rawData['phoneNumber'];
    if (raw is String) return raw;
    return null;
  }

  /// Price for valet service at this location.
  double? get price => _toDouble(rawData['value'] ?? rawData['price']);

  /// Currency code for the price (e.g. "USD").
  String? get currency => rawData['currency'] as String?;

  /// Bio or description of this location.
  String? get bio => rawData['bio'] as String?;

  /// List of photo URLs for this location.
  List<String> get photos {
    final raw = rawData['photos'];
    if (raw is List) {
      return raw.whereType<String>().toList();
    }
    return [];
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Creates a [ValetLocation] from a JSON map.
  ///
  /// The entire JSON map is stored as [rawData] for access to dynamic fields.
  /// Top-level `id`, `name`, and `address` are extracted as typed fields.
  factory ValetLocation.fromJson(Map<String, dynamic> json) {
    return ValetLocation(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      address: json['address'] as String?,
      rawData: json,
    );
  }

  /// Serializes this location to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (address != null) 'address': address,
      ...rawData,
    };
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  String toString() {
    return 'ValetLocation(id: $id, name: $name, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValetLocation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
