/// Model representing a vehicle in the KNEX system.
///
/// The backend API uses snake_case keys for vehicle fields (e.g.
/// `vehicle_make`, `license_plate`). The [fromJson] and [toJson] methods
/// handle this conversion.
class Vehicle {
  final String? id;
  final String? userClientId;
  final String vehicleMake;
  final String vehicleModel;
  final String? vehicleYear;
  final String licensePlate;
  final String color;
  final String? vin;

  const Vehicle({
    this.id,
    this.userClientId,
    required this.vehicleMake,
    required this.vehicleModel,
    this.vehicleYear,
    required this.licensePlate,
    required this.color,
    this.vin,
  });

  /// Creates a [Vehicle] from a JSON map with snake_case keys.
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String?,
      userClientId: json['user_client_id'] as String?,
      vehicleMake: (json['vehicle_make'] as String?) ?? '',
      vehicleModel: (json['vehicle_model'] as String?) ?? '',
      vehicleYear: json['vehicle_year'] as String?,
      licensePlate: (json['license_plate'] as String?) ?? '',
      color: (json['color'] as String?) ?? '',
      vin: json['vin'] as String?,
    );
  }

  /// Serializes this vehicle to a JSON map with snake_case keys.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userClientId != null) 'user_client_id': userClientId,
      'vehicle_make': vehicleMake,
      'vehicle_model': vehicleModel,
      if (vehicleYear != null) 'vehicle_year': vehicleYear,
      'license_plate': licensePlate,
      'color': color,
      if (vin != null) 'vin': vin,
    };
  }

  /// Returns a new [Vehicle] with the given fields replaced.
  Vehicle copyWith({
    String? id,
    String? userClientId,
    String? vehicleMake,
    String? vehicleModel,
    String? vehicleYear,
    String? licensePlate,
    String? color,
    String? vin,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userClientId: userClientId ?? this.userClientId,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      licensePlate: licensePlate ?? this.licensePlate,
      color: color ?? this.color,
      vin: vin ?? this.vin,
    );
  }

  @override
  String toString() {
    return 'Vehicle(id: $id, make: $vehicleMake, model: $vehicleModel, '
        'plate: $licensePlate, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vehicle &&
        other.id == id &&
        other.userClientId == userClientId &&
        other.vehicleMake == vehicleMake &&
        other.vehicleModel == vehicleModel &&
        other.vehicleYear == vehicleYear &&
        other.licensePlate == licensePlate &&
        other.color == color &&
        other.vin == vin;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userClientId,
      vehicleMake,
      vehicleModel,
      vehicleYear,
      licensePlate,
      color,
      vin,
    );
  }
}
