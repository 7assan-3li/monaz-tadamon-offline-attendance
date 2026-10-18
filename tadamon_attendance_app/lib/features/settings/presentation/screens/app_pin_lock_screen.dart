import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/features/settings/domain/repositories/settings_repository.dart';

class AppPinLockScreen extends StatefulWidget {
  const AppPinLockScreen({
    required this.settingsRepository,
    required this.onUnlocked,
    super.key,
  });

  final SettingsRepository settingsRepository;
  final VoidCallback onUnlocked;

  @override
  State<AppPinLockScreen> createState() => _AppPinLockScreenState();
}

class _AppPinLockScreenState extends State<AppPinLockScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _isError = false;
  bool _isVerifying = false;
  bool _hasCustomPin = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _checkPinState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
      });
  }

  Future<void> _checkPinState() async {
    final settings = await widget.settingsRepository.read();
    if (mounted) {
      setState(() {
        _hasCustomPin = settings.hasPin;
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String digit) {
    if (_isVerifying || _pin.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isError = false;
      _pin += digit;
    });

    if (_pin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_isVerifying || _pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isError = false;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);
    final isValid = await widget.settingsRepository.verifyPin(_pin);

    if (!mounted) return;

    if (isValid) {
      HapticFeedback.heavyImpact();
      widget.onUnlocked();
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _isError = true;
        _isVerifying = false;
      });
      _shakeController.forward(from: 0.0);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _pin = '';
          _isError = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            if (isLandscape) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: SingleChildScrollView(
                          child: _buildBrandingAndDots(compact: true),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: constraints.maxHeight * 0.75,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: SingleChildScrollView(
                          child: _buildKeypad(buttonSize: 56),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBrandingAndDots(compact: false),
                    _buildKeypad(buttonSize: 72),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandingAndDots({required bool compact}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact) const SizedBox(height: 10),
        Container(
          width: compact ? 64 : 80,
          height: compact ? 64 : 80,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.royalBlue.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/main_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: compact ? 8 : 14),
        Text(
          'نادي تضامن حضرموت الرياضي',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.shieldCheck,
                size: 13,
                color: Color(0xFF38BDF8),
              ),
              SizedBox(width: 5),
              Text(
                'نظام التحضير الميداني المعتمد',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 12 : 16),
        const Text(
          'أدخل رمز المرور السريع (PIN)',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE2E8F0),
          ),
        ),
        SizedBox(height: compact ? 10 : 16),
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _isError ? _shakeAnimation.value : 0,
                0,
              ),
              child: child,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isFilled = index < _pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isError
                      ? AppColors.unexcused
                      : isFilled
                          ? AppColors.royalBlue
                          : Colors.transparent,
                  border: Border.all(
                    color: _isError
                        ? AppColors.unexcused
                        : isFilled
                            ? AppColors.royalBlue
                            : const Color(0xFF64748B),
                    width: 2,
                  ),
                  boxShadow: isFilled && !_isError
                      ? [
                          BoxShadow(
                            color: AppColors.royalBlue.withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 20,
          child: Text(
            _isError
                ? 'رمز المرور غير صحيح، يرجى المحاولة مرة أخرى'
                : (!_hasCustomPin ? 'رمز الدخول الافتراضي: 1959' : ''),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _isError
                  ? const Color(0xFFF87171)
                  : const Color(0xFF94A3B8),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildKeypad({required double buttonSize}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var col = 1; col <= 3; col++) ...[
                  if (col > 1) const SizedBox(width: 14),
                  _buildKeyButton('${row * 3 + col}', size: buttonSize),
                ],
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: buttonSize, height: buttonSize),
              const SizedBox(width: 14),
              _buildKeyButton('0', size: buttonSize),
              const SizedBox(width: 14),
              SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _onBackspace,
                    borderRadius: BorderRadius.circular(buttonSize / 2),
                    child: Center(
                      child: Icon(
                        LucideIcons.delete,
                        size: buttonSize * 0.38,
                        color: _pin.isEmpty
                            ? const Color(0xFF475569)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyButton(String label, {double size = 72}) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size / 2),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        child: InkWell(
          onTap: () => _onKeyPress(label),
          borderRadius: BorderRadius.circular(size / 2),
          highlightColor: AppColors.royalBlue.withValues(alpha: 0.3),
          splashColor: AppColors.royalBlue.withValues(alpha: 0.2),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: size * 0.36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
