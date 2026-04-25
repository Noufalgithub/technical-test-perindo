import 'package:technical_test_superindo/core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> login(String email, String password);
  Future<Either<Failure, String>> register(String name, String email, String password, {String? phone});
  Future<Either<Failure, Map<String, dynamic>>> getProfile();
  Future<void> logout();
  Future<bool> isLoggedIn();
}
