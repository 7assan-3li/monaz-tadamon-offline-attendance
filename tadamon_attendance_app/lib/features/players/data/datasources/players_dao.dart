import 'package:drift/drift.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';

class PlayersDao {
  const PlayersDao(this._database);
  final AppDatabase _database;

  Future<List<ClubPlayer>> getActive({String query = ''}) async {
    final statement = _database.select(_database.players)
      ..where((row) => row.isArchived.equals(false))
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);
    if (query.trim().isNotEmpty) {
      statement.where((row) => row.name.like('%${query.trim()}%'));
    }
    final rows = await statement.get();
    return rows.map(_map).toList(growable: false);
  }

  Future<void> insert(ClubPlayer player) => _database
      .into(_database.players)
      .insert(
        PlayersCompanion.insert(
          id: player.id,
          name: player.name.trim(),
          teamId: player.teamId,
          jerseyNumber: Value(player.jerseyNumber),
          position: Value(player.position?.trim()),
          joinDate: player.joinDate,
          notes: Value(player.notes?.trim()),
          updatedAt: player.updatedAt,
        ),
      );

  Future<void> update(ClubPlayer player) =>
      (_database.update(
        _database.players,
      )..where((row) => row.id.equals(player.id))).write(
        PlayersCompanion(
          name: Value(player.name.trim()),
          teamId: Value(player.teamId),
          jerseyNumber: Value(player.jerseyNumber),
          position: Value(player.position?.trim()),
          notes: Value(player.notes?.trim()),
          updatedAt: Value(player.updatedAt),
        ),
      );

  Future<void> archive(String playerId) =>
      (_database.update(
        _database.players,
      )..where((row) => row.id.equals(playerId))).write(
        PlayersCompanion(
          isArchived: const Value(true),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );

  ClubPlayer _map(Player row) => ClubPlayer(
    id: row.id,
    name: row.name,
    teamId: row.teamId,
    jerseyNumber: row.jerseyNumber,
    position: row.position,
    joinDate: row.joinDate,
    isArchived: row.isArchived,
    notes: row.notes,
    updatedAt: row.updatedAt,
  );
}
