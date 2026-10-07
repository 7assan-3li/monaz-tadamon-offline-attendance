import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({required this.onChanged, super.key});
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    decoration: const InputDecoration(
      hintText: 'البحث باسم اللاعب',
      prefixIcon: Icon(LucideIcons.search),
      filled: true,
    ),
  );
}
