import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/usecases/attendance_use_cases.dart';

sealed class AttendanceEvent {
  const AttendanceEvent();
}

class StartTodaySessionEvent extends AttendanceEvent {
  const StartTodaySessionEvent(this.teamId);
  final String teamId;
}

class MarkAllPresentEvent extends AttendanceEvent {
  const MarkAllPresentEvent();
}

class UpdatePlayerStatusEvent extends AttendanceEvent {
  const UpdatePlayerStatusEvent(this.playerId);
  final String playerId;
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
  const AttendanceReady(this.session);
  final AttendanceSession session;
}

class AttendanceFailure extends AttendanceState {
  const AttendanceFailure(this.message);
  final String message;
}

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc(this._start, this._markAll, this._update, this._dispatch)
    : super(const AttendanceInitial()) {
    on<StartTodaySessionEvent>(
      (event, emit) async =>
          _run(emit, () => _start(event.teamId), loading: true),
    );
    on<MarkAllPresentEvent>(
      (event, emit) async =>
          _runCurrent(emit, (session) => _markAll(session.sessionUuid)),
    );
    on<UpdatePlayerStatusEvent>(
      (event, emit) async => _runCurrent(emit, (session) {
        final item = session.items.firstWhere(
          (entry) => entry.playerId == event.playerId,
        );
        return _update(session.sessionUuid, item.playerId, item.status.next);
      }),
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
  Future<void> _runCurrent(
    Emitter<AttendanceState> emit,
    Future<AttendanceSession> Function(AttendanceSession) action,
  ) async {
    final current = state;
    if (current is! AttendanceReady || current.session.isLocked) return;
    await _run(emit, () => action(current.session));
  }

  Future<void> _run(
    Emitter<AttendanceState> emit,
    Future<AttendanceSession> Function() action, {
    bool loading = false,
  }) async {
    try {
      if (loading) emit(const AttendanceLoading());
      emit(AttendanceReady(await action()));
    } on Object catch (error) {
      emit(AttendanceFailure(error.toString()));
    }
  }
}
