import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/app_constants.dart';
import '../../models/api_response.dart';
import 'api_interceptors.dart';

/// HTTP client for the KNEX backend API, built on top of [Dio].
///
/// All KNEX endpoints are POST-only. The [AuthInterceptor] automatically wraps
/// request payloads with the current Firebase JWT token. Errors are normalized
/// by [ErrorInterceptor] and requests are logged in debug mode by
/// [LoggingInterceptor].
///
/// Usage:
/// ```dart
/// final client = ApiClient();
/// client.setAuthToken(firebaseJwt);
///
/// final response = await client.post<UserClientProfile>(
///   Endpoints.searchUserClient,
///   data: {'email': 'user@example.com'},
///   fromData: (json) => UserClientProfile.fromJson(json),
/// );
/// ```
class ApiClient {
  late final Dio _dio;
  String? _authToken;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(tokenGetter: () => _authToken),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  /// Updates the auth token used for subsequent requests.
  ///
  /// Pass `null` to clear the token (e.g. on sign-out).
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// The current auth token, if set.
  String? get authToken => _authToken;

  /// Sends a POST request to [endpoint] and parses the response into an
  /// [ApiResponse<T>].
  ///
  /// [data] is the request payload (will be wrapped by [AuthInterceptor]).
  /// [fromData] is an optional factory to transform the response `data` field
  /// into a typed [T].
  ///
  /// Returns an [ApiResponse.error] on network or parsing failures rather than
  /// throwing, so callers can handle errors uniformly.
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    T Function(dynamic)? fromData,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        endpoint,
        data: data ?? <String, dynamic>{},
      );

      final raw = response.data;
      if (raw == null) {
        return ApiResponse<T>.error('Empty response from server');
      }

      // The standard envelope is a Map with `status` + `data` keys.
      if (raw is Map<String, dynamic>) {
        debugPrint('[ApiClient] Response on $endpoint: keys=${raw.keys.toList()}, '
            'status type=${raw['status']?.runtimeType}, '
            'data type=${raw['data']?.runtimeType}');

        // The backend uses two envelope formats:
        // 1. Legacy: { "status": { "status": "success", ... }, "data": ... }
        // 2. Current: { "success": true/false, "data": ..., "endpoint": ..., ... }
        // Detect format 2 and normalize into format 1 for downstream parsing.
        if (raw.containsKey('success') && raw.containsKey('data') &&
            !raw.containsKey('status')) {
          final isSuccess = raw['success'] == true;
          final innerData = raw['data'];
          debugPrint('[ApiClient] Detected {success, data} envelope on $endpoint: '
              'success=$isSuccess, innerData type=${innerData?.runtimeType}');

          if (fromData != null && innerData != null) {
            try {
              final parsed = fromData(innerData);
              return ApiResponse<T>(
                status: ApiStatus(
                  status: isSuccess ? 'success' : 'error',
                  result: isSuccess ? 'READ' : 'ERROR',
                ),
                data: parsed,
              );
            } catch (e) {
              debugPrint('[ApiClient] fromData threw on $endpoint: $e');
              // If parsing fails (e.g. empty list), return success with no data
              return ApiResponse<T>(
                status: ApiStatus(
                  status: isSuccess ? 'success' : 'error',
                  result: isSuccess ? 'READ' : 'ERROR',
                ),
              );
            }
          }

          return ApiResponse<T>(
            status: ApiStatus(
              status: isSuccess ? 'success' : 'error',
              result: isSuccess ? 'READ' : 'ERROR',
            ),
          );
        }

        // Some endpoints return a raw Map without any envelope.
        if (!raw.containsKey('status') && fromData != null) {
          debugPrint('[ApiClient] Non-envelope map on $endpoint, treating as raw data');
          try {
            final parsed = fromData(raw);
            return ApiResponse<T>(
              status: const ApiStatus(status: 'success', result: 'CREATE'),
              data: parsed,
            );
          } catch (e) {
            return ApiResponse<T>.error('Failed to parse response: $e');
          }
        }

        return ApiResponse<T>.fromJson(raw, fromData);
      }

      // Some endpoints return a raw list or other non-envelope format.
      // Wrap it in a synthetic success envelope so fromData can parse it.
      debugPrint('[ApiClient] Non-map response on $endpoint: ${raw.runtimeType}');
      if (fromData != null) {
        try {
          final parsed = fromData(raw);
          return ApiResponse<T>(
            status: const ApiStatus(status: 'success', result: 'READ'),
            data: parsed,
          );
        } catch (e) {
          return ApiResponse<T>.error('Failed to parse response: $e');
        }
      }

      return ApiResponse<T>.error('Unexpected response format');
    } on DioException catch (e) {
      debugPrint('[ApiClient] DioException on $endpoint: '
          'type=${e.type}, statusCode=${e.response?.statusCode}, '
          'message=${e.message}, '
          'responseData=${e.response?.data}');

      // Attempt to parse a structured error response from the server.
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('status')) {
        return ApiResponse<T>.fromJson(responseData, fromData);
      }

      return ApiResponse<T>.error(
        e.message ?? 'An unexpected network error occurred.',
      );
    } catch (e) {
      debugPrint('[ApiClient] Unexpected error on $endpoint: $e');
      return ApiResponse<T>.error('An unexpected error occurred: $e');
    }
  }

  /// Sends a raw POST request without the [ApiResponse] envelope parsing.
  ///
  /// Useful for endpoints that return non-standard response shapes (e.g.
  /// provisional ticket endpoints or external APIs).
  Future<Response<dynamic>> postRaw(
    String endpoint, {
    Map<String, dynamic>? data,
  }) {
    return _dio.post(
      endpoint,
      data: data ?? <String, dynamic>{},
    );
  }
}
