import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/roadmap_colors.dart';
import '../models/roadmap_models.dart';
import 'roadmap_badge.dart';

class RoadmapStepTile extends StatelessWidget {
  final RoadmapStep step;
  final VoidCallback onTap;

  const RoadmapStepTile({super.key, required this.step, required this.onTap});

  bool get _isLocked => step.status == RoadmapStepStatus.locked;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isLocked ? 0.6 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: step.status == RoadmapStepStatus.completed ? RoadmapColors.green200 : RoadmapColors.gray200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: step.status == RoadmapStepStatus.completed ? RoadmapColors.green100 : RoadmapColors.amber100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${step.stepOrder}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: step.status == RoadmapStepStatus.completed ? RoadmapColors.green700 : RoadmapColors.orangeDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(step.label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: RoadmapColors.gray800)),
                        if (!step.isRequired) ...[
                          const SizedBox(width: 6),
                          const Text('(opsional)', style: TextStyle(fontSize: 10, color: RoadmapColors.gray400)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(step.description, style: const TextStyle(fontSize: 11, color: RoadmapColors.gray500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    RoadmapStatusBadge(status: step.status),
                  ],
                ),
              ),
              Icon(_isLocked ? LucideIcons.lock : LucideIcons.chevronRight, size: 16, color: RoadmapColors.gray400),
            ],
          ),
        ),
      ),
    );
  }
}