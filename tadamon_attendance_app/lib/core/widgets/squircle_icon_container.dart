import 'package:flutter/material.dart';

class SquircleIconContainer extends StatelessWidget {
  const SquircleIconContainer({
    required this.icon,
    required this.color,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
