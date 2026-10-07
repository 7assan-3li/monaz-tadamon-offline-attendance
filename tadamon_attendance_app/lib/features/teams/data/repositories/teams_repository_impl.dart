import 'package:drift/drift.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/features/teams/domain/entities/club_team.dart';
import 'package:tadamon_attendance_app/features/teams/domain/repositories/teams_repository.dart';

class TeamsRepositoryImpl implements TeamsRepository {
  const TeamsRepositoryImpl(this._database);
  final AppDatabase _database;
  @override
  Future<List<ClubTeam>> getTeams() async {
    final query = _database.select(_database.teams)
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);
    return (await query.get())
        .map(
          (row) => ClubTeam(
            id: row.id,
            name: row.name,
            category: row.category,
            updatedAt: row.updatedAt,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveTeam(ClubTeam team) => _database
      .into(_database.teams)
      .insertOnConflictUpdate(
        TeamsCompanion.insert(
          id: team.id,
          name: team.name.trim(),
          category: team.category.trim(),
          createdAt: team.updatedAt,
          updatedAt: team.updatedAt,
        ),
      );
}
