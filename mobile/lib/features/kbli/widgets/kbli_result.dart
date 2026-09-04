import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/kbli_colors.dart';
import '../models/kbli_models.dart';
import 'kbli_confirm.dart';

class KbliResultCard extends StatelessWidget {
  final KbliScanResult result;
  final String? currentKbliCode;
  final KbliConfirmState confirmState;
  final ValueChanged<String> onConfirm;

  const KbliResultCard({
    super.key,
    required this.result,
    required this.currentKbliCode,
    required this.confirmState,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return switch (result) {
      KbliRecommendResult r => _buildRecommend(r),
      KbliValidateResult r => _buildValidate(r),
    };
  }

  Widget _buildRecommend(KbliRecommendResult r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KbliColors.green50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KbliColors.green200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(LucideIcons.checkCircle, size: 22, color: KbliColors.green500),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(r.kbliCode, style: const TextStyle(fontWeight: FontWeight.w900, color: KbliColors.gray800)),
                        const Text('  —  ', style: TextStyle(color: KbliColors.gray400)),
                        Text(r.kbliTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: KbliColors.gray700)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Confidence: ', style: TextStyle(fontSize: 11, color: KbliColors.gray500)),
                        Text(
                          '${(r.confidence * 100).round()}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: KbliColors.green600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(r.explanation, style: const TextStyle(fontSize: 13, color: KbliColors.gray600, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          KbliConfirmSection(
            kbliCode: r.kbliCode,
            state: confirmState,
            onConfirm: () => onConfirm(r.kbliCode),
          ),
        ],
      ),
    );
  }

  Widget _buildValidate(KbliValidateResult r) {
    final hasSuggestion = r.hasSuggestion;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasSuggestion ? KbliColors.orange50 : KbliColors.green50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasSuggestion ? KbliColors.orange200 : KbliColors.green200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  hasSuggestion ? LucideIcons.alertTriangle : LucideIcons.checkCircle,
                  size: 22,
                  color: hasSuggestion ? KbliColors.orange : KbliColors.green500,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((currentKbliCode ?? '').isNotEmpty)
                      Text(currentKbliCode!, style: const TextStyle(fontWeight: FontWeight.w900, color: KbliColors.gray800)),
                    const SizedBox(height: 6),
                    Text(r.explanation, style: const TextStyle(fontSize: 13, color: KbliColors.gray600, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          if (hasSuggestion) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: KbliColors.orange200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KBLI TIDAK SESUAI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: KbliColors.orange700, letterSpacing: 0.4),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        currentKbliCode ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.lineThrough,
                          color: KbliColors.gray400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 14, color: KbliColors.gray400),
                      const SizedBox(width: 8),
                      Text(
                        r.suggestedKbli!,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: KbliColors.orangeDark),
                      ),
                    ],
                  ),
                  KbliConfirmSection(
                    kbliCode: r.suggestedKbli!,
                    state: confirmState,
                    onConfirm: () => onConfirm(r.suggestedKbli!),
                  ),
                ],
              ),
            ),
          ],
          if (!hasSuggestion && r.isValid) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: KbliColors.green100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: KbliColors.green200),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.shieldCheck, size: 18, color: KbliColors.green600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: KbliColors.green700),
                        children: [
                          const TextSpan(text: 'KBLI '),
                          TextSpan(text: currentKbliCode ?? '', style: const TextStyle(fontWeight: FontWeight.w900)),
                          const TextSpan(text: ' sudah valid untuk usahamu.'),
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
}