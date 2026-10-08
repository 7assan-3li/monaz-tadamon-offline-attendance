import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_event.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_state.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/widgets/qr_code_widget.dart';

class FieldQrDisplayScreen extends StatefulWidget {
  const FieldQrDisplayScreen({
    required this.session,
    super.key,
  });

  final AttendanceSession session;

  @override
  State<FieldQrDisplayScreen> createState() => _FieldQrDisplayScreenState();
}

class _FieldQrDisplayScreenState extends State<FieldQrDisplayScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SyncBloc>().add(GenerateQrRequested(widget.session));
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('كود الترحيل الميداني'),
        centerTitle: true,
      ),
      body: BlocConsumer<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state is SyncFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SyncLoading || state is SyncInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! QrGeneratedState) {
            return Center(
              child: Text(
                'تعذر توليد كود الترحيل',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          final qrData = state.qrData;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.lock, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'مرحّل ومقفل إدارياً 🔒',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  QrCodeWidget(
                    data: qrData,
                    size: 260,
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.scanLine, size: 20, color: AppColors.royalBlue),
                      SizedBox(width: 8),
                      Text(
                        'بانتظار مسح كود الترحيل من جهاز الإدارة',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.royalBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metric(
                          title: 'حاضر',
                          count: session.presentCount,
                          color: AppColors.present,
                        ),
                        _metric(
                          title: 'بعذر',
                          count: session.excusedCount,
                          color: AppColors.excused,
                        ),
                        _metric(
                          title: 'بدون عذر',
                          count: session.unexcusedCount,
                          color: AppColors.unexcused,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'نسخ كود الترحيل الاحتياطي',
                    leadingIcon: LucideIcons.copy,
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: qrData));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ كود الترحيل الاحتياطي بنجاح.'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _metric({
    required String title,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
