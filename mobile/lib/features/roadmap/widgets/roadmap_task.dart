import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/roadmap_colors.dart';
import '../models/roadmap_models.dart';

class RoadmapTaskItem extends StatelessWidget {
  final ActionPlanTask task;

  const RoadmapTaskItem({super.key, required this.task});

  ({Color fg, Color bg, IconData icon}) get _tagStyle => switch (task.tag) {
        'dokumen' => (fg: RoadmapColors.blue500, bg: RoadmapColors.blue50, icon: LucideIcons.fileText),
        'online' => (fg: RoadmapColors.orangeDark, bg: RoadmapColors.amber100, icon: LucideIcons.globe),
        'review' => (fg: RoadmapColors.green600, bg: RoadmapColors.green100, icon: LucideIcons.search),
        _ => (fg: RoadmapColors.gray500, bg: RoadmapColors.gray100, icon: LucideIcons.circleDot),
      };

  @override
  Widget build(BuildContext context) {
    final tag = _tagStyle;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: RoadmapColors.gray50, borderRadius: BorderRadius.circular(14), border: Border.all(color: RoadmapColors.gray200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: RoadmapColors.gray200)),
                child: Text('H${task.day}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: RoadmapColors.gray600)),
              ),
              const SizedBox(width: 8),
              if (task.tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: tag.bg, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tag.icon, size: 10, color: tag.fg),
                      const SizedBox(width: 4),
                      Text(task.tag!, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: tag.fg)),
                    ],
                  ),
                ),
              const Spacer(),
              Icon(LucideIcons.clock, size: 11, color: RoadmapColors.gray400),
              const SizedBox(width: 4),
              Text(task.duration, style: const TextStyle(fontSize: 10.5, color: RoadmapColors.gray500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(task.task, style: const TextStyle(fontSize: 12.5, color: RoadmapColors.gray800, height: 1.45)),
          if (task.tip != null && task.tip!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: RoadmapColors.amber50, borderRadius: BorderRadius.circular(10), border: Border.all(color: RoadmapColors.amber200)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.lightbulb, size: 12, color: RoadmapColors.orangeDark),
                  const SizedBox(width: 6),
                  Expanded(child: Text(task.tip!, style: const TextStyle(fontSize: 11, color: RoadmapColors.orangeDark, height: 1.4))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}