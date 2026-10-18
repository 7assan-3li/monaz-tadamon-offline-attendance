import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/usecases/attendance_use_cases.dart';

sealed class AttendanceEvent {
  const AttendanceEvent();
}

class StartTodaySessionEvent extends AttendanceEvent {
  const StartTodaySessionEvent(
    this.teamId, {
    this.period = 'مسائي',
    this.location,
  });
  final String teamId;
  final String period;
  final String? location;
}

class CreateNewSessionEvent extends AttendanceEvent {
  const CreateNewSessionEvent({
    required this.teamId,
    this.period = 'مسائي',
    this.location,
    this.sessionTitle,
  });
  final String teamId;
  final String period;
  final String? location;
  final String? sessionTitle;
}

class LoadActiveDraftsEvent extends AttendanceEvent {
  const LoadActiveDraftsEvent({this.teamId});
  final String? teamId;
}

class SwitchActiveSessionEvent extends AttendanceEvent {
  const SwitchActiveSessionEvent(this.sessionUuid);
  final String sessionUuid;
}

class MarkAllPresentEvent extends AttendanceEvent {
  const MarkAllPresentEvent({this.allowAdminOverride = false});
  final bool allowAdminOverride;
}

class UpdatePlayerStatusEvent extends AttendanceEvent {
  const UpdatePlayerStatusEvent(this.playerId, {this.allowAdminOverride = false});
  final String playerId;
  final bool allowAdminOverride;
}

class SetPlayerAttendanceStatusEvent extends AttendanceEvent {
  const SetPlayerAttendanceStatusEvent({
    required this.playerId,
    required this.status,
    this.allowAdminOverride = false,
  });
  final String playerId;
  final PlayerAttendanceStatus status;
  final bool allowAdminOverride;
}

class DispatchSessionEvent extends AttendanceEvent {
  const DispatchSessionEvent();
}

sealed class AttendanceState {
  const AttendanceState();
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

class AttendanceReady extends AttendanceState {
  const AttendanceReady(
    this.session, {
    this.activeDrafts = const [],
  });
  final AttendanceSession session;
  final List<AttendanceSession> activeDrafts;

  AttendanceReady copyWith({
    AttendanceSession? session,
    List<AttendanceSession>? activeDrafts,
  }) => AttendanceReady(
    session ?? this.session,
    activeDrafts: activeDrafts ?? this.activeDrafts,
  );
}

class AttendanceFailure extends AttendanceState {
  const AttendanceFailure(this.message);
  final String message;
}

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc(
    this._start,
    this._markAll,
    this._update,
    this._dispatch, {
    this.createSession,
    this.getActiveDrafts,
    this.readSession,
  }) : super(const AttendanceInitial()) {
    on<StartTodaySessionEvent>(
      (event, emit) async => _runWithDrafts(
        emit,
        () => _start(
          event.teamId,
          period: event.period,
          location: event.location,
        ),
        loading: true,
        teamId: event.teamId,
      ),
    );

    on<CreateNewSessionEvent>(
      (event, emit) async => _runWithDrafts(
        emit,
        () async {
          if (createSession != null) {
            return createSession!(
              teamId: event.teamId,
              period: event.period,
              location: event.location,
              sessionTitle: event.sessionTitle,
            );
          }
          return _start(
            event.teamId,
            period: event.period,
            location: event.location,
          );
        },
        loading: true,
        teamId: event.teamId,
      ),
    );

    on<SwitchActiveSessionEvent>((event, emit) async {
      final reader = readSession;
      if (reader == null) return;
      try {
        emit(const AttendanceLoading());
        final session = await reader(event.sessionUuid);
        if (session != null) {
          final drafts = await _loadDrafts(session.teamId);
          emit(AttendanceReady(session, activeDrafts: drafts));
        }
      } on Object catch (error) {
        emit(AttendanceFailure(error.toString()));
      }
    });

    on<LoadActiveDraftsEvent>((event, emit) async {
      final current = state;
      if (current is AttendanceReady) {
        final drafts = await _loadDrafts(
          event.teamId ?? current.session.teamId,
        );
        emit(current.copyWith(activeDrafts: drafts));
      }
    });

    on<MarkAllPresentEvent>(
      (event, emit) async => _runCurrent(
        emit,
        (session) => _markAll(
          session.sessionUuid,
          allowAdminOverride: event.allowAdminOverride,
        ),
        allowAdminOverride: event.allowAdminOverride,
      ),
    );

    on<UpdatePlayerStatusEvent>(
      (event, emit) async => _runCurrent(
        emit,
        (session) {
          final item = session.items.firstWhere(
            (entry) => entry.playerId == event.playerId,
          );
          return _update(
            session.sessionUuid,
            item.playerId,
            item.status.next,
            allowAdminOverride: event.allowAdminOverride,
          );
        },
        allowAdminOverride: event.allowAdminOverride,
      ),
    );

    on<SetPlayerAttendanceStatusEvent>(
      (event, emit) async => _runCurrent(
        emit,
        (session) => _update(
          session.sessionUuid,
          event.playerId,
          event.status,
          allowAdminOverride: event.allowAdminOverride,
        ),
        allowAdminOverride: event.allowAdminOverride,
      ),
    );

    on<DispatchSessionEvent>(
      (event, emit) async =>
          _runCurrent(emit, (session) => _dispatch(session.sessionUuid)),
    );
  }

  final StartTodaySessionUseCase _start;
  final MarkAllPresentUseCase _markAll;
  final UpdatePlayerStatusUseCase _update;
  final DispatchSessionUseCase _dispatch;
  final CreateSessionUseCase? createSession;
  final GetActiveDraftsUseCase? getActiveDrafts;
  final ReadSessionUseCase? readSession;

  Future<List<AttendanceSession>> _loadDrafts(String? teamId) async {
    final getter = getActiveDrafts;
    if (getter == null) return const [];
    try {
      return await getter(teamId: teamId);
    } catch (_) {
      return const [];
    }
  }

  Future<void> _runCurrent(
    Emitter<AttendanceState> emit,
    Future<AttendanceSession> Function(AttendanceSession) action, {
    bool allowAdminOverride = false,
  }) async {
    final current = state;
    if (current is! AttendanceReady) return;
    if (current.session.isLocked && !allowAdminOverride) return;
    try {
      final updatedSession = await action(current.session);
      final drafts = await _loadDrafts(updatedSession.teamId);
      emit(AttendanceReady(updatedSession, activeDrafts: drafts));
    } on Object catch (error) {
      emit(AttendanceFailure(error.toString()));
    }
  }

  Future<void> _runWithDrafts(
    Emitter<AttendanceState> emit,
    Future<AttendanceSession> Function() action, {
    bool loading = false,
    String? teamId,
  }) async {
    try {
      if (loading) emit(const AttendanceLoading());
      final session = await action();
      final drafts = await _loadDrafts(teamId ?? session.teamId);
      emit(AttendanceReady(session, activeDrafts: drafts));
    } on Object catch (error) {
      emit(AttendanceFailure(error.toString()));
    }
  }
}
