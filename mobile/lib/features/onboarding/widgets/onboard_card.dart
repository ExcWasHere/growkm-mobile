import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/onboard_colors.dart';

class OnboardingChoiceCard extends StatelessWidget {
  final String label;
  final String? sublabel;
  final bool selected;
  final VoidCallback onTap;

  const OnboardingChoiceCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? OnboardingColors.amber50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? OnboardingColors.orange : OnboardingColors.gray200, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? OnboardingColors.orangeDark : OnboardingColors.gray800,
                    ),
                  ),
                  if (sublabel != null) ...[
                    const SizedBox(height: 2),
                    Text(sublabel!, style: const TextStyle(fontSize: 12, color: OnboardingColors.gray500)),
                  ],
                ],
              ),
            ),
            if (selected)
              const Icon(LucideIcons.checkCircle2, size: 20, color: OnboardingColors.orange)
            else
              Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: OnboardingColors.gray300))),
          ],
        ),
      ),
    );
  }
}