import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadamon_attendance_app/features/teams/domain/entities/club_team.dart';
import 'package:tadamon_attendance_app/features/teams/domain/repositories/teams_repository.dart';

sealed class TeamsEvent {
  const TeamsEvent();
}

class TeamsRequested extends TeamsEvent {
  const TeamsRequested();
}

class TeamSaved extends TeamsEvent {
  const TeamSaved(this.team);
  final ClubTeam team;
}

sealed class TeamsState {
  const TeamsState();
}

class TeamsLoading extends TeamsState {
  const TeamsLoading();
}

class TeamsReady extends TeamsState {
  const TeamsReady(this.teams);
  final List<ClubTeam> teams;
}

class TeamsFailure extends TeamsState {
  const TeamsFailure(this.message);
  final String message;
}

class TeamsBloc extends Bloc<TeamsEvent, TeamsState> {
  TeamsBloc(this._repository) : super(const TeamsLoading()) {
    on<TeamsRequested>((event, emit) async => _load(emit));
    on<TeamSaved>((event, emit) async {
      await _repository.saveTeam(event.team);
      await _load(emit);
    });
  }
  final TeamsRepository _repository;
  Future<void> _load(Emitter<TeamsState> emit) async {
    try {
      emit(TeamsReady(await _repository.getTeams()));
    } on Object catch (error) {
      emit(TeamsFailure(error.toString()));
    }
  }
}
