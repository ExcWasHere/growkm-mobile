import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/market_colors.dart';
import '../models/market_models.dart';
import '../pages/market_link.dart';
import 'market_badges.dart';

class MarketRecommendationItem extends StatefulWidget {
  final AdvisorRecommendation recommendation;

  const MarketRecommendationItem({super.key, required this.recommendation});

  @override
  State<MarketRecommendationItem> createState() => _MarketRecommendationItemState();
}

class _MarketRecommendationItemState extends State<MarketRecommendationItem> {
  bool _expanded = false;

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context) {
    final r = widget.recommendation;
    final medal = r.priorityRank >= 1 && r.priorityRank <= 3 ? _medals[r.priorityRank - 1] : '🏅';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MarketColors.gray50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MarketColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(medal, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        MarketStatusBadge(status: r.matchStatus, compact: true),
                        Text('Prioritas #${r.priorityRank}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: MarketColors.gray500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(r.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: MarketColors.gray800, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 13, color: MarketColors.gray500),
                const SizedBox(width: 4),
                Text(
                  _expanded ? 'Sembunyikan alasan' : 'Kenapa direkomendasikan?',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: MarketColors.gray500),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 8),
            _reasonBlock('Kenapa cocok', r.whyThisFits),
            _reasonBlock('Kenapa sekarang', r.whyNow),
            _reasonBlock('Langkah selanjutnya', r.nextStep),
            if (r.caveats != null && r.caveats!.trim().isNotEmpty) _reasonBlock('Catatan', r.caveats!, isWarning: true),
            if (r.sourceUrl != null) ...[
              const SizedBox(height: 4),
              InkWell(
                onTap: () => openExternalLink(r.sourceUrl),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.externalLink, size: 12, color: MarketColors.orangeDark),
                    const SizedBox(width: 5),
                    const Text('Lihat sumber', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: MarketColors.orangeDark)),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _reasonBlock(String label, String text, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.3, color: isWarning ? MarketColors.orangeDark : MarketColors.gray400),
          ),
          const SizedBox(height: 2),
          Text(text, style: const TextStyle(fontSize: 12, color: MarketColors.gray600, height: 1.4)),
        ],
      ),
    );
  }
}