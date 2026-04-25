import 'package:dartz/dartz.dart';
import 'package:technical_test_superindo/core/error/failures.dart';
import 'package:technical_test_superindo/domain/entities/location.dart';

abstract class LocationRepository {
  Future<Either<Failure, List<Location>>> getProvinces();
  Future<Either<Failure, List<Location>>> getRegencies(String provinceId);
  Future<Either<Failure, List<Location>>> getDistricts(String regencyId);
  Future<Either<Failure, List<Location>>> getVillages(String districtId);
}
