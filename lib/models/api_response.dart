/// Generic wrapper for KNEX API responses.
///
/// The backend returns responses in the shape:
/// ```json
/// {
///   "status": {
///     "status": "success" | "error",
///     "result": "...",
///     "message": "..."
///   },
///   "data": <dynamic>
/// }
/// ```
///
/// [ApiResponse] parses this envelope and optionally transforms the `data`
/// payload into a typed [T] using a provided factory function.
class ApiResponse<T> {
  final ApiStatus status;
  final T? data;

  const ApiResponse({
    required this.status,
    this.data,
  });

  /// Whether the API call was successful.
  ///
  /// The backend may return `"success"` or `"VALID"` as the status string.
  bool get isSuccess {
    final s = status.status.toLowerCase();
    return s == 'success' || s == 'valid';
  }

  /// Whether the API call failed.
  bool get isError => !isSuccess;

  /// Convenience accessor for the status message.
  String? get message => status.message;

  /// Creates an [ApiResponse] from a JSON map.
  ///
  /// If [fromData] is provided, it is used to transform the raw `data` field
  /// into a typed [T]. If the `data` field is null or [fromData] is not
  /// provided, [data] will be null.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    final statusJson = json['status'];
    final apiStatus = statusJson is Map<String, dynamic>
        ? ApiStatus.fromJson(statusJson)
        : const ApiStatus(status: 'error', message: 'Invalid response format');

    T? parsedData;
    final rawData = json['data'];
    if (rawData != null && fromData != null) {
      try {
        parsedData = fromData(rawData);
      } catch (e) {
        // If data parsing fails, leave data as null. The status is still
        // available so callers can decide how to handle the failure.
        parsedData = null;
      }
    }

    return ApiResponse<T>(
      status: apiStatus,
      data: parsedData,
    );
  }

  /// Creates a synthetic error response for client-side failures.
  factory ApiResponse.error(String message) {
    return ApiResponse<T>(
      status: ApiStatus(status: 'error', message: message),
    );
  }

  @override
  String toString() {
    return 'ApiResponse(status: $status, hasData: ${data != null})';
  }
}

/// Represents the `status` envelope of a KNEX API response.
class ApiStatus {
  final String status;
  final String? result;
  final String? message;

  const ApiStatus({
    required this.status,
    this.result,
    this.message,
  });

  factory ApiStatus.fromJson(Map<String, dynamic> json) {
    return ApiStatus(
      status: (json['status'] as String?) ?? 'error',
      result: json['result'] as String?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (result != null) 'result': result,
      if (message != null) 'message': message,
    };
  }

  @override
  String toString() {
    return 'ApiStatus(status: $status, result: $result, message: $message)';
  }
}
