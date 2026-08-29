import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/market_colors.dart';
import '../models/market_models.dart';
import 'market_recommendation.dart';

class MarketAdvisorCard extends StatelessWidget {
  final bool loading;
  final String? error;
  final AdvisorResult? result;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onRefresh;

  const MarketAdvisorCard({
    super.key,
    required this.loading,
    required this.error,
    required this.result,
    required this.expanded,
    required this.onToggleExpand,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MarketColors.amber200),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [MarketColors.amber, MarketColors.orange]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        const Text('Rekomendasi AI Advisor', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: MarketColors.gray800)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [MarketColors.amber, MarketColors.orange]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('LEXA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                        ),
                      ],
                    ),
                    Text(
                      result != null ? '${result!.recommendations.length} rekomendasi personal untukmu' : 'Menyusun rekomendasi untukmu...',
                      style: const TextStyle(fontSize: 11.5, color: MarketColors.gray500),
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: loading ? null : onRefresh,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: loading
                      ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: MarketColors.orange))
                      : const Icon(LucideIcons.refreshCw, size: 15, color: MarketColors.orange),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onToggleExpand,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16, color: MarketColors.gray500),
                ),
              ),
            ],
          ),
          if (expanded) ...[
            const SizedBox(height: 14),
            if (error != null)
              Text(error!, style: const TextStyle(fontSize: 12.5, color: MarketColors.gray500))
            else if (result != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: MarketColors.amber50, borderRadius: BorderRadius.circular(12), border: Border.all(color: MarketColors.amber200)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.checkCircle2, size: 14, color: MarketColors.orangeDark),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(result!.userContextSummary, style: const TextStyle(fontSize: 12, color: MarketColors.orangeDark, height: 1.5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(':-)', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Text(
                    'Top ${result!.recommendations.length} peluang terbaik khusus untuk usahamu',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: MarketColors.gray600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...result!.recommendations.map((r) => MarketRecommendationItem(recommendation: r)),
            ],
          ],
        ],
      ),
    );
  }
}