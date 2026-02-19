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
///
/// Extends [QueuedInterceptor] so that when a 401 occurs, all pending
/// requests are queued while a single token refresh takes place. After
/// refresh, the original request is retried automatically.
class AuthInterceptor extends QueuedInterceptor {
  /// Callback that returns the current Firebase JWT token (or null).
  final String? Function() tokenGetter;

  /// Async callback that force-refreshes the Firebase token and returns the
  /// new JWT string (or null if the user is signed out).
  final Future<String?> Function() tokenRefresher;

  /// Callback to persist the refreshed token in ApiClient + Riverpod state.
  final void Function(String?) tokenSetter;

  AuthInterceptor({
    required this.tokenGetter,
    required this.tokenRefresher,
    required this.tokenSetter,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenGetter();
    _wrapWithToken(options, token);
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only attempt refresh on 401 (expired token) responses.
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    developer.log(
      'Got 401 on ${err.requestOptions.path} — refreshing Firebase token…',
      name: 'AuthInterceptor',
    );

    try {
      final newToken = await tokenRefresher();

      if (newToken == null || newToken.isEmpty) {
        // User is signed out; nothing to retry.
        developer.log('Token refresh returned null — user signed out',
            name: 'AuthInterceptor');
        handler.next(err);
        return;
      }

      // Persist the refreshed token so all subsequent requests use it.
      tokenSetter(newToken);

      // Rebuild the original request with the new token.
      final opts = err.requestOptions;
      // Restore the original data (unwrap the previous envelope).
      final previousData = opts.data;
      dynamic originalData;
      if (previousData is Map<String, dynamic> &&
          previousData.containsKey('idToken') &&
          previousData.containsKey('data')) {
        originalData = previousData['data'];
      } else {
        originalData = previousData;
      }

      // Re-wrap with the fresh token.
      opts.data = originalData;
      _wrapWithToken(opts, newToken);

      developer.log('Retrying ${opts.path} with refreshed token',
          name: 'AuthInterceptor');

      // Retry the request through the same Dio instance.
      final dio = Dio(BaseOptions(
        baseUrl: opts.baseUrl,
        connectTimeout: opts.connectTimeout,
        receiveTimeout: opts.receiveTimeout,
        contentType: opts.contentType,
        responseType: opts.responseType,
      ));
      final response = await dio.request(
        opts.path,
        data: opts.data,
        queryParameters: opts.queryParameters,
        options: Options(
          method: opts.method,
          headers: opts.headers,
        ),
      );

      handler.resolve(response);
    } catch (e) {
      developer.log('Token refresh / retry failed: $e',
          name: 'AuthInterceptor');
      handler.next(err);
    }
  }

  /// Wraps [options.data] in the `{ idToken, data }` envelope.
  void _wrapWithToken(RequestOptions options, String? token) {
    if (token != null && token.isNotEmpty) {
      final originalData = options.data;

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
        options.data = {
          'idToken': token,
          'data': originalData,
        };
      }
    }
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
