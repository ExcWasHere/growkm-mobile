import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/market_colors.dart';
import '../models/market_models.dart';

class MarketCategoryBadge extends StatelessWidget {
  final OpportunityCategory category;

  const MarketCategoryBadge({super.key, required this.category});

  ({Color fg, Color bg, IconData icon}) get _style => switch (category) {
        OpportunityCategory.programPemerintah => (fg: MarketColors.teal600, bg: MarketColors.teal100, icon: LucideIcons.landmark),
        OpportunityCategory.marketplace => (fg: MarketColors.pink600, bg: MarketColors.pink100, icon: LucideIcons.shoppingBag),
        OpportunityCategory.vendorSupplyChain => (fg: MarketColors.violet600, bg: MarketColors.violet100, icon: LucideIcons.building2),
        OpportunityCategory.pembiayaan => (fg: MarketColors.blue600, bg: MarketColors.blue100, icon: LucideIcons.banknote),
        OpportunityCategory.eventPameran => (fg: MarketColors.rose600, bg: MarketColors.rose100, icon: LucideIcons.calendar),
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
          Text(category.label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: s.fg)),
        ],
      ),
    );
  }
}

class MarketStatusBadge extends StatelessWidget {
  final MatchStatus status;
  final bool compact;

  const MarketStatusBadge({super.key, required this.status, this.compact = false});

  ({Color fg, Color bg, IconData icon}) get _style => switch (status) {
        MatchStatus.eligible => (fg: MarketColors.green700, bg: MarketColors.green100, icon: LucideIcons.checkCircle2),
        MatchStatus.almost => (fg: MarketColors.orangeDark, bg: MarketColors.amber100, icon: LucideIcons.trendingUp),
        MatchStatus.locked => (fg: MarketColors.gray500, bg: MarketColors.gray100, icon: LucideIcons.lock),
      };

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: compact ? 10 : 12, color: s.fg),
          const SizedBox(width: 4),
          Text(status.label, style: TextStyle(fontSize: compact ? 9.5 : 10.5, fontWeight: FontWeight.w700, color: s.fg)),
        ],
      ),
    );
  }
}

class MarketStatusIcon extends StatelessWidget {
  final MatchStatus status;

  const MarketStatusIcon({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (status) {
      MatchStatus.eligible => (MarketColors.green100, MarketColors.green600, LucideIcons.checkCircle2),
      MatchStatus.almost => (MarketColors.amber100, MarketColors.orangeDark, LucideIcons.trendingUp),
      MatchStatus.locked => (MarketColors.gray100, MarketColors.gray400, LucideIcons.lock),
    };
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 14, color: fg),
    );
  }
}

class MarketRequirementChip extends StatelessWidget {
  final StepType step;
  final bool satisfied;

  const MarketRequirementChip({super.key, required this.step, required this.satisfied});

  @override
  Widget build(BuildContext context) {
    final color = satisfied ? MarketColors.green600 : MarketColors.red600;
    final bg = satisfied ? MarketColors.green50 : MarketColors.red50;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(satisfied ? LucideIcons.checkCircle2 : LucideIcons.xCircle, size: 12, color: color),
          const SizedBox(width: 5),
          Text(step.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}