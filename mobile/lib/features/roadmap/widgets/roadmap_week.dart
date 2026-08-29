import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/roadmap_colors.dart';
import '../models/roadmap_models.dart';
import 'roadmap_task.dart';

class RoadmapWeekSection extends StatefulWidget {
  final ActionPlanWeek week;
  final bool initiallyExpanded;

  const RoadmapWeekSection({super.key, required this.week, this.initiallyExpanded = false});

  @override
  State<RoadmapWeekSection> createState() => _RoadmapWeekSectionState();
}

class _RoadmapWeekSectionState extends State<RoadmapWeekSection> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final w = widget.week;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: RoadmapColors.gray200)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: RoadmapColors.amber100, borderRadius: BorderRadius.circular(10)),
                    child: Text('${w.week}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: RoadmapColors.orangeDark)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Minggu ${w.week}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RoadmapColors.gray500)),
                        Text(w.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: RoadmapColors.gray800)),
                      ],
                    ),
                  ),
                  Icon(_expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16, color: RoadmapColors.gray400),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(children: w.tasks.map((t) => RoadmapTaskItem(task: t)).toList()),
            ),
        ],
      ),
    );
  }
}