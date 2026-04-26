import 'package:sqflite/sqflite.dart';
import 'package:technical_test_superindo/domain/entities/member.dart';

abstract class MemberLocalDataSource {
  Future<void> saveMember(Member member);
  Future<List<Member>> getDraftMembers(String? userId);
  Future<void> updateMemberStatus(int id, bool isSynced);
  Future<void> deleteMember(int id);
  Future<void> deleteAllMembers();
}

class MemberLocalDataSourceImpl implements MemberLocalDataSource {
  final Database database;

  MemberLocalDataSourceImpl(this.database);

  @override
  Future<void> saveMember(Member member) async {
    await database.insert(
      'members',
      member.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Member>> getDraftMembers(String? userId) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'members',
      where: 'is_synced = ? AND (user_id = ? OR (? IS NULL AND user_id IS NULL))',
      whereArgs: [0, userId, userId],
    );
    return List.generate(maps.length, (i) => Member.fromMap(maps[i]));
  }

  @override
  Future<void> updateMemberStatus(int id, bool isSynced) async {
    await database.update(
      'members',
      {'is_synced': isSynced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteMember(int id) async {
    await database.delete(
      'members',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteAllMembers() async {
    await database.delete('members');
  }
}
