import 'package:flutter/material.dart';
import '../theme/onboard_colors.dart';

class OnboardingContinueButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  const OnboardingContinueButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    this.label = 'Lanjutkan',
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: (enabled && !loading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: OnboardingColors.orange,
          disabledBackgroundColor: OnboardingColors.gray200,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
            : Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: enabled ? Colors.white : OnboardingColors.gray500,
                ),
              ),
      ),
    );
  }
}