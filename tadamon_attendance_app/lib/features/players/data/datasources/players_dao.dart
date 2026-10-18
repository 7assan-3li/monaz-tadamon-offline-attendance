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

  Future<ClubPlayer?> findActiveByJerseyNumber({
    required String teamId,
    required int jerseyNumber,
    String? excludePlayerId,
  }) async {
    final statement = _database.select(_database.players)
      ..where((row) =>
          row.isArchived.equals(false) &
          row.teamId.equals(teamId) &
          row.jerseyNumber.equals(jerseyNumber));
    if (excludePlayerId != null && excludePlayerId.isNotEmpty) {
      statement.where((row) => row.id.equals(excludePlayerId).not());
    }
    final row = await statement.getSingleOrNull();
    return row != null ? _map(row) : null;
  }

  Future<void> insert(ClubPlayer player) async {
    final jerseyNumber = player.jerseyNumber;
    if (jerseyNumber != null) {
      final existing = await findActiveByJerseyNumber(
        teamId: player.teamId,
        jerseyNumber: jerseyNumber,
      );
      if (existing != null) {
        throw FormatException(
          'رقم القميص ($jerseyNumber) مسجل بالفعل للاعب "${existing.name}" في هذا الفريق.',
        );
      }
    }

    await _database.into(_database.players).insert(
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
  }

  Future<void> update(ClubPlayer player) async {
    final jerseyNumber = player.jerseyNumber;
    if (jerseyNumber != null) {
      final existing = await findActiveByJerseyNumber(
        teamId: player.teamId,
        jerseyNumber: jerseyNumber,
        excludePlayerId: player.id,
      );
      if (existing != null) {
        throw FormatException(
          'رقم القميص ($jerseyNumber) مسجل بالفعل للاعب "${existing.name}" في هذا الفريق.',
        );
      }
    }

    await (_database.update(
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
  }

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
