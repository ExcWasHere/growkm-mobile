import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/onboard_colors.dart';

class OnboardingProgressHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  const OnboardingProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSteps == 0 ? 0.0 : (currentStep + 1) / totalSteps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onBack,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(LucideIcons.arrowLeft, size: 20, color: onBack != null ? OnboardingColors.gray600 : Colors.transparent),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress.clamp(0, 1)),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: OnboardingColors.gray200,
                    valueColor: const AlwaysStoppedAnimation(OnboardingColors.orange),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 38),
          child: Text(
            'Langkah ${currentStep + 1} dari $totalSteps',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: OnboardingColors.gray500),
          ),
        ),
      ],
    );
  }
}