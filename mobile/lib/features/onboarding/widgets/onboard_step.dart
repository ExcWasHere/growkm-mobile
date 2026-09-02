import 'package:flutter/material.dart';
import '../theme/onboard_colors.dart';
import '../models/onboard_models.dart';
import 'onboard_button.dart';
import 'onboard_mascot.dart';
import 'onboard_progress.dart';

class OnboardingStepScaffold extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final MascotPose mascot;
  final String question;
  final Widget content;
  final bool canContinue;
  final bool submitting;
  final VoidCallback onContinue;
  final String continueLabel;
  final VoidCallback? onSkip;
  final bool centerMascot;

  const OnboardingStepScaffold({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.mascot,
    required this.question,
    required this.content,
    required this.canContinue,
    required this.onContinue,
    this.onBack,
    this.submitting = false,
    this.continueLabel = 'Lanjutkan',
    this.onSkip,
    this.centerMascot = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: [
            OnboardingProgressHeader(currentStep: currentStep, totalSteps: totalSteps, onBack: onBack),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(currentStep),
                  child: centerMascot ? _buildCenteredBody() : _buildDefaultBody(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (onSkip != null) ...[
              TextButton(
                onPressed: submitting ? null : onSkip,
                child: const Text('Lewati', style: TextStyle(color: OnboardingColors.gray500, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 4),
            ],
            OnboardingContinueButton(
              enabled: canContinue,
              loading: submitting,
              label: continueLabel,
              onPressed: onContinue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingMascotBubble(pose: mascot, message: question),
        const SizedBox(height: 24),
        Expanded(child: SingleChildScrollView(child: content)),
      ],
    );
  }

  Widget _buildCenteredBody() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingMascotCentered(pose: mascot, message: question),
            if (content is! SizedBox) ...[
              const SizedBox(height: 20),
              content,
            ],
          ],
        ),
      ),
    );
  }
}