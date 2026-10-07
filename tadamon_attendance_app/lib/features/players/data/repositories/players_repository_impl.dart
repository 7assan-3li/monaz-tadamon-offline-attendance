import 'package:tadamon_attendance_app/core/routing/device_role_guard.dart';
import 'package:tadamon_attendance_app/features/players/data/datasources/players_dao.dart';
import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';
import 'package:tadamon_attendance_app/features/players/domain/repositories/players_repository.dart';

class PlayersRepositoryImpl implements PlayersRepository {
  const PlayersRepositoryImpl(this._dao, this._role);
  final PlayersDao _dao;
  final DeviceRole _role;

  void _requireMaster() {
    if (_role != DeviceRole.masterAdmin) {
      throw const UnauthorizedDeviceOperationException();
    }
  }

  @override
  Future<List<ClubPlayer>> getActivePlayers({String query = ''}) {
    _requireMaster();
    return _dao.getActive(query: query);
  }

  @override
  Future<void> addPlayer(ClubPlayer player) {
    _requireMaster();
    return _dao.insert(player);
  }

  @override
  Future<void> updatePlayer(ClubPlayer player) {
    _requireMaster();
    return _dao.update(player);
  }

  @override
  Future<void> archivePlayer(String playerId) {
    _requireMaster();
    return _dao.archive(playerId);
  }
}
