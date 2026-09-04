import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/roadmap_colors.dart';
import '../models/roadmap_models.dart';

class RoadmapPrerequisiteCard extends StatelessWidget {
  final ActionPlanPrerequisiteCheck check;

  const RoadmapPrerequisiteCard({super.key, required this.check});

  @override
  Widget build(BuildContext context) {
    final bg = check.passed ? RoadmapColors.green50 : RoadmapColors.red50;
    final border = check.passed ? RoadmapColors.green200 : RoadmapColors.red500.withOpacity(0.3);
    final fg = check.passed ? RoadmapColors.green700 : RoadmapColors.red500;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(check.passed ? LucideIcons.checkCircle2 : LucideIcons.alertTriangle, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  check.passed ? 'Prasyarat sudah terpenuhi' : 'Ada prasyarat yang perlu dicek',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: fg),
                ),
                const SizedBox(height: 3),
                Text(check.notes, style: TextStyle(fontSize: 11.5, color: fg.withOpacity(0.9), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}