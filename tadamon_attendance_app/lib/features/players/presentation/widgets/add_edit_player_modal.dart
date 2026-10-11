import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';

Future<ClubPlayer?> showAddEditPlayerModal(
  BuildContext context, {
  ClubPlayer? player,
  String defaultTeamId = 'team-first',
}) {
  return showModalBottomSheet<ClubPlayer>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PlayerForm(
      player: player,
      defaultTeamId: defaultTeamId,
    ),
  );
}

class _PlayerForm extends StatefulWidget {
  const _PlayerForm({this.player, this.defaultTeamId = 'team-first'});
  final ClubPlayer? player;
  final String defaultTeamId;

  @override
  State<_PlayerForm> createState() => _PlayerFormState();
}

class _PlayerFormState extends State<_PlayerForm> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.player?.name);
  late final TextEditingController _numberController = TextEditingController(
    text: widget.player?.jerseyNumber?.toString() ?? '',
  );

  late String _selectedTeamId =
      widget.player?.teamId.isNotEmpty == true
          ? widget.player!.teamId
          : widget.defaultTeamId;

  late String _selectedPosition = _initPosition();

  bool get _isEditing =>
      widget.player != null && widget.player!.id.trim().isNotEmpty;

  String _initPosition() {
    final pos = widget.player?.position ?? '';
    if (pos.contains('حارس')) return 'حارس مرمى';
    if (pos.contains('دفاع') || pos.contains('ظهير')) return 'مدافع';
    if (pos.contains('وسط') || pos.contains('محور') || pos.contains('صانع')) {
      return 'لاعب وسط';
    }
    if (pos.contains('مهاجم') || pos.contains('جناح') || pos.contains('حربة')) {
      return 'مهاجم';
    }
    return 'لاعب وسط';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
                Text(
                  _isEditing ? 'تعديل بيانات اللاعب' : 'إضافة لاعب جديد إلى الكشف',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 18),

            // 1. Full Name Field
            const Text(
              'اسم اللاعب كاملاً',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              autofocus: !_isEditing,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'الاسم الثلاثي أو الرباعي للاعب',
                hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                prefixIcon: const Icon(LucideIcons.user, size: 18),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Jersey Number Field
            const Text(
              'رقم القميص',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'مثال: 14',
                hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                prefixIcon: const Icon(LucideIcons.hash, size: 18),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 3. Team / Squad Selection
            const Text(
              'الفئة الرياضية / الفريق المعتمد',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTeamChip('team-first', 'الفريق الأول'),
                const SizedBox(width: 8),
                _buildTeamChip('team-youth', 'فريق الشباب U-19'),
                const SizedBox(width: 8),
                _buildTeamChip('team-junior', 'الناشئين U-17'),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Main Position
            const Text(
              'المركز الأساسي في التشكيلة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPositionChip('حارس مرمى', LucideIcons.shieldCheck),
                _buildPositionChip('مدافع', LucideIcons.shield),
                _buildPositionChip('لاعب وسط', LucideIcons.circleDot),
                _buildPositionChip('مهاجم', LucideIcons.zap),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: Icon(
                _isEditing ? LucideIcons.save : LucideIcons.userPlus,
                size: 18,
              ),
              label: Text(
                _isEditing ? 'حفظ تعديلات اللاعب' : 'اعتماد قيد اللاعب في الكشف',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamChip(String teamId, String label) {
    final isSel = _selectedTeamId == teamId;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTeamId = teamId),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? AppColors.royalBlue : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSel ? AppColors.royalBlue : AppColors.borderSubtle,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
              color: isSel ? Colors.white : AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildPositionChip(String position, IconData icon) {
    final isSel = _selectedPosition == position;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 15,
        color: isSel ? Colors.white : AppColors.royalBlue,
      ),
      label: Text(
        position,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
          color: isSel ? Colors.white : AppColors.textPrimary,
        ),
      ),
      selected: isSel,
      selectedColor: AppColors.royalBlue,
      onSelected: (val) {
        if (val) setState(() => _selectedPosition = position);
      },
    );
  }

  void _save() {
    final trimmedName = _nameController.text.trim();
    if (trimmedName.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى كتابة اسم اللاعب.',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppColors.unexcused,
        ),
      );
      return;
    }

    final numberText = _numberController.text.trim();
    final jerseyNumber = int.tryParse(numberText);
    if (jerseyNumber != null && (jerseyNumber < 1 || jerseyNumber > 99)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'رقم القميص يجب أن يكون بين 1 و 99.',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppColors.unexcused,
        ),
      );
      return;
    }

    final now = DateTime.now().toUtc();
    final randomSuffix = Random().nextInt(99999);
    final playerId = _isEditing
        ? widget.player!.id
        : 'player-${now.microsecondsSinceEpoch}-$randomSuffix';

    final player = ClubPlayer(
      id: playerId,
      name: trimmedName,
      teamId: _selectedTeamId,
      jerseyNumber: jerseyNumber,
      position: _selectedPosition,
      notes: 'كشف معتمد',
      joinDate: _isEditing ? widget.player!.joinDate : now,
      updatedAt: now,
    );

    Navigator.pop(context, player);
  }
}
