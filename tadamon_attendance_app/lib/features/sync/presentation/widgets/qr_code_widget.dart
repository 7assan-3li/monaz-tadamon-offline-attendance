import 'package:flutter/material.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/features/sync/data/datasources/qr_matrix_generator.dart';

class QrCodeWidget extends StatelessWidget {
  const QrCodeWidget({
    required this.data,
    this.size = 240,
    super.key,
  });

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    final matrix = const QrMatrixGenerator().generate(data);

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _QrPainter(matrix: matrix, color: AppColors.textPrimary),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  const _QrPainter({required this.matrix, required this.color});

  final List<List<bool>> matrix;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (matrix.isEmpty) return;
    final moduleCount = matrix.length;
    final modulePixelSize = size.width / moduleCount;
    final paint = Paint()..color = color;

    for (var r = 0; r < moduleCount; r++) {
      for (var c = 0; c < moduleCount; c++) {
        if (matrix[r][c]) {
          final rect = Rect.fromLTWH(
            c * modulePixelSize,
            r * modulePixelSize,
            modulePixelSize,
            modulePixelSize,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) =>
      oldDelegate.matrix != matrix || oldDelegate.color != color;
}
