import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/usecases/attendance_use_cases.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/bloc/attendance_bloc.dart';

void main() {
  late _Repository repository;
  AttendanceBloc build() => AttendanceBloc(
    StartTodaySessionUseCase(repository),
    MarkAllPresentUseCase(repository),
    UpdatePlayerStatusUseCase(repository),
    DispatchSessionUseCase(repository),
  );
  setUp(() => repository = _Repository());
  blocTest<AttendanceBloc, AttendanceState>(
    'starts today session with default unmarked players',
    build: build,
    act: (bloc) => bloc.add(const StartTodaySessionEvent('team-first')),
    expect: () => [
      isA<AttendanceLoading>(),
      isA<AttendanceReady>().having(
        (s) => s.session.items.length,
        'players',
        2,
      ),
    ],
  );
  blocTest<AttendanceBloc, AttendanceState>(
    'marks everyone present then dispatches and locks permanently',
    build: build,
    act: (bloc) async {
      bloc.add(const StartTodaySessionEvent('team-first'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const MarkAllPresentEvent());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const DispatchSessionEvent());
    },
    wait: const Duration(milliseconds: 20),
    verify: (bloc) {
      final session = (bloc.state as AttendanceReady).session;
      expect(session.presentCount, 2);
      expect(session.isLocked, isTrue);
    },
  );
}

class _Repository implements AttendanceRepository {
  late AttendanceSession session;
  AttendanceSession _initial() {
    final now = DateTime.utc(2026, 10, 7);
    return AttendanceSession(
      sessionUuid: 's1',
      teamId: 'team-first',
      date: now,
      isLocked: false,
      isDispatched: false,
      items: [
        PlayerAttendanceItem(
          playerId: 'p1',
          playerName: 'سالم',
          status: PlayerAttendanceStatus.unmarked,
        ),
        PlayerAttendanceItem(
          playerId: 'p2',
          playerName: 'علي',
          status: PlayerAttendanceStatus.unmarked,
        ),
      ],
    );
  }

  @override
  Future<AttendanceSession> startTodaySession(String teamId) async =>
      session = _initial();
  @override
  Future<AttendanceSession?> readSession(String id) async => session;
  @override
  Future<AttendanceSession> markAllPresent(String id) async =>
      session = session.copyWith(
        items: session.items
            .map(
              (item) => item.copyWith(status: PlayerAttendanceStatus.present),
            )
            .toList(),
      );
  @override
  Future<AttendanceSession> updateStatus(
    String id,
    String playerId,
    PlayerAttendanceStatus status,
  ) async => session;
  @override
  Future<AttendanceSession> dispatch(String id) async =>
      session = session.copyWith(isLocked: true, isDispatched: true);
}
