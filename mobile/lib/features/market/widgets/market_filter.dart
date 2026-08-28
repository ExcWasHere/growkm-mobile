import 'package:flutter/material.dart';
import '../theme/market_colors.dart';
import '../models/market_models.dart';

class MarketFilterTabs extends StatelessWidget {
  final MatchStatus? selected;
  final OpportunitySummary summary;
  final ValueChanged<MatchStatus?> onSelect;

  const MarketFilterTabs({
    super.key,
    required this.selected,
    required this.summary,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = <(MatchStatus? status, String label, int count)>[
      (null, 'Semua', summary.total),
      (MatchStatus.eligible, 'Eligible', summary.eligibleCount),
      (MatchStatus.almost, 'Hampir', summary.almostCount),
      (MatchStatus.locked, 'Terkunci', summary.lockedCount),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (status, label, count) = tabs[index];
          final isSelected = status == selected;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onSelect(status),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? const LinearGradient(colors: [MarketColors.amber, MarketColors.orange]) : null,
                color: isSelected ? null : Colors.white,
                border: Border.all(color: isSelected ? Colors.transparent : MarketColors.gray200),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '$label ($count)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : MarketColors.gray600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}