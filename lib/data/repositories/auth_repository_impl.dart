import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:technical_test_superindo/core/error/failures.dart';
import 'package:technical_test_superindo/core/error/error_handler.dart';
import 'package:technical_test_superindo/core/utils/constants.dart';
import 'package:technical_test_superindo/data/datasources/auth_remote_datasource.dart';
import 'package:technical_test_superindo/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, String>> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      final token = response['token'];
      if (token != null) {
        await secureStorage.write(key: AppConstants.tokenKey, value: token);
        return Right(token);
      } else {
        return const Left(ServerFailure('Token not found in response'));
      }
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, String>> register(String name, String email, String password, {String? phone}) async {
    try {
      final response = await remoteDataSource.register(name, email, password, phone: phone);
      final token = response['token'];
      if (token != null) {
        await secureStorage.write(key: AppConstants.tokenKey, value: token);
        return Right(token);
      } else {
        // If register succeeds but no token is returned, perform auto-login
        return login(email, password);
      }
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProfile() async {
    try {
      final response = await remoteDataSource.getProfile();
      return Right(response);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: AppConstants.tokenKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await secureStorage.read(key: AppConstants.tokenKey);
    return token != null;
  }
}
