import 'package:flutter/material.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';

class QrCameraOverlay extends StatelessWidget {
  const QrCameraOverlay({
    this.viewfinderSize = 250,
    super.key,
  });

  final double viewfinderSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final left = (width - viewfinderSize) / 2;
        final top = (height - viewfinderSize) / 2 - 40;

        return Stack(
          children: [
            // Darkened vignette background
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0x8A000000),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Container(
                      color: Colors.black,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    width: viewfinderSize,
                    height: viewfinderSize,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Border outline and corners
            Positioned(
              left: left,
              top: top,
              width: viewfinderSize,
              height: viewfinderSize,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.royalBlue,
                    width: 3,
                  ),
                ),
              ),
            ),
            // Instructional labels
            Positioned(
              left: 24,
              right: 24,
              top: top - 60,
              child: const Text(
                'وجّه الكاميرا نحو كود الترحيل في جهاز الميدان',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: top + viewfinderSize + 24,
              child: const Text(
                'يتم المسح والاستيراد تلقائياً في أقل من ثانيتين',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
