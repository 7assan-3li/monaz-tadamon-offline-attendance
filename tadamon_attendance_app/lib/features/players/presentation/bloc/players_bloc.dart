import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadamon_attendance_app/features/players/domain/repositories/players_repository.dart';
import 'package:tadamon_attendance_app/features/players/domain/usecases/add_player_use_case.dart';
import 'package:tadamon_attendance_app/features/players/domain/usecases/archive_player_use_case.dart';
import 'package:tadamon_attendance_app/features/players/domain/usecases/get_players_use_case.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_event.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_state.dart';

class PlayersBloc extends Bloc<PlayersEvent, PlayersState> {
  PlayersBloc(
    this._getPlayers,
    this._addPlayer,
    this._archivePlayer,
    this._repository,
  ) : super(const PlayersInitial()) {
    on<PlayersRequested>(_onRequested);
    on<PlayerAdded>(_onAdded);
    on<PlayerUpdated>(_onUpdated);
    on<PlayerArchived>(_onArchived);
  }

  final GetPlayersUseCase _getPlayers;
  final AddPlayerUseCase _addPlayer;
  final ArchivePlayerUseCase _archivePlayer;
  final PlayersRepository _repository;
  String _query = '';

  Future<void> _onRequested(
    PlayersRequested event,
    Emitter<PlayersState> emit,
  ) async {
    _query = event.query;
    if (state is PlayersInitial) emit(const PlayersLoading());
    await _emitPlayers(emit);
  }

  Future<void> _onAdded(PlayerAdded event, Emitter<PlayersState> emit) async {
    try {
      await _addPlayer(event.player);
      await _emitPlayers(emit);
    } on Object catch (error) {
      emit(PlayersFailure(error.toString()));
    }
  }

  Future<void> _onUpdated(
    PlayerUpdated event,
    Emitter<PlayersState> emit,
  ) async {
    try {
      await _repository.updatePlayer(event.player);
      await _emitPlayers(emit);
    } on Object catch (error) {
      emit(PlayersFailure(error.toString()));
    }
  }

  Future<void> _onArchived(
    PlayerArchived event,
    Emitter<PlayersState> emit,
  ) async {
    try {
      await _archivePlayer(event.playerId);
      await _emitPlayers(emit);
    } on Object catch (error) {
      emit(PlayersFailure(error.toString()));
    }
  }

  Future<void> _emitPlayers(Emitter<PlayersState> emit) async {
    try {
      emit(PlayersReady(await _getPlayers(query: _query), query: _query));
    } on Object catch (error) {
      emit(PlayersFailure(error.toString()));
    }
  }
}
