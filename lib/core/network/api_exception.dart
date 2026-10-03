class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? error;
  final Map<String, List<String>>? fieldErrors;

  ApiException({
    required this.message,
    this.statusCode,
    this.error,
    this.fieldErrors,
  });

  factory ApiException.fromDioError(dynamic dioError) {
    if (dioError is! Exception) {
      return ApiException(message: 'An unexpected error occurred.');
    }

    try {
      final dynamic response = (dioError as dynamic).response;
      if (response != null && response.data != null) {
        final dynamic data = response.data;
        if (data is Map<String, dynamic>) {
          String message = data['message'] ?? 'An error occurred';
          String? errorTitle = data['error'];
          Map<String, List<String>>? fieldErrors;

          if (data['errors'] != null && data['errors'] is Map) {
            fieldErrors = {};
            (data['errors'] as Map).forEach((key, value) {
              if (value is List) {
                fieldErrors![key.toString()] =
                    value.map((e) => e.toString()).toList();
              } else if (value is String) {
                fieldErrors![key.toString()] = [value];
              }
            });

            // If message is generic, combine field errors
            if (fieldErrors.isNotEmpty && message.toLowerCase().contains('validation')) {
              final firstErr = fieldErrors.values.first.firstOrNull;
              if (firstErr != null) {
                message = firstErr;
              }
            }
          }

          return ApiException(
            message: message,
            statusCode: response.statusCode,
            error: errorTitle,
            fieldErrors: fieldErrors,
          );
        }
      }

      // Handle status codes without standard json body
      final statusCode = response?.statusCode;
      if (statusCode == 401) {
        return ApiException(
          message: 'Invalid credentials or session expired.',
          statusCode: statusCode,
        );
      } else if (statusCode == 403) {
        return ApiException(
          message: 'Access forbidden or account deactivated.',
          statusCode: statusCode,
        );
      } else if (statusCode == 404) {
        return ApiException(
          message: 'Requested resource not found.',
          statusCode: statusCode,
        );
      } else if (statusCode == 500) {
        return ApiException(
          message: 'Internal server error. Please try again later.',
          statusCode: statusCode,
        );
      }
    } catch (_) {
      // Fallback
    }

    return ApiException(
      message: 'Network error. Please check your connection and backend URL.',
    );
  }

  factory ApiException.fromResponse(dynamic response) {
    final int? statusCode = response.statusCode;
    final dynamic data = response.data;

    if (data is Map<String, dynamic>) {
      String message = data['message'] ?? 'An error occurred';
      String? errorTitle = data['error'];
      Map<String, List<String>>? fieldErrors;

      if (data['errors'] != null && data['errors'] is Map) {
        fieldErrors = {};
        (data['errors'] as Map).forEach((key, value) {
          if (value is List) {
            fieldErrors![key.toString()] =
                value.map((e) => e.toString()).toList();
          } else if (value is String) {
            fieldErrors![key.toString()] = [value];
          }
        });

        if (fieldErrors.isNotEmpty && message.toLowerCase().contains('validation')) {
          final firstErr = fieldErrors.values.first.firstOrNull;
          if (firstErr != null) {
            message = firstErr;
          }
        }
      }

      return ApiException(
        message: message,
        statusCode: statusCode,
        error: errorTitle,
        fieldErrors: fieldErrors,
      );
    }

    if (statusCode == 401) {
      return ApiException(
        message: 'Invalid credentials or session expired.',
        statusCode: statusCode,
      );
    } else if (statusCode == 403) {
      return ApiException(
        message: 'Access forbidden or account deactivated.',
        statusCode: statusCode,
      );
    } else if (statusCode == 404) {
      return ApiException(
        message: 'Requested resource not found.',
        statusCode: statusCode,
      );
    } else if (statusCode == 500) {
      return ApiException(
        message: 'Internal server error. Please try again later.',
        statusCode: statusCode,
      );
    }

    return ApiException(
      message: 'Request failed with status $statusCode.',
      statusCode: statusCode,
    );
  }

  @override
  String toString() => message;
}
