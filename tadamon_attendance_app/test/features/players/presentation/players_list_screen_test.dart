import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';
import 'package:tadamon_attendance_app/features/players/domain/repositories/players_repository.dart';
import 'package:tadamon_attendance_app/features/players/domain/usecases/add_player_use_case.dart';
import 'package:tadamon_attendance_app/features/players/domain/usecases/archive_player_use_case.dart';
import 'package:tadamon_attendance_app/features/players/domain/usecases/get_players_use_case.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_bloc.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_event.dart';
import 'package:tadamon_attendance_app/features/players/presentation/screens/players_list_screen.dart';

void main() {
  testWidgets('renders RTL player list and filters immediately by name', (
    tester,
  ) async {
    final repository = _Repository();
    final bloc = PlayersBloc(
      GetPlayersUseCase(repository),
      AddPlayerUseCase(repository),
      ArchivePlayerUseCase(repository),
      repository,
    )..add(const PlayersRequested());
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocProvider.value(
            value: bloc,
            child: const PlayersListScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('سالم مبارك'), findsOneWidget);
    expect(find.text('علي حسن'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'سالم');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('سالم مبارك'), findsOneWidget);
    expect(find.text('علي حسن'), findsNothing);
    expect(
      tester.getSize(find.text('إضافة لاعب')).height,
      greaterThanOrEqualTo(16),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _Repository implements PlayersRepository {
  final players = ['سالم مبارك', 'علي حسن'].map((name) {
    final now = DateTime.utc(2026, 10, 7);
    return ClubPlayer(
      id: name,
      name: name,
      teamId: 'team-first',
      joinDate: now,
      updatedAt: now,
    );
  }).toList();
  @override
  Future<void> addPlayer(ClubPlayer player) async => players.add(player);
  @override
  Future<void> archivePlayer(String id) async =>
      players.removeWhere((p) => p.id == id);
  @override
  Future<List<ClubPlayer>> getActivePlayers({String query = ''}) async =>
      players.where((p) => p.name.contains(query)).toList();
  @override
  Future<void> updatePlayer(ClubPlayer player) async {}
}
