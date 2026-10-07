import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/core/widgets/squircle_icon_container.dart';
import 'package:tadamon_attendance_app/features/activation/domain/entities/activated_license.dart';
import 'package:tadamon_attendance_app/features/activation/presentation/bloc/activation_bloc.dart';
import 'package:tadamon_attendance_app/features/activation/presentation/bloc/activation_event.dart';
import 'package:tadamon_attendance_app/features/activation/presentation/bloc/activation_state.dart';

final class ActivationScreen extends StatefulWidget {
  const ActivationScreen({
    required this.deviceId,
    required this.onActivated,
    super.key,
  });

  final String deviceId;
  final ValueChanged<ActivatedLicense> onActivated;

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

final class _ActivationScreenState extends State<ActivationScreen> {
  final _activationCodeController = TextEditingController();

  @override
  void dispose() {
    _activationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivationBloc, ActivationState>(
      listener: (context, state) {
        if (state case ActivationSucceeded(:final license)) {
          widget.onActivated(license);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('تفعيل النظام')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Center(
              child: SquircleIconContainer(
                icon: LucideIcons.shieldCheck,
                color: AppColors.royalBlue,
                semanticLabel: 'حماية الترخيص',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تفعيل جهاز النادي',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'انسخ معرّف الجهاز وأرسله إلى مسؤول الترخيص، ثم أدخل كود التفعيل الصادر للجهاز.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معرّف الجهاز',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    widget.deviceId,
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'نسخ معرّف الجهاز',
                    leadingIcon: LucideIcons.copy,
                    variant: AppButtonVariant.secondary,
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: widget.deviceId)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _activationCodeController,
              minLines: 3,
              maxLines: 6,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                labelText: 'كود التفعيل',
                hintText: 'ألصق كود التفعيل هنا',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<ActivationBloc, ActivationState>(
              builder: (context, state) {
                if (state case ActivationFailed(:final message)) {
                  return Text(
                    message,
                    style: const TextStyle(color: AppColors.unexcused),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: BlocBuilder<ActivationBloc, ActivationState>(
            builder: (context, state) => AppButton(
              label: state is ActivationInProgress
                  ? 'جارٍ التحقق...'
                  : 'تفعيل النظام',
              leadingIcon: LucideIcons.keyRound,
              onPressed: state is ActivationInProgress
                  ? null
                  : () => context.read<ActivationBloc>().add(
                      ActivationSubmitted(
                        activationCode: _activationCodeController.text,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
