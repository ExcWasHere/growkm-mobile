import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/market_colors.dart';
import '../models/market_models.dart';

class MarketSummaryCard extends StatelessWidget {
  final OpportunitySummary summary;
  final bool refreshing;
  final VoidCallback onRefresh;

  const MarketSummaryCard({
    super.key,
    required this.summary,
    required this.refreshing,
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
                  color: MarketColors.orange,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(LucideIcons.barChart3, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ringkasan Peluang', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: MarketColors.gray800)),
                    const Text('Diperbarui otomatis', style: TextStyle(fontSize: 11.5, color: MarketColors.gray500)),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: refreshing ? null : onRefresh,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (refreshing)
                        const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(strokeWidth: 2, color: MarketColors.orange),
                        )
                      else
                        const Icon(LucideIcons.refreshCw, size: 14, color: MarketColors.orange),
                      const SizedBox(width: 5),
                      const Text('Perbarui', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: MarketColors.orange)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildStat('${summary.eligibleCount}', 'Eligible', 'bisa apply', MarketColors.green100, MarketColors.green700)),
              const SizedBox(width: 10),
              Expanded(child: _buildStat('${summary.almostCount}', 'Hampir', 'kurang 1-2 step', MarketColors.amber100, MarketColors.orangeDark)),
              const SizedBox(width: 10),
              Expanded(child: _buildStat('${summary.lockedCount}', 'Terkunci', 'selesaikan dulu', MarketColors.gray100, MarketColors.gray600)),
            ],
          ),
          if (summary.almostCount > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: MarketColors.amber50, borderRadius: BorderRadius.circular(14), border: Border.all(color: MarketColors.amber200)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 12.5, color: MarketColors.orangeDark, height: 1.4),
                        children: [
                          const TextSpan(text: 'Kamu punya '),
                          TextSpan(text: '${summary.almostCount} peluang', style: const TextStyle(fontWeight: FontWeight.w800)),
                          const TextSpan(text: ' yang hampir bisa diakses! Selesaikan izin berikutnya di roadmap untuk unlock mereka.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(String count, String label, String sub, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: fg)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: fg)),
          Text(sub, style: TextStyle(fontSize: 9.5, color: fg.withOpacity(0.75))),
        ],
      ),
    );
  }
}