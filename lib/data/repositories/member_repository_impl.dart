import 'package:dartz/dartz.dart';
import 'package:technical_test_superindo/core/error/failures.dart';
import 'package:technical_test_superindo/core/error/error_handler.dart';
import 'package:technical_test_superindo/data/datasources/member_local_datasource.dart';
import 'package:technical_test_superindo/data/datasources/member_remote_datasource.dart';
import 'package:technical_test_superindo/domain/entities/member.dart';
import 'package:technical_test_superindo/domain/repositories/member_repository.dart';

class MemberRepositoryImpl implements MemberRepository {
  final MemberLocalDataSource localDataSource;
  final MemberRemoteDataSource remoteDataSource;

  MemberRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, void>> saveMemberLocally(Member member) async {
    try {
      await localDataSource.saveMember(member);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Member>>> getDraftMembers() async {
    try {
      final members = await localDataSource.getDraftMembers();
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
}
