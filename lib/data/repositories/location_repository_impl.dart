import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:technical_test_superindo/core/error/failures.dart';
import 'package:technical_test_superindo/data/datasources/location_remote_datasource.dart';
import 'package:technical_test_superindo/domain/entities/location.dart';
import 'package:technical_test_superindo/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  LocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Location>>> getProvinces() async {
    try {
      final data = await remoteDataSource.getProvinces();
      return Right(data);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Location>>> getRegencies(String provinceId) async {
    try {
      final data = await remoteDataSource.getRegencies(provinceId);
      return Right(data);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Location>>> getDistricts(String regencyId) async {
    try {
      final data = await remoteDataSource.getDistricts(regencyId);
      return Right(data);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Location>>> getVillages(String districtId) async {
    try {
      final data = await remoteDataSource.getVillages(districtId);
      return Right(data);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
