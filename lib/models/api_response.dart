class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final Map<String, List<String>>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    T? parsedData;
    if (json['data'] != null && fromJsonT != null) {
      parsedData = fromJsonT(json['data']);
    }

    Map<String, List<String>>? parsedErrors;
    if (json['errors'] != null && json['errors'] is Map) {
      parsedErrors = {};
      (json['errors'] as Map).forEach((key, value) {
        if (value is List) {
          parsedErrors![key.toString()] =
              value.map((e) => e.toString()).toList();
        } else if (value is String) {
          parsedErrors![key.toString()] = [value];
        }
      });
    }

    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: parsedData,
      error: json['error']?.toString(),
      errors: parsedErrors,
    );
  }
}
