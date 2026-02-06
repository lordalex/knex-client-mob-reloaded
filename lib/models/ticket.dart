/// Model representing a valet parking ticket in the KNEX system.
///
/// The backend API uses snake_case keys for ticket fields (e.g.
/// `ticket_number`, `user_client_id`). The [fromJson] and [toJson] methods
/// handle this conversion.
class Ticket {
  final String? id;
  final String? ticketNumber;
  final String userClientId;
  final String vehicleId;
  final String status;
  final String locationId;
  final String? notes;
  final String? pin;
  final double? tip;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Ticket({
    this.id,
    this.ticketNumber,
    required this.userClientId,
    required this.vehicleId,
    required this.status,
    required this.locationId,
    this.notes,
    this.pin,
    this.tip,
    this.createdAt,
    this.updatedAt,
  });

  /// Known ticket status values.
  static const String statusPending = 'Pending';
  static const String statusAccepted = 'Accepted';
  static const String statusInProgress = 'InProgress';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';

  /// Whether this ticket is in an active state (not completed or cancelled).
  bool get isActive =>
      status != statusCompleted && status != statusCancelled;

  /// Creates a [Ticket] from a JSON map with snake_case keys.
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String?,
      ticketNumber: json['ticket_number'] as String?,
      userClientId: (json['user_client_id'] as String?) ?? '',
      vehicleId: (json['vehicle_id'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      locationId: (json['location_id'] as String?) ?? '',
      notes: json['notes'] as String?,
      pin: json['pin'] as String?,
      tip: _parseDouble(json['tip']),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }

  /// Serializes this ticket to a JSON map with snake_case keys.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (ticketNumber != null) 'ticket_number': ticketNumber,
      'user_client_id': userClientId,
      'vehicle_id': vehicleId,
      'status': status,
      'location_id': locationId,
      if (notes != null) 'notes': notes,
      if (pin != null) 'pin': pin,
      if (tip != null) 'tip': tip,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Returns a new [Ticket] with the given fields replaced.
  Ticket copyWith({
    String? id,
    String? ticketNumber,
    String? userClientId,
    String? vehicleId,
    String? status,
    String? locationId,
    String? notes,
    String? pin,
    double? tip,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ticket(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      userClientId: userClientId ?? this.userClientId,
      vehicleId: vehicleId ?? this.vehicleId,
      status: status ?? this.status,
      locationId: locationId ?? this.locationId,
      notes: notes ?? this.notes,
      pin: pin ?? this.pin,
      tip: tip ?? this.tip,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  @override
  String toString() {
    return 'Ticket(id: $id, number: $ticketNumber, status: $status, '
        'locationId: $locationId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ticket &&
        other.id == id &&
        other.ticketNumber == ticketNumber &&
        other.userClientId == userClientId &&
        other.vehicleId == vehicleId &&
        other.status == status &&
        other.locationId == locationId &&
        other.pin == pin &&
        other.tip == tip;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      ticketNumber,
      userClientId,
      vehicleId,
      status,
      locationId,
      pin,
      tip,
    );
  }
}
