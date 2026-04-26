import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:technical_test_superindo/core/error/failures.dart';
import 'package:technical_test_superindo/core/error/error_handler.dart';
import 'package:technical_test_superindo/core/utils/constants.dart';
import 'package:technical_test_superindo/data/datasources/member_local_datasource.dart';
import 'package:technical_test_superindo/data/datasources/member_remote_datasource.dart';
import 'package:technical_test_superindo/domain/entities/member.dart';
import 'package:technical_test_superindo/domain/repositories/member_repository.dart';

class MemberRepositoryImpl implements MemberRepository {
  final MemberLocalDataSource localDataSource;
  final MemberRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  MemberRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.secureStorage,
  });

  Future<String?> _getUserId() async {
    final userDataString = await secureStorage.read(key: AppConstants.userKey);
    if (userDataString != null) {
      final userData = json.decode(userDataString);
      return userData['id']?.toString();
    }
    return null;
  }

  @override
  Future<Either<Failure, void>> saveMemberLocally(Member member) async {
    try {
      final userId = await _getUserId();
      final memberWithUser = Member(
        id: member.id,
        userId: userId,
        name: member.name,
        nik: member.nik,
        phone: member.phone,
        birthPlace: member.birthPlace,
        birthDate: member.birthDate,
        gender: member.gender,
        status: member.status,
        occupation: member.occupation,
        address: member.address,
        provinsi: member.provinsi,
        kotaKabupaten: member.kotaKabupaten,
        kecamatan: member.kecamatan,
        kelurahan: member.kelurahan,
        kodePos: member.kodePos,
        alamatDomisili: member.alamatDomisili,
        provinsiDomisili: member.provinsiDomisili,
        kotaKabupatenDomisili: member.kotaKabupatenDomisili,
        kecamatanDomisili: member.kecamatanDomisili,
        kelurahanDomisili: member.kelurahanDomisili,
        kodePosDomisili: member.kodePosDomisili,
        ktpPath: member.ktpPath,
        ktpSecondaryPath: member.ktpSecondaryPath,
        isSynced: member.isSynced,
      );
      await localDataSource.saveMember(memberWithUser);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Member>>> getDraftMembers() async {
    try {
      final userId = await _getUserId();
      final members = await localDataSource.getDraftMembers(userId);
      return Right(members);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Member>>> getSyncedMembers() async {
    try {
      final members = await remoteDataSource.getSyncedMembers();
      return Right(members);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> syncMember(Member member) async {
    try {
      await remoteDataSource.uploadMember(member);
      if (member.id != null) {
        await localDataSource.updateMemberStatus(member.id!, true);
      }
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllMembers() async {
    try {
      await localDataSource.deleteAllMembers();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
