import 'package:drift/drift.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/theme/club_theme_service.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:tadamon_attendance_app/features/sync/data/datasources/cloud_sync_api_client.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/cloud_master_data.dart';
import 'package:tadamon_attendance_app/features/sync/domain/repositories/cloud_sync_repository.dart';
import 'package:tadamon_attendance_app/features/teams/domain/entities/club_team.dart';
import 'package:tadamon_attendance_app/features/teams/domain/repositories/teams_repository.dart';

class CloudSyncRepositoryImpl implements CloudSyncRepository {
  CloudSyncRepositoryImpl({
    required this.apiClient,
    required this.settingsRepository,
    this.teamsRepository,
    this.database,
  });

  final CloudSyncApiClient apiClient;
  final SettingsRepository settingsRepository;
  final TeamsRepository? teamsRepository;
  final AppDatabase? database;

  @override
  Future<bool> checkConnectivity() => apiClient.checkHealth();

  @override
  Future<bool> registerDevice({
    required String deviceId,
    required String deviceName,
    required String role,
    String? clubName,
    String? season,
    String? primaryColorHex,
  }) async {
    final res = await apiClient.registerDevice({
      'device_id': deviceId,
      'device_name': deviceName,
      'role': role,
      'club_name': clubName,
      'season': season,
      'primary_color_hex': primaryColorHex,
    });
    return res != null && res['status'] == 'success';
  }

  @override
  Future<bool> pushMasterData({
    required String sourceDeviceId,
    required Map<String, dynamic> clubProfile,
    required List<Map<String, dynamic>> teams,
    required List<Map<String, dynamic>> players,
    int? versionTimestamp,
  }) async {
    final payload = {
      'source_device_id': sourceDeviceId,
      'version_timestamp': versionTimestamp ?? DateTime.now().millisecondsSinceEpoch,
      'club_profile': clubProfile,
      'teams': teams,
      'players': players,
    };

    final res = await apiClient.pushMasterData(payload);
    return res != null && res['status'] == 'success';
  }

  @override
  Future<CloudMasterData?> pullMasterData({String? clubId}) async {
    final res = await apiClient.pullMasterData(clubId: clubId);
    if (res == null || res['status'] != 'success' || res['data'] == null) {
      return null;
    }

    final rawData = Map<String, dynamic>.from(res['data'] as Map);
    final masterData = CloudMasterData.fromJson(rawData);

    // Synchronize local club settings & visual theme with pulled data
    final profile = masterData.clubProfile;
    final clubName = profile['club_name'] as String?;
    final colorHex = profile['primary_color_hex'] as String?;
    final season = profile['season'] as String?;

    if (clubName != null || colorHex != null) {
      final currentSettings = await settingsRepository.read();
      final updated = currentSettings.copyWith(
        clubName: clubName ?? currentSettings.clubName,
        season: season ?? currentSettings.season,
        primaryColorHex: colorHex ?? currentSettings.primaryColorHex,
      );
      await settingsRepository.save(updated);

      if (colorHex != null) {
        final parsedColor = ClubThemeService.parseColorHex(colorHex);
        ClubThemeService.instance.updatePrimaryColor(parsedColor);
      }
      if (clubName != null) {
        ClubThemeService.instance.updateClubName(clubName);
      }
    }

    // Synchronize teams into local database
    if (teamsRepository != null) {
      for (final t in masterData.teams) {
        final id = t['id'] as String?;
        final name = t['name'] as String?;
        if (id != null && name != null) {
          await teamsRepository!.saveTeam(ClubTeam(
            id: id,
            name: name,
            category: t['age_category'] as String? ?? 'عام',
          ));
        }
      }
    }

    // Synchronize players into local database
    if (database != null) {
      for (final p in masterData.players) {
        final id = p['id'] as String?;
        final name = p['name'] as String?;
        if (id != null && name != null) {
          await database!.into(database!.players).insertOnConflictUpdate(
                PlayersCompanion.insert(
                  id: id,
                  name: name,
                  jerseyNumber: Value(p['jersey_number'] as int? ?? 0),
                  teamId: p['team_id'] as String? ?? 'default',
                  position: Value(p['position'] as String? ?? 'لاعب'),
                  isArchived: const Value(false),
                  joinDate: DateTime.now().toUtc(),
                  updatedAt: DateTime.now().toUtc(),
                ),
              );
        }
      }
    }

    return masterData;
  }

  @override
  Future<bool> dispatchSessionToCloud(AttendanceSession session) async {
    final absentees = session.items
        .where((i) =>
            i.status == PlayerAttendanceStatus.excused ||
            i.status == PlayerAttendanceStatus.unexcused)
        .map((i) => {
              'player_id': i.playerId,
              'player_name': i.playerName,
              'status': i.status.name,
              'reason': i.notes,
            })
        .toList();

    final payload = {
      'session_uuid': session.sessionUuid,
      'team_id': session.teamId,
      'session_date': session.date.toIso8601String(),
      'source_device_id': 'field_device',
      'absentees': absentees,
      'present_count': session.presentCount,
      'excused_count': session.excusedCount,
      'unexcused_count': session.unexcusedCount,
      'total_count': session.totalCount,
      'period': session.period,
      'location': session.location,
    };

    return apiClient.dispatchSession(payload);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchDispatchedSessionsFromCloud({String? teamId}) {
    return apiClient.fetchDispatchedSessions(teamId: teamId);
  }

  @override
  Future<bool> approveSessionOnCloud(String sessionUuid, {String? approverDeviceId}) {
    return apiClient.approveSession(sessionUuid, approverDeviceId: approverDeviceId);
  }
}
