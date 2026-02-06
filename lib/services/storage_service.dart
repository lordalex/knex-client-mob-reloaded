import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Typed wrapper around [SharedPreferences] for local key-value persistence.
///
/// Call [init] once during app startup before using any other methods.
/// Provides convenience methods for common types including JSON objects.
class StorageService {
  late SharedPreferences _prefs;

  /// Initializes the underlying SharedPreferences instance.
  ///
  /// Must be called (and awaited) before any get/set operations.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ---------------------------------------------------------------------------
  // Bool
  // ---------------------------------------------------------------------------

  /// Returns the boolean value for [key], or [defaultValue] if not found.
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  /// Persists a boolean [value] for [key].
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  // ---------------------------------------------------------------------------
  // String
  // ---------------------------------------------------------------------------

  /// Returns the string value for [key], or [defaultValue] if not found.
  String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  /// Persists a string [value] for [key].
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  // ---------------------------------------------------------------------------
  // Int
  // ---------------------------------------------------------------------------

  /// Returns the int value for [key], or [defaultValue] if not found.
  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  /// Persists an int [value] for [key].
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  // ---------------------------------------------------------------------------
  // Double
  // ---------------------------------------------------------------------------

  /// Returns the double value for [key], or [defaultValue] if not found.
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  /// Persists a double [value] for [key].
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  // ---------------------------------------------------------------------------
  // String List
  // ---------------------------------------------------------------------------

  /// Returns the string list for [key], or an empty list if not found.
  List<String> getStringList(String key) {
    return _prefs.getStringList(key) ?? [];
  }

  /// Persists a string list [value] for [key].
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  // ---------------------------------------------------------------------------
  // JSON Object
  // ---------------------------------------------------------------------------

  /// Returns a deserialized JSON map for [key], or null if not found or
  /// if the stored value is not valid JSON.
  Map<String, dynamic>? getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Persists a JSON-encodable map [value] for [key].
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  // ---------------------------------------------------------------------------
  // Removal
  // ---------------------------------------------------------------------------

  /// Removes the entry for [key].
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  /// Removes all entries from SharedPreferences.
  Future<void> clear() async {
    await _prefs.clear();
  }

  /// Whether the store contains a value for [key].
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}
