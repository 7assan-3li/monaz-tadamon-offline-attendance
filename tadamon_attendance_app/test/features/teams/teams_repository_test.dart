import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/features/teams/data/repositories/teams_repository_impl.dart';
import 'package:tadamon_attendance_app/features/teams/domain/entities/club_team.dart';

void main() {
  test('adds and updates a sports team without duplicate rows', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = TeamsRepositoryImpl(database);
    final now = DateTime.utc(2026, 10, 7);
    await repository.saveTeam(
      ClubTeam(
        id: 'team-first',
        name: 'الفريق الأول',
        category: 'الفريق الأول',
        updatedAt: now,
      ),
    );
    await repository.saveTeam(
      ClubTeam(
        id: 'team-first',
        name: 'الفريق الأول',
        category: 'فئة الرجال',
        updatedAt: now,
      ),
    );
    final teams = await repository.getTeams();
    expect(teams, hasLength(1));
    expect(teams.single.category, 'فئة الرجال');
    await database.close();
  });
}
