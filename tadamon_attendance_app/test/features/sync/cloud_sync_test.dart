import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/cloud_master_data.dart';
import 'package:tadamon_attendance_app/features/sync/domain/repositories/cloud_sync_repository.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/cloud_sync_bloc.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/cloud_sync_event.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/cloud_sync_state.dart';

class _MockCloudSyncRepository implements CloudSyncRepository {
  bool isOnline = true;
  bool pushSuccess = true;
  bool dispatchSuccess = true;

  @override
  Future<bool> checkConnectivity() async => isOnline;

  @override
  Future<bool> registerDevice({
    required String deviceId,
    required String deviceName,
    required String role,
    String? clubName,
    String? season,
    String? primaryColorHex,
  }) async => true;

  @override
  Future<bool> pushMasterData({
    required String sourceDeviceId,
    required Map<String, dynamic> clubProfile,
    required List<Map<String, dynamic>> teams,
    required List<Map<String, dynamic>> players,
    int? versionTimestamp,
  }) async => pushSuccess;

  @override
  Future<CloudMasterData?> pullMasterData({String? clubId}) async {
    return const CloudMasterData(
      clubProfile: {
        'club_name': 'نادي تضامن حضرموت',
        'season': '2026/2027',
        'primary_color_hex': '#0F48A2',
      },
      versionTimestamp: 123456,
      teams: [
        {'id': 'team_1', 'name': 'الفريق الأول'},
      ],
      players: [
        {'id': 'p_1', 'name': 'سالم العمودي'},
      ],
    );
  }

  @override
  Future<bool> dispatchSessionToCloud(AttendanceSession session) async => dispatchSuccess;

  @override
  Future<List<Map<String, dynamic>>> fetchDispatchedSessionsFromCloud({String? teamId}) async {
    return [
      {
        'session_uuid': 'cloud_sess_01',
        'team_id': 'team_1',
        'session_date': '2026-10-21',
        'status': 'pending',
      }
    ];
  }

  @override
  Future<bool> approveSessionOnCloud(String sessionUuid, {String? approverDeviceId}) async => true;
}

void main() {
  group('CloudMasterData entity tests', () {
    test('serializes and deserializes correctly', () {
      final json = {
        'club_profile': {'club_name': 'تضامن حضرموت', 'primary_color_hex': '#0F48A2'},
        'version_timestamp': 1700000000,
        'source_device_id': 'TD-MSTR-01',
        'teams': [
          {'id': 'team_1', 'name': 'الفريق الأول'}
        ],
        'players': [
          {'id': 'p_1', 'name': 'أحمد علي'}
        ],
      };

      final data = CloudMasterData.fromJson(json);
      expect(data.clubProfile['club_name'], 'تضامن حضرموت');
      expect(data.versionTimestamp, 1700000000);
      expect(data.teams.length, 1);
      expect(data.players.length, 1);
      expect(data.toJson()['version_timestamp'], 1700000000);
    });
  });

  group('CloudSyncBloc unit tests', () {
    late _MockCloudSyncRepository repo;
    late CloudSyncBloc bloc;

    setUp(() {
      repo = _MockCloudSyncRepository();
      bloc = CloudSyncBloc(repository: repo);
    });

    tearDown(() {
      bloc.close();
    });

    test('emits CloudHealthState on CheckCloudHealthEvent', () async {
      final expected = [
        isA<CloudSyncLoading>(),
        isA<CloudHealthState>().having((s) => s.isOnline, 'isOnline', true),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const CheckCloudHealthEvent());
    });

    test('emits CloudDeviceRegisteredState on RegisterCloudDeviceEvent', () async {
      final expected = [
        isA<CloudSyncLoading>(),
        isA<CloudDeviceRegisteredState>()
            .having((s) => s.deviceId, 'deviceId', 'TD-MSTR-01')
            .having((s) => s.role, 'role', 'master_admin'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const RegisterCloudDeviceEvent(
        deviceId: 'TD-MSTR-01',
        deviceName: 'جهاز الإدارة',
        role: 'master_admin',
      ));
    });

    test('emits MasterDataPulledState on PullMasterDataCloudEvent', () async {
      final expected = [
        isA<CloudSyncLoading>(),
        isA<MasterDataPulledState>()
            .having((s) => s.masterData.teams.length, 'teams.length', 1),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const PullMasterDataCloudEvent());
    });

    test('emits SessionDispatchedCloudState on DispatchSessionCloudEvent', () async {
      final session = AttendanceSession(
        sessionUuid: 'sess_test_123',
        teamId: 'team_1',
        date: DateTime.now(),
        items: const [
          PlayerAttendanceItem(
            playerId: 'p_1',
            playerName: 'أحمد سالم',
            status: PlayerAttendanceStatus.present,
          ),
        ],
        isLocked: true,
        isDispatched: true,
      );

      final expected = [
        isA<CloudSyncLoading>(),
        isA<SessionDispatchedCloudState>()
            .having((s) => s.sessionUuid, 'sessionUuid', 'sess_test_123'),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(DispatchSessionCloudEvent(session));
    });

    test('emits CloudSessionsFetchedState on FetchCloudSessionsEvent', () async {
      final expected = [
        isA<CloudSyncLoading>(),
        isA<CloudSessionsFetchedState>()
            .having((s) => s.sessions.length, 'sessions.length', 1),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const FetchCloudSessionsEvent());
    });
  });
}
