import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tadamon_attendance_app/core/theme/club_theme_service.dart';

class ClubLogoWidget extends StatelessWidget {
  const ClubLogoWidget({
    this.width = 30,
    this.height = 32,
    this.fit = BoxFit.contain,
    this.semanticLabel = 'شعار النادي المعتمد',
    super.key,
  });

  final double width;
  final double height;
  final BoxFit fit;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: ClubThemeService.instance.logoPathNotifier,
      builder: (context, logoPath, _) {
        if (logoPath != null && logoPath.isNotEmpty) {
          final file = File(logoPath);
          if (file.existsSync()) {
            return Image.file(
              file,
              width: width,
              height: height,
              fit: fit,
              semanticLabel: semanticLabel,
              errorBuilder: (context, error, stackTrace) => _buildFallbackLogo(),
            );
          }
        }
        return _buildFallbackLogo();
      },
    );
  }

  Widget _buildFallbackLogo() {
    return Image.asset(
      'assets/images/main_logo.png',
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
    );
  }
}
