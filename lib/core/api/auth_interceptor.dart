import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:technical_test_superindo/core/utils/constants.dart';
import 'package:technical_test_superindo/presentation/pages/login_page.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;
  final GlobalKey<NavigatorState> navigatorKey;

  AuthInterceptor(this.secureStorage, this.navigatorKey);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await secureStorage.read(key: AppConstants.tokenKey);
    if (token != null && token.trim().isNotEmpty) {
      // Sanitize token: trim and remove any accidental Bearer prefix if it exists twice
      final cleanToken = token.trim().replaceFirst('Bearer ', '');
      options.headers['Authorization'] = 'Bearer $cleanToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Clear token on unauthorized
      await secureStorage.delete(key: AppConstants.tokenKey);
      
      // Redirect to login page
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
    handler.next(err);
  }
}
