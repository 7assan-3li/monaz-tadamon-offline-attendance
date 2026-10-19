import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/report_storage_service.dart';

class ExportSuccessBottomSheet extends StatelessWidget {
  const ExportSuccessBottomSheet({
    super.key,
    required this.filePath,
    required this.fileName,
    required this.isPdf,
    this.storageService = const ReportStorageService(),
  });

  final String filePath;
  final String fileName;
  final bool isPdf;
  final ReportStorageService storageService;

  static Future<void> show(
    BuildContext context, {
    required String filePath,
    required String fileName,
    required bool isPdf,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExportSuccessBottomSheet(
        filePath: filePath,
        fileName: fileName,
        isPdf: isPdf,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Success Header Icon & Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.present.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.checkCheck,
                    size: 26,
                    color: AppColors.present,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تم تصدير وحفظ التقرير بنجاح',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        isPdf ? 'ملف PDF رسمي معتمد' : 'ملف Excel للجداول الإدارية',
                        style: const TextStyle(
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

            const SizedBox(height: 16),

            // File Information Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPdf ? LucideIcons.fileText : LucideIcons.fileSpreadsheet,
                        size: 18,
                        color: isPdf ? AppColors.royalBlue : AppColors.present,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    filePath,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Primary Button: Native Share Sheet
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.royalBlue,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  storageService.shareReportFile(
                    filePath,
                    subject: 'تقرير نادي تضامن حضرموت',
                    text: 'مرفق تقرير نادي تضامن حضرموت المعتمد: $fileName',
                  );
                },
                icon: const Icon(LucideIcons.share2, size: 18, color: Colors.white),
                label: const Text(
                  'مشاركة التقرير الميداني',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Secondary Row: Open File & Copy Path
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.royalBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        storageService.openReportFile(filePath);
                      },
                      icon: Icon(LucideIcons.externalLink, size: 16, color: AppColors.royalBlue),
                      label: const Text(
                        'فتح ومعاينة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.royalBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderSubtle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: filePath));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تم نسخ مسار حفظ التقرير إلى الحافظة بنجاح.',
                              style: TextStyle(fontFamily: 'Cairo'),
                            ),
                            backgroundColor: AppColors.royalBlue,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.copy, size: 16, color: AppColors.textPrimary),
                      label: const Text(
                        'نسخ المسار',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Close Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'إغلاق',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
