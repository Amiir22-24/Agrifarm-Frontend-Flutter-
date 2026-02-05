class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ApiResponse<T>(
      success: json['success'] ?? true,
      data: json['data'] != null ? fromJson(json['data']) : null,
      message: json['message'],
      statusCode: json['statusCode'],
    );
  }

  factory ApiResponse.error(String message, [int? statusCode]) {
    return ApiResponse<T>(success: false, message: message, statusCode: statusCode);
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    if (json['success'] == true) {
      return ApiResponse.success(json, fromJson);
    } else {
      return ApiResponse.error(
        json['message'] ?? 'Erreur inconnue',
        json['statusCode'],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'statusCode': statusCode,
    };
  }
}

