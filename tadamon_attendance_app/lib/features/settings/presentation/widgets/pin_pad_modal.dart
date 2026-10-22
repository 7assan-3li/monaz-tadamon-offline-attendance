import 'package:flutter/material.dart';

Future<String?> showPinPadModal(
  BuildContext context, {
  String? title,
  String? subtitle,
}) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PinPad(
        title: title ?? 'رمز الحماية (PIN)',
        subtitle: subtitle ?? 'أدخل رمز PIN المكون من 4 أرقام للمتابعة.',
      ),
    );

class _PinPad extends StatefulWidget {
  const _PinPad({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  State<_PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<_PinPad> {
  String pin = '';
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            widget.subtitle,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Text(
            '●' * pin.length,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          for (final row in const [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
          ])
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map(_key).toList(),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 56),
              _key(0),
              IconButton(
                onPressed: pin.isEmpty
                    ? null
                    : () => setState(
                        () => pin = pin.substring(0, pin.length - 1),
                      ),
                icon: const Icon(Icons.backspace_outlined),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  Widget _key(int value) => SizedBox(
    width: 56,
    height: 56,
    child: OutlinedButton(
      onPressed: () {
        if (pin.length == 4) return;
        setState(() => pin += '$value');
        if (pin.length == 4) Navigator.pop(context, pin);
      },
      child: Text('$value'),
    ),
  );
}
