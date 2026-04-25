import 'package:dio/dio.dart';
import 'package:technical_test_superindo/core/error/failures.dart';

class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else {
      return ServerFailure(error.toString());
    }
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout');
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        String message = 'Server error';
        if (data != null && data is Map) {
          message = data['error'] ?? data['message'] ?? 'Status: ${error.response?.statusCode}';
        } else if (error.response?.statusCode != null) {
          message = 'Error code: ${error.response?.statusCode}';
        }
        return ServerFailure(message);
      case DioExceptionType.cancel:
        return const ServerFailure('Request cancelled');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');
      default:
        return ServerFailure(error.message ?? 'Unknown server error');
    }
  }
}
