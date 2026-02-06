/// Form field validators for use with [TextFormField.validator].
///
/// Each method returns `null` when valid or an error message string
/// when validation fails. These are designed to be composed:
///
/// ```dart
/// TextFormField(
///   validator: (v) => Validators.required(v, 'Email') ?? Validators.email(v),
/// )
/// ```
class Validators {
  Validators._();

  /// Validates that the value is not null or empty.
  /// Optionally includes [fieldName] in the error message.
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      final field = fieldName ?? 'This field';
      return '$field is required';
    }
    return null;
  }

  /// Validates that the value is a well-formed email address.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates that the value looks like a phone number.
  /// Accepts digits, spaces, dashes, parentheses, and an optional leading +.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Strip formatting characters for length check
    final digitsOnly = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return 'Enter a valid phone number';
    }
    if (!RegExp(r'^[\d\s\-\(\)\+]+$').hasMatch(value)) {
      return 'Phone number contains invalid characters';
    }
    return null;
  }

  /// Validates that the value has at least [min] characters.
  static String? minLength(String? value, int min) {
    if (value == null || value.length < min) {
      return 'Must be at least $min characters';
    }
    return null;
  }

  /// Validates that [value] matches [other] (for password confirmation).
  static String? passwordMatch(String? value, String? other) {
    if (value != other) {
      return 'Passwords do not match';
    }
    return null;
  }
}
