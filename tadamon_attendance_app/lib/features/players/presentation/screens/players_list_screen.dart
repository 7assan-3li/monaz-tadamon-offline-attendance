import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/widgets/confirmation_dialog.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_bloc.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_event.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_state.dart';
import 'package:tadamon_attendance_app/features/players/presentation/widgets/add_edit_player_modal.dart';
import 'package:tadamon_attendance_app/features/players/presentation/widgets/player_card.dart';
import 'package:tadamon_attendance_app/features/players/presentation/widgets/search_filter_bar.dart';
import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';

class PlayersListScreen extends StatelessWidget {
  const PlayersListScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('اللاعبون')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _edit(context),
      icon: const Icon(LucideIcons.userPlus),
      label: const Text('إضافة لاعب'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SearchFilterBar(
            onChanged: (query) =>
                context.read<PlayersBloc>().add(PlayersRequested(query: query)),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: BlocBuilder<PlayersBloc, PlayersState>(
              builder: (context, state) => switch (state) {
                PlayersInitial() || PlayersLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                PlayersFailure(:final message) => Center(child: Text(message)),
                PlayersReady(:final players) when players.isEmpty =>
                  const Center(child: Text('لا يوجد لاعبون مسجلون بعد.')),
                PlayersReady(:final players) => ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (_, index) {
                    final player = players[index];
                    return PlayerCard(
                      player: player,
                      onEdit: () => _edit(context, player: player),
                      onArchive: () async {
                        final confirmed = await showAppConfirmationDialog(
                          context: context,
                          title: 'أرشفة اللاعب؟',
                          message: 'لن يُحذف سجل اللاعب التاريخي.',
                          confirmLabel: 'أرشفة',
                        );
                        if (confirmed && context.mounted) {
                          context.read<PlayersBloc>().add(
                            PlayerArchived(player.id),
                          );
                        }
                      },
                    );
                  },
                ),
              },
            ),
          ),
        ],
      ),
    ),
  );
  Future<void> _edit(BuildContext context, {ClubPlayer? player}) async {
    final result = await showAddEditPlayerModal(context, player: player);
    if (result == null || !context.mounted) return;
    context.read<PlayersBloc>().add(
      player == null ? PlayerAdded(result) : PlayerUpdated(result),
    );
  }
}
