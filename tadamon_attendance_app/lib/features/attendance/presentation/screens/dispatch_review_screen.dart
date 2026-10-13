import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/di/service_locator.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/core/widgets/confirmation_dialog.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/widgets/locked_session_banner.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/screens/field_qr_display_screen.dart';

class DispatchReviewScreen extends StatelessWidget {
  const DispatchReviewScreen({
    this.onBack,
    this.onReturnHome,
    this.onStartAnotherSession,
    super.key,
  });

  final VoidCallback? onBack;
  final VoidCallback? onReturnHome;
  final VoidCallback? onStartAnotherSession;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is! AttendanceReady) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final session = state.session;
          final periodLabel = switch (session.period) {
            'صباحي' => 'الفترة الصباحية (لياقة)',
            'إضافي' => 'حصة تدريبية إضافية',
            _ => 'الفترة المسائية (الرئيسية)',
          };

          return Scaffold(
            backgroundColor: AppColors.canvas,
            appBar: AppBar(
              title: Text(
                session.isLocked
                    ? 'خلاصة التمرين المرحّل'
                    : 'مراجعة التمرين والترحيل',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: (!session.isLocked && onBack != null)
                  ? IconButton(
                      icon: const Icon(LucideIcons.arrowRight),
                      tooltip: 'رجوع للتحضير',
                      onPressed: onBack,
                    )
                  : (session.isLocked && onReturnHome != null)
                      ? IconButton(
                          icon: const Icon(LucideIcons.home),
                          tooltip: 'الرئيسية',
                          onPressed: onReturnHome,
                        )
                      : null,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (session.isLocked) ...[
                    _buildSuccessBanner(context, periodLabel),
                    const SizedBox(height: 12),
                    const LockedSessionBanner(),
                    const SizedBox(height: 16),
                  ],

                  // Session Details Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.royalBlue.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                LucideIcons.calendarCheck2,
                                color: AppColors.royalBlue,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.sessionTitle,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${session.location} • $periodLabel',
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
                        ),
                        const Divider(height: 24),
                        _statRow(
                          context,
                          'إجمالي اللاعبين بالكشف',
                          '${session.totalCount}',
                          AppColors.textPrimary,
                        ),
                        const SizedBox(height: 8),
                        _statRow(
                          context,
                          'حاضر بالملعب',
                          '${session.presentCount}',
                          AppColors.present,
                        ),
                        const SizedBox(height: 8),
                        _statRow(
                          context,
                          'غائب بعذر إداري',
                          '${session.excusedCount}',
                          AppColors.excused,
                        ),
                        const SizedBox(height: 8),
                        _statRow(
                          context,
                          'غائب بدون عذر',
                          '${session.unexcusedCount}',
                          AppColors.unexcused,
                        ),
                        if (session.unmarkedCount > 0) ...[
                          const SizedBox(height: 8),
                          _statRow(
                            context,
                            'غير محدد',
                            '${session.unmarkedCount}',
                            AppColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  if (!session.isLocked) ...[
                    AppButton(
                      label: '🔒 ترحيل التمرين المباشر واعتماده',
                      leadingIcon: LucideIcons.lockKeyhole,
                      onPressed: () => _dispatch(context),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'بالترحيل المباشر يُقفل التمرين فوراً ويُدرج في الكشوفات الرسمية',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ] else ...[
                    // When locked, provide primary navigation buttons
                    AppButton(
                      label: 'العودة إلى الشاشة الرئيسية',
                      leadingIcon: LucideIcons.home,
                      onPressed: onReturnHome ?? () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: 12),
                    if (onStartAnotherSession != null) ...[
                      OutlinedButton.icon(
                        onPressed: onStartAnotherSession,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          side: const BorderSide(color: AppColors.royalBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          LucideIcons.plusCircle,
                          size: 18,
                          color: AppColors.royalBlue,
                        ),
                        label: const Text(
                          'بدء تحضير تمرين آخر لنفس اليوم',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            color: AppColors.royalBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Optional QR Export for air-gap sync
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BlocProvider<SyncBloc>(
                              create: (_) => serviceLocator<SyncBloc>(),
                              child: FieldQrDisplayScreen(session: session),
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(LucideIcons.qrCode, size: 16),
                      label: const Text(
                        '📲 (اختياري) تصدير كود QR لجهاز خارجي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );

  Widget _buildSuccessBanner(BuildContext context, String periodLabel) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.presentBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.present.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(
              LucideIcons.checkCheck,
              color: AppColors.present,
              size: 26,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تم ترحيل التمرين واعتماده بنجاح',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.present,
                    ),
                  ),
                  Text(
                    'الكشف مقفل إدارياً وأصبح متاحاً مباشرة في السجلات الرسمية.',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _statRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      );

  Future<void> _dispatch(BuildContext context) async {
    final state = context.read<AttendanceBloc>().state;
    if (state is AttendanceReady && state.session.unmarkedCount > 0) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(LucideIcons.alertTriangle, color: Color(0xFFD97706), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تعذر الترحيل: كشف غير مكتمل',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'لا يمكن ترحيل التمرين واعتماده إدارياً حتى يتم رصد جميع اللاعبين.\n\nيوجد حالياً ${state.session.unmarkedCount} لاعبين لم يتم تحديد حالتهم (حاضر، غائب، أو بعذر).',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                if (onBack != null) onBack!();
              },
              child: const Text(
                'العودة لرصد المتبقين',
                style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'ترحيل التمرين واعتماده إدارياً؟',
      message:
          'سيُقفل التمرين نهائياً ويُعتمد رسمياً في سجلات وكشوفات النادي، ولن تتمكن من تعديل حالات اللاعبين بعد الترحيل.',
      confirmLabel: 'ترحيل وقفل قطعي',
    );
    if (confirmed && context.mounted) {
      context.read<AttendanceBloc>().add(const DispatchSessionEvent());
    }
  }
}
