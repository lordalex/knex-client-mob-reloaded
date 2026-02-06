/// Model representing a user client profile in the KNEX system.
///
/// The backend API is inconsistent with key casing -- it may return keys in
/// camelCase (e.g. `firstName`) or all-lowercase (e.g. `firstname`). The
/// [fromJson] factory handles both variants gracefully.
class UserClientProfile {
  final String? id;
  final String? uid;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? photo;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserClientProfile({
    this.id,
    this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.photo,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [UserClientProfile] from a JSON map.
  ///
  /// Handles both camelCase and lowercase key variants that the backend may
  /// return. For example, `firstName` or `firstname`, `phoneNumber` or `phone`.
  factory UserClientProfile.fromJson(Map<String, dynamic> json) {
    return UserClientProfile(
      id: json['id'] as String?,
      uid: json['uid'] as String?,
      email: (json['email'] as String?) ?? '',
      firstName:
          (json['firstName'] ?? json['firstname'] ?? '') as String,
      lastName:
          (json['lastName'] ?? json['lastname'] ?? '') as String,
      phoneNumber:
          (json['phoneNumber'] ?? json['phone'] ?? json['phonenumber'] ?? '')
              as String,
      photo: json['photo'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: (json['zipCode'] ?? json['zipcode']) as String?,
      createdAt: _parseDateTime(json['createdAt'] ?? json['createdat']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updatedat']),
    );
  }

  /// Serializes this profile to a JSON map using camelCase keys.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      if (photo != null) 'photo': photo,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (zipCode != null) 'zipCode': zipCode,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Returns a new [UserClientProfile] with the given fields replaced.
  UserClientProfile copyWith({
    String? id,
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? photo,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserClientProfile(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photo: photo ?? this.photo,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper to parse DateTime from various formats the backend may return.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  @override
  String toString() {
    return 'UserClientProfile(id: $id, email: $email, '
        'firstName: $firstName, lastName: $lastName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserClientProfile &&
        other.id == id &&
        other.uid == uid &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        other.photo == photo &&
        other.address == address &&
        other.city == city &&
        other.state == state &&
        other.zipCode == zipCode;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      uid,
      email,
      firstName,
      lastName,
      phoneNumber,
      photo,
      address,
      city,
      state,
      zipCode,
    );
  }
}
