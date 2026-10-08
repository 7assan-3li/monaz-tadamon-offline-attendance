import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/core/widgets/confirmation_dialog.dart';
import 'package:tadamon_attendance_app/features/backup/presentation/bloc/backup_bloc.dart';
import 'package:tadamon_attendance_app/features/backup/presentation/bloc/backup_event.dart';
import 'package:tadamon_attendance_app/features/backup/presentation/bloc/backup_state.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _restorePayloadController = TextEditingController();

  @override
  void dispose() {
    _restorePayloadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('النسخ الاحتياطي والاستعادة (USB)'),
        centerTitle: false,
      ),
      body: BlocConsumer<BackupBloc, BackupState>(
        listener: (context, state) {
          if (state is BackupRestoredSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.present,
              ),
            );
          } else if (state is BackupFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: AppColors.unexcused,
              ),
            );
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Info Card
              AppCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.sessionBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.hardDrive,
                        color: AppColors.royalBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حفظ واستعادة بيانات النادي',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'حزم مشفرة بختم SHA-256 مع عزل بيانات الترخيص وساعة النظام لمنع التلاعب.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Export Section
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.upload, size: 20, color: AppColors.royalBlue),
                        SizedBox(width: 8),
                        Text(
                          'تصدير نسخة احتياطية جديدة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'يتم تجميع كافة الفرق، اللاعبين، التمارين، وسجل التدقيق في حزمة واحدة موثقة رقمياً.',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      label: 'إنشاء نسخة احتياطية الآن',
                      leadingIcon: LucideIcons.download,
                      onPressed: () {
                        context.read<BackupBloc>().add(const CreateBackupRequestedEvent());
                      },
                    ),

                    if (state is BackupCreatedSuccess) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.presentBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.present),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'معرف النسخة: ${state.package.manifest.backupId}',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.present,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.copy, size: 18, color: AppColors.present),
                                  tooltip: 'نسخ محتوى الحزمة',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: state.package.rawContent));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم نسخ بيانات النسخة الاحتياطية للحافظة.'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Text(
                              'ختم SHA-256: ${state.package.manifest.sha256Checksum.substring(0, 16)}...',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إجمالي: ${state.package.manifest.tableCounts['players'] ?? 0} لاعبين | ${state.package.manifest.tableCounts['sessions'] ?? 0} تمارين',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Import & Restore Section
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.history, size: 20, color: AppColors.excused),
                        SizedBox(width: 8),
                        Text(
                          'استعادة نسخة احتياطية من USB',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'الصق محتوى ملف النسخة الاحتياطية لفحص تطابقه الرقمي واستعادة البيانات:',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _restorePayloadController,
                      maxLines: 4,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'الصق نص حزمة النسخة الاحتياطية هنا...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.borderSubtle),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'فحص صحة الحزمة وختم SHA-256',
                      leadingIcon: LucideIcons.shieldCheck,
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        final text = _restorePayloadController.text.trim();
                        if (text.isNotEmpty) {
                          context.read<BackupBloc>().add(VerifyBackupRequestedEvent(text));
                        }
                      },
                    ),

                    if (state is BackupVerifiedState) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.present, width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(LucideIcons.checkCircle2, color: AppColors.present, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'النسخة سليمة وموثقة رقمياً بنجاح',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.present,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'النادي: ${state.manifest.clubName} | التاريخ: ${state.manifest.createdAt.toLocal()}',
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
                            ),
                            const SizedBox(height: 10),
                            AppButton(
                              label: 'تأكيد الاستعادة واستبدال البيانات',
                              leadingIcon: LucideIcons.rotateCcw,
                              variant: AppButtonVariant.destructive,
                              onPressed: () async {
                                final confirmed = await showAppConfirmationDialog(
                                  context: context,
                                  title: 'استعادة النسخة الاحتياطية',
                                  message:
                                      'سيتم استبدال بيانات الفرق واللاعبين والتمارين الحالية ببيانات النسخة المحددة. بيانات الترخيص وساعة الجهاز ستظل محفوظة ومحمية. هل ترغب بالمتابعة؟',
                                  confirmLabel: 'استعادة وتطبيق',
                                  isDestructive: true,
                                );
                                if (confirmed == true && context.mounted) {
                                  context.read<BackupBloc>().add(
                                        RestoreBackupConfirmedEvent(state.packageContent),
                                      );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (state is BackupInProgress) ...[
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 10),
                      Text(
                        state.message,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
