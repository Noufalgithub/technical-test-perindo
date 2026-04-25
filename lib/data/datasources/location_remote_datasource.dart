import 'package:dio/dio.dart';
import 'package:technical_test_superindo/domain/entities/location.dart';

abstract class LocationRemoteDataSource {
  Future<List<Location>> getProvinces();
  Future<List<Location>> getRegencies(String provinceId);
  Future<List<Location>> getDistricts(String regencyId);
  Future<List<Location>> getVillages(String districtId);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final Dio dio;

  LocationRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Location>> getProvinces() async {
    final response = await dio.get('https://www.emsifa.com/api-wilayah-indonesia/api/provinces.json');
    return (response.data as List).map((e) => Location.fromMap(e)).toList();
  }

  @override
  Future<List<Location>> getRegencies(String provinceId) async {
    final response = await dio.get('https://www.emsifa.com/api-wilayah-indonesia/api/regencies/$provinceId.json');
    return (response.data as List).map((e) => Location.fromMap(e)).toList();
  }

  @override
  Future<List<Location>> getDistricts(String regencyId) async {
    final response = await dio.get('https://www.emsifa.com/api-wilayah-indonesia/api/districts/$regencyId.json');
    return (response.data as List).map((e) => Location.fromMap(e)).toList();
  }

  @override
  Future<List<Location>> getVillages(String districtId) async {
    final response = await dio.get('https://www.emsifa.com/api-wilayah-indonesia/api/villages/$districtId.json');
    return (response.data as List).map((e) => Location.fromMap(e)).toList();
  }
}
