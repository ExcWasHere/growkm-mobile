import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/kbli_colors.dart';
import '../models/kbli_models.dart';

class KbliConfirmSection extends StatelessWidget {
  final String kbliCode;
  final KbliConfirmState state;
  final VoidCallback onConfirm;

  const KbliConfirmSection({
    super.key,
    required this.kbliCode,
    required this.state,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      KbliConfirmState.success => _buildSuccess(),
      KbliConfirmState.error => _buildError(),
      KbliConfirmState.idle || KbliConfirmState.loading => _buildIdleOrLoading(),
    };
  }

  Widget _buildSuccess() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
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
                  TextSpan(text: kbliCode, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const TextSpan(text: ' berhasil dikonfirmasi & disimpan!'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: KbliColors.red50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: KbliColors.red200),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.xCircle, size: 18, color: KbliColors.red),
              SizedBox(width: 8),
              Expanded(
                child: Text('Gagal menyimpan KBLI. Coba lagi ya!', style: TextStyle(fontSize: 13, color: KbliColors.red700)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: KbliColors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.refreshCw, size: 16, color: Colors.white),
                SizedBox(width: 8),
                Text('Coba Lagi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdleOrLoading() {
    final loading = state == KbliConfirmState.loading;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: KbliColors.amber200),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(LucideIcons.info, size: 14, color: KbliColors.amber500),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pastikan KBLI ini sudah sesuai sebelum dikonfirmasi. KBLI yang dipilih akan tersimpan di profil bisnismu.',
                  style: TextStyle(fontSize: 11.5, color: KbliColors.gray600, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: loading ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: KbliColors.green500,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              disabledBackgroundColor: KbliColors.green500.withOpacity(0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                else
                  const Icon(LucideIcons.shieldCheck, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  loading ? 'Menyimpan...' : 'Konfirmasi KBLI $kbliCode',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}