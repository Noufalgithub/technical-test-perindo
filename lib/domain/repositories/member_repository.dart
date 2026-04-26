import 'package:dartz/dartz.dart';
import 'package:technical_test_superindo/core/error/failures.dart';
import 'package:technical_test_superindo/domain/entities/member.dart';

abstract class MemberRepository {
  Future<Either<Failure, void>> saveMemberLocally(Member member);
  Future<Either<Failure, List<Member>>> getDraftMembers();
  Future<Either<Failure, List<Member>>> getSyncedMembers();
  Future<Either<Failure, void>> syncMember(Member member);
  Future<Either<Failure, void>> deleteAllMembers();
}
