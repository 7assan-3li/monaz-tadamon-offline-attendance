import 'package:flutter/material.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';

class ExceptionalEditReasonDialog extends StatefulWidget {
  const ExceptionalEditReasonDialog({
    required this.playerName,
    required this.currentStatus,
    required this.targetStatus,
    super.key,
  });

  final String playerName;
  final AttendanceStatus currentStatus;
  final AttendanceStatus targetStatus;

  @override
  State<ExceptionalEditReasonDialog> createState() =>
      _ExceptionalEditReasonDialogState();
}

class _ExceptionalEditReasonDialogState
    extends State<ExceptionalEditReasonDialog> {
  final _reasonController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final text = _reasonController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'سبب التعديل الاستثنائي إجباري لتوثيقه في سجل التدقيق.';
      });
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.royalBlue),
                const SizedBox(width: 8),
                Text(
                  'تعديل استثنائي لحالة اللاعب',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'اللاعب: ${widget.playerName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('من: ', style: Theme.of(context).textTheme.bodySmall),
                AttendanceBadge(status: widget.currentStatus),
                const SizedBox(width: 8),
                Text('إلى: ', style: Theme.of(context).textTheme.bodySmall),
                AttendanceBadge(status: widget.targetStatus),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'سبب التعديل الاستثنائي (إجباري)',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'اكتب سبب التعديل المعتمد لتدوينه في سجل التدقيق...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    errorText: _errorMessage,
                    errorStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppColors.unexcused,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.royalBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'إلغاء',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'حفظ وتدوين',
                    variant: AppButtonVariant.primary,
                    onPressed: _onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
