import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/roadmap_colors.dart';
import '../models/roadmap_models.dart';

class RoadmapStatusBadge extends StatelessWidget {
  final RoadmapStepStatus status;

  const RoadmapStatusBadge({super.key, required this.status});

  ({Color fg, Color bg, IconData icon}) get _style => switch (status) {
        RoadmapStepStatus.completed => (fg: RoadmapColors.green700, bg: RoadmapColors.green100, icon: LucideIcons.checkCircle2),
        RoadmapStepStatus.inProgress => (fg: RoadmapColors.blue500, bg: RoadmapColors.blue50, icon: LucideIcons.loader),
        RoadmapStepStatus.unlocked => (fg: RoadmapColors.orangeDark, bg: RoadmapColors.amber100, icon: LucideIcons.unlock),
        RoadmapStepStatus.locked => (fg: RoadmapColors.gray500, bg: RoadmapColors.gray100, icon: LucideIcons.lock),
      };

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 12, color: s.fg),
          const SizedBox(width: 5),
          Text(status.label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: s.fg)),
        ],
      ),
    );
  }
}