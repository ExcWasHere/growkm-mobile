import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/market_colors.dart';
import '../models/market_models.dart';
import '../pages/market_link.dart';
import 'market_badges.dart';

class MarketOpportunityCard extends StatefulWidget {
  final Opportunity opportunity;
  final VoidCallback onTapDetail;

  const MarketOpportunityCard({super.key, required this.opportunity, required this.onTapDetail});

  @override
  State<MarketOpportunityCard> createState() => _MarketOpportunityCardState();
}

class _MarketOpportunityCardState extends State<MarketOpportunityCard> {
  bool _expanded = false;

  Color get _accentColor => switch (widget.opportunity.matchStatus) {
        MatchStatus.eligible => MarketColors.green500,
        MatchStatus.almost => MarketColors.orange,
        MatchStatus.locked => MarketColors.gray400,
      };

  @override
  Widget build(BuildContext context) {
    final o = widget.opportunity;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MarketColors.gray200),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 4, color: _accentColor),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          MarketCategoryBadge(category: o.category),
                          MarketStatusBadge(status: o.matchStatus),
                        ],
                      ),
                    ),
                    MarketStatusIcon(status: o.matchStatus),
                  ],
                ),
                const SizedBox(height: 10),
                Text(o.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: MarketColors.gray800, height: 1.3)),
                const SizedBox(height: 2),
                Text(o.provider, style: const TextStyle(fontSize: 12, color: MarketColors.gray500)),
                const SizedBox(height: 8),
                if (o.estimatedValue != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 2), child: Icon(LucideIcons.star, size: 13, color: MarketColors.amber)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          o.estimatedValue!,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: MarketColors.gray800),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 14, color: MarketColors.gray500),
                      const SizedBox(width: 4),
                      Text(
                        _expanded ? 'Sembunyikan detail' : 'Lihat detail syarat',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MarketColors.gray500),
                      ),
                    ],
                  ),
                ),
                if (_expanded) ...[
                  const SizedBox(height: 10),
                  const Text('SYARAT', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: MarketColors.gray400, letterSpacing: 0.4)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: o.requiredSteps
                        .map((step) => MarketRequirementChip(step: step, satisfied: !o.missingSteps.contains(step)))
                        .toList(),
                  ),
                  if (o.deadline != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(LucideIcons.calendar, size: 13, color: MarketColors.gray500),
                        const SizedBox(width: 6),
                        Text('Deadline: ${_formatDate(o.deadline!)}', style: const TextStyle(fontSize: 12, color: MarketColors.gray600)),
                      ],
                    ),
                  ],
                  if (o.matchStatus != MatchStatus.eligible && o.missingSteps.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: MarketColors.amber50, borderRadius: BorderRadius.circular(12), border: Border.all(color: MarketColors.amber200)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(LucideIcons.alertCircle, size: 14, color: MarketColors.orangeDark),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(fontSize: 11.5, color: MarketColors.orangeDark, height: 1.4),
                                children: [
                                  const TextSpan(text: 'Selesaikan '),
                                  TextSpan(
                                    text: o.missingSteps.map((s) => s.label).join(', '),
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  const TextSpan(text: ' untuk unlock peluang ini'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: o.isLocked
                          ? OutlinedButton(
                              onPressed: widget.onTapDetail,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: MarketColors.amber200),
                                foregroundColor: MarketColors.orangeDark,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Cara Unlock', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                                  SizedBox(width: 6),
                                  Icon(LucideIcons.arrowRight, size: 14),
                                ],
                              ),
                            )
                          : InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: widget.onTapDetail,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: MarketColors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Lihat Detail', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5)),
                                    SizedBox(width: 6),
                                    Icon(LucideIcons.chevronRight, size: 14, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    if (o.sourceUrl != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => openExternalLink(o.sourceUrl),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(border: Border.all(color: MarketColors.gray200), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(LucideIcons.externalLink, size: 16, color: MarketColors.gray500),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }
}