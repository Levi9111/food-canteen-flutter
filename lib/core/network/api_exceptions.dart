import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timed out. Please check your network connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        String message = 'An error occurred while communicating with the server.';

        if (responseData is Map<String, dynamic>) {
          if (responseData['message'] != null) {
            message = responseData['message'].toString();
          } else if (responseData['errorMessages'] != null &&
              responseData['errorMessages'] is List &&
              (responseData['errorMessages'] as List).isNotEmpty) {
            final firstError = responseData['errorMessages'][0];
            message = firstError['message'] ?? message;
          }
        }

        return ApiException(
          message: message,
          statusCode: statusCode,
          data: responseData,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Could not connect to server. Please ensure backend is running.',
        );
      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.');
      default:
        return ApiException(message: 'An unexpected network error occurred.');
    }
  }

  @override
  String toString() => message;
}
