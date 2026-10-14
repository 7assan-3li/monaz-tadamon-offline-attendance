import 'package:flutter_bloc/flutter_bloc.dart';

class ActiveTeamState {
  const ActiveTeamState({
    required this.teamId,
    required this.teamName,
    this.category = '',
  });

  final String teamId;
  final String teamName;
  final String category;

  static const defaultTeam = ActiveTeamState(
    teamId: 'team-first',
    teamName: 'الفريق الأول',
    category: 'الفريق الأول',
  );

  static const availableTeams = [
    ActiveTeamState(
      teamId: 'team-first',
      teamName: 'الفريق الأول',
      category: 'الفريق الأول',
    ),
    ActiveTeamState(
      teamId: 'team-youth',
      teamName: 'فريق الشباب',
      category: 'تحت 19 سنة',
    ),
    ActiveTeamState(
      teamId: 'team-junior',
      teamName: 'فريق الناشئين',
      category: 'تحت 17 سنة',
    ),
  ];

  static ActiveTeamState fromId(String id) {
    return availableTeams.firstWhere(
      (t) => t.teamId == id,
      orElse: () => defaultTeam,
    );
  }

  ActiveTeamState copyWith({
    String? teamId,
    String? teamName,
    String? category,
  }) {
    return ActiveTeamState(
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActiveTeamState &&
          runtimeType == other.runtimeType &&
          teamId == other.teamId &&
          teamName == other.teamName &&
          category == other.category;

  @override
  int get hashCode => teamId.hashCode ^ teamName.hashCode ^ category.hashCode;
}

class ActiveTeamCubit extends Cubit<ActiveTeamState> {
  ActiveTeamCubit({ActiveTeamState initialState = ActiveTeamState.defaultTeam})
      : super(initialState);

  void selectTeam({
    required String teamId,
    required String teamName,
    String category = '',
  }) {
    emit(ActiveTeamState(
      teamId: teamId,
      teamName: teamName,
      category: category,
    ));
  }

  void selectById(String teamId) {
    emit(ActiveTeamState.fromId(teamId));
  }
}
