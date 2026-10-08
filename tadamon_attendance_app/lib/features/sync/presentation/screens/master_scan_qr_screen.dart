import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/sync_result.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_event.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_state.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/widgets/qr_camera_overlay.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/widgets/sync_success_dialog.dart';

class MasterScanQrScreen extends StatefulWidget {
  const MasterScanQrScreen({
    this.onSessionImported,
    super.key,
  });

  final VoidCallback? onSessionImported;

  @override
  State<MasterScanQrScreen> createState() => _MasterScanQrScreenState();
}

class _MasterScanQrScreenState extends State<MasterScanQrScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submitCode(String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return;
    HapticFeedback.lightImpact();
    context.read<SyncBloc>().add(ImportQrRequested(trimmed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('استقبال تمرين مرحّل'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state is SyncFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.unexcused,
              ),
            );
          } else if (state is SyncSuccessState) {
            final result = state.result;
            if (result.status == SyncStatus.duplicate) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(LucideIcons.info, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text(result.message)),
                    ],
                  ),
                  backgroundColor: AppColors.excused,
                  duration: const Duration(seconds: 4),
                ),
              );
            } else if (result.status == SyncStatus.success) {
              showSyncSuccessDialog(
                context: context,
                sessionUuid: result.sessionUuid,
                playersCount: result.importedItemsCount,
                onConfirm: () {
                  widget.onSessionImported?.call();
                  Navigator.of(context).pop();
                },
              );
            } else if (result.status == SyncStatus.invalidSignature) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.message),
                  backgroundColor: AppColors.unexcused,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // 1. Camera viewfinder overlay
              const QrCameraOverlay(viewfinderSize: 260),

              // 2. Bottom Thumb Zone Controls
              Positioned(
                left: 20,
                right: 20,
                bottom: 30,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state is SyncLoading)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    else ...[
                      AppButton(
                        label: 'إدخال / لصق كود الترحيل',
                        leadingIcon: LucideIcons.clipboardPaste,
                        onPressed: () => _showManualInputDialog(context),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        icon: const Icon(LucideIcons.camera, color: Colors.white70),
                        label: const Text(
                          'مسح تلقائي عبر الحافظة',
                          style: TextStyle(color: Colors.white70),
                        ),
                        onPressed: () async {
                          final data = await Clipboard.getData(Clipboard.kTextPlain);
                          if (data?.text != null && context.mounted) {
                            _submitCode(data!.text!);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showManualInputDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'إدخال كود الترحيل يدوياً',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'يمكنك لصق كود الترحيل الصادر من جهاز الميدان مباشرة للاستيراد:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'ألصق كود JSON أو التوقيع هنا...',
                  filled: true,
                  fillColor: AppColors.canvas,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'استيراد التمرين الآن',
                leadingIcon: LucideIcons.downloadCloud,
                onPressed: () {
                  final text = _codeController.text;
                  Navigator.of(bottomSheetContext).pop();
                  _submitCode(text);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
