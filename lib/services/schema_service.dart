import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../config/app_constants.dart';

/// Service for fetching and parsing the OpenAPI schema that determines which
/// profile fields are required.
///
/// The schema is hosted in the **knex-attendant-25** Firebase project (not the
/// client project) at:
/// `https://storage.googleapis.com/knex-attendant-25.firebasestorage.app/client_openapi.json`
///
/// The FlowManager uses this schema to decide whether a user's profile is
/// complete, and the ProfileCreateScreen uses it to determine which form
/// fields to show and mark as required.
class SchemaService {
  /// Fetches the OpenAPI schema JSON from Firebase Storage.
  ///
  /// Uses a standalone Dio instance (no auth interceptor needed).
  /// Returns the parsed schema map on success, or null on failure.
  Future<Map<String, dynamic>?> fetchSchema() async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(
            milliseconds: AppConstants.connectTimeoutMs,
          ),
          receiveTimeout: const Duration(
            milliseconds: AppConstants.receiveTimeoutMs,
          ),
        ),
      );
      final response = await dio.get<Map<String, dynamic>>(
        AppConstants.schemaUrl,
      );
      return response.data;
    } catch (e) {
      developer.log('Failed to fetch schema: $e', name: 'SchemaService');
      return null;
    }
  }

  /// Extracts the list of required field names from the fetched schema.
  ///
  /// Parses the OpenAPI schema structure to find the `required` array for the
  /// user client profile definition at:
  /// `schema['components']['schemas']['UserClient']['required']`
  List<String> getRequiredFields(Map<String, dynamic> schema) {
    try {
      final components = schema['components'] as Map<String, dynamic>?;
      if (components == null) return [];

      final schemas = components['schemas'] as Map<String, dynamic>?;
      if (schemas == null) return [];

      final userClient = schemas['UserClient'] as Map<String, dynamic>?;
      if (userClient == null) return [];

      final required = userClient['required'];
      if (required is List) {
        return required.cast<String>();
      }
      return [];
    } catch (e) {
      developer.log(
        'Failed to parse required fields: $e',
        name: 'SchemaService',
      );
      return [];
    }
  }

  /// Checks whether a user profile has all required fields populated based on
  /// the schema.
  bool isProfileComplete(
    Map<String, dynamic> profileJson,
    List<String> requiredFields,
  ) {
    for (final field in requiredFields) {
      final value = profileJson[field];
      if (value == null || (value is String && value.isEmpty)) {
        return false;
      }
    }
    return true;
  }
}
