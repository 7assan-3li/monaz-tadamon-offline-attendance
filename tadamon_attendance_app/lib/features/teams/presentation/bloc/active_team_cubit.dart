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

  static final Map<String, ActiveTeamState> _dynamicTeams = {};

  static void registerTeams(List<dynamic> teams) {
    for (final t in teams) {
      final id = (t as dynamic).id as String;
      final name = (t as dynamic).name as String;
      final cat = (t as dynamic).category as String? ?? '';
      _dynamicTeams[id] = ActiveTeamState(
        teamId: id,
        teamName: name,
        category: cat,
      );
    }
  }

  static ActiveTeamState fromId(String id, [String? fallbackName]) {
    if (_dynamicTeams.containsKey(id)) {
      return _dynamicTeams[id]!;
    }
    for (final t in availableTeams) {
      if (t.teamId == id) return t;
    }
    if (fallbackName != null && fallbackName.trim().isNotEmpty) {
      final state = ActiveTeamState(teamId: id, teamName: fallbackName.trim());
      _dynamicTeams[id] = state;
      return state;
    }
    return defaultTeam;
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

  void updateAvailableTeams(List<dynamic> teams) {
    ActiveTeamState.registerTeams(teams);
  }

  void selectTeam({
    required String teamId,
    required String teamName,
    String category = '',
  }) {
    final state = ActiveTeamState(
      teamId: teamId,
      teamName: teamName,
      category: category,
    );
    ActiveTeamState._dynamicTeams[teamId] = state;
    emit(state);
  }

  void selectById(String teamId, [String? fallbackName]) {
    emit(ActiveTeamState.fromId(teamId, fallbackName));
  }
}
