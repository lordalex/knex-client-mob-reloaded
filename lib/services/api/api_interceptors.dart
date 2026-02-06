import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dio interceptor that wraps every outgoing request with the Firebase JWT
/// token in the format expected by the KNEX backend:
///
/// ```json
/// { "idToken": "<token>", "data": <originalPayload> }
/// ```
///
/// If no token is available (the [tokenGetter] returns null or empty), the
/// request data is sent through unmodified. This allows provisional/public
/// endpoints to work without authentication.
class AuthInterceptor extends Interceptor {
  /// Callback that returns the current Firebase JWT token (or null).
  final String? Function() tokenGetter;

  AuthInterceptor({required this.tokenGetter});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenGetter();

    if (token != null && token.isNotEmpty) {
      final originalData = options.data;

      // Wrap the payload in the expected envelope.
      if (originalData is Map<String, dynamic>) {
        options.data = {
          'idToken': token,
          'data': originalData,
        };
      } else if (originalData == null) {
        options.data = {
          'idToken': token,
          'data': <String, dynamic>{},
        };
      } else {
        // For non-Map payloads, wrap them as-is.
        options.data = {
          'idToken': token,
          'data': originalData,
        };
      }
    }

    handler.next(options);
  }
}

/// Dio interceptor that normalizes error responses into a consistent format
/// and logs errors for diagnostics.
///
/// Handles common HTTP status codes (401, 500) and Dio-specific error types
/// (timeouts, connection errors) with user-friendly messages.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final String friendlyMessage;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        friendlyMessage = 'Request timed out. Please check your connection '
            'and try again.';
      case DioExceptionType.connectionError:
        friendlyMessage = 'Unable to connect to the server. Please check '
            'your internet connection.';
      case DioExceptionType.badResponse:
        friendlyMessage = _handleStatusCode(err.response?.statusCode);
      case DioExceptionType.cancel:
        friendlyMessage = 'Request was cancelled.';
      case DioExceptionType.badCertificate:
        friendlyMessage = 'Security certificate error. Please try again later.';
      case DioExceptionType.unknown:
        friendlyMessage = 'An unexpected error occurred. Please try again.';
    }

    developer.log(
      'API Error: ${err.requestOptions.path} - $friendlyMessage',
      name: 'ErrorInterceptor',
      error: err,
    );

    // Replace the error with a friendlier message while preserving the
    // original response data for callers that need it.
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: err.error,
        message: friendlyMessage,
      ),
    );
  }

  String _handleStatusCode(int? statusCode) {
    return switch (statusCode) {
      401 => 'Your session has expired. Please sign in again.',
      403 => 'You do not have permission to perform this action.',
      404 => 'The requested resource was not found.',
      500 => 'The server encountered an error. Please try again later.',
      502 || 503 || 504 =>
        'The server is temporarily unavailable. Please try again later.',
      _ => 'Request failed with status $statusCode.',
    };
  }
}

/// Dio interceptor that logs request and response details in debug mode only.
///
/// Logs are written using `dart:developer` log so they appear in the IDE
/// console without polluting release builds.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '--> ${options.method} ${options.path}',
        name: 'ApiClient',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '<-- ${response.statusCode} ${response.requestOptions.path}',
        name: 'ApiClient',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '<-- ERROR ${err.response?.statusCode ?? 'N/A'} '
        '${err.requestOptions.path}: ${err.message}',
        name: 'ApiClient',
      );
    }
    handler.next(err);
  }
}
