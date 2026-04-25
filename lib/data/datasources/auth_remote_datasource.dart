import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String password, {
    String? phone,
  });
  Future<Map<String, dynamic>> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String password, {
    String? phone,
  }) async {
    final response = await dio.post(
      '/register',
      data: {
        'name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
      },
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    final response = await dio.get('/profile');
    return response.data ?? {};
  }
}
