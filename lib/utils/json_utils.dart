import 'dart:convert';

/// Convenience helpers for working with JSON strings.
///
/// These utilities are used throughout the app for quick JSON parsing
/// operations where full model deserialization is unnecessary.
class JsonUtils {
  JsonUtils._();

  /// Extracts a single value from a JSON-encoded string by [key].
  ///
  /// Returns `null` if the key does not exist. Throws [FormatException]
  /// if [jsonString] is not valid JSON.
  static dynamic getKeyFromJsonString(String jsonString, String key) {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return map[key];
  }

  /// Parses a JSON array string into a `List<String>`.
  ///
  /// Each element is converted to a string via [Object.toString].
  /// Throws [FormatException] if [jsonString] is not a valid JSON array.
  static List<String> jsonToArray(String jsonString) {
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list.map((e) => e.toString()).toList();
  }

  /// Safely attempts to decode a JSON string, returning `null` on failure.
  static Map<String, dynamic>? tryDecode(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } on FormatException {
      return null;
    }
  }
}
