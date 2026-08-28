import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/market_colors.dart';
import '../models/market_models.dart';
import '../pages/market_link.dart';
import 'market_badges.dart';

Future<void> showMarketDetailSheet(BuildContext context, Opportunity o) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _MarketDetailSheet(opportunity: o),
  );
}

class _MarketDetailSheet extends StatelessWidget {
  final Opportunity opportunity;

  const _MarketDetailSheet({required this.opportunity});

  String _formatDate(DateTime d) {
    const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: MarketColors.gray200, borderRadius: BorderRadius.circular(4))),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        MarketCategoryBadge(category: o.category),
                        MarketStatusBadge(status: o.matchStatus),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(o.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: MarketColors.gray800, height: 1.3)),
                    const SizedBox(height: 4),
                    Text(o.provider, style: const TextStyle(fontSize: 13, color: MarketColors.gray500)),
                    const SizedBox(height: 16),
                    if (o.description != null) ...[
                      Text(o.description!, style: const TextStyle(fontSize: 13.5, color: MarketColors.gray600, height: 1.5)),
                      const SizedBox(height: 16),
                    ],
                    if (o.estimatedValue != null) _sectionBox(
                      icon: LucideIcons.star,
                      title: o.estimatedValue!,
                      subtitle: o.valueDescription,
                    ),
                    const SizedBox(height: 12),
                    const Text('SYARAT UTAMA', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: MarketColors.gray400, letterSpacing: 0.4)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: o.requiredSteps
                          .map((step) => MarketRequirementChip(step: step, satisfied: !o.missingSteps.contains(step)))
                          .toList(),
                    ),
                    if (o.niceToHaveSteps.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('NILAI TAMBAH (OPSIONAL)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: MarketColors.gray400, letterSpacing: 0.4)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: o.niceToHaveSteps
                            .map((step) => MarketRequirementChip(step: step, satisfied: !o.missingSteps.contains(step)))
                            .toList(),
                      ),
                    ],
                    if (o.additionalRequirements.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('SYARAT TAMBAHAN', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: MarketColors.gray400, letterSpacing: 0.4)),
                      const SizedBox(height: 8),
                      ...o.additionalRequirements.map(
                        (req) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Icon(LucideIcons.dot, size: 14, color: MarketColors.gray400),
                              ),
                              Expanded(child: Text(req, style: const TextStyle(fontSize: 12.5, color: MarketColors.gray600, height: 1.4))),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (o.deadline != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(LucideIcons.calendar, size: 14, color: MarketColors.gray500),
                          const SizedBox(width: 6),
                          Text('Deadline: ${_formatDate(o.deadline!)}', style: const TextStyle(fontSize: 12.5, color: MarketColors.gray600, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (o.sourceUrl != null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => openExternalLink(o.sourceUrl),
                          icon: const Icon(LucideIcons.externalLink, size: 15),
                          label: const Text('Buka Sumber Resmi'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: MarketColors.amber200),
                            foregroundColor: MarketColors.orangeDark,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionBox({required IconData icon, required String title, String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: MarketColors.amber50, borderRadius: BorderRadius.circular(12), border: Border.all(color: MarketColors.amber200)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: MarketColors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: MarketColors.gray800)),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(fontSize: 11.5, color: MarketColors.gray600, height: 1.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}