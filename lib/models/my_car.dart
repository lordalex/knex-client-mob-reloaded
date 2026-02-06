/// Lightweight model for a locally-persisted vehicle.
///
/// Used to remember the user's last-used car details across sessions via
/// SharedPreferences. Unlike [Vehicle], this model is not tied to a backend
/// record and contains only the minimal fields needed for quick re-use.
class MyCar {
  final String? make;
  final String? model;
  final String? color;
  final String? plate;
  final String? state;
  final String? notes;

  const MyCar({
    this.make,
    this.model,
    this.color,
    this.plate,
    this.state,
    this.notes,
  });

  /// Creates an empty [MyCar] with all fields null.
  factory MyCar.empty() => const MyCar();

  /// Whether this car has any meaningful data.
  bool get isEmpty =>
      make == null && model == null && color == null && plate == null;

  /// Whether this car has at least some data.
  bool get isNotEmpty => !isEmpty;

  /// Creates a [MyCar] from a JSON map.
  factory MyCar.fromJson(Map<String, dynamic> json) {
    return MyCar(
      make: json['make'] as String?,
      model: json['model'] as String?,
      color: json['color'] as String?,
      plate: json['plate'] as String?,
      state: json['state'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// Serializes this car to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'color': color,
      'plate': plate,
      'state': state,
      'notes': notes,
    };
  }

  /// Returns a new [MyCar] with the given fields replaced.
  MyCar copyWith({
    String? make,
    String? model,
    String? color,
    String? plate,
    String? state,
    String? notes,
  }) {
    return MyCar(
      make: make ?? this.make,
      model: model ?? this.model,
      color: color ?? this.color,
      plate: plate ?? this.plate,
      state: state ?? this.state,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() =>
      'MyCar(make: $make, model: $model, color: $color, plate: $plate, state: $state, notes: $notes)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyCar &&
        other.make == make &&
        other.model == model &&
        other.color == color &&
        other.plate == plate &&
        other.state == state &&
        other.notes == notes;
  }

  @override
  int get hashCode => Object.hash(make, model, color, plate, state, notes);
}
