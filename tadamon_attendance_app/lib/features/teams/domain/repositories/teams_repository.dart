import 'package:tadamon_attendance_app/features/teams/domain/entities/club_team.dart';

abstract interface class TeamsRepository {
  Future<List<ClubTeam>> getTeams();
  Future<void> saveTeam(ClubTeam team);
}
