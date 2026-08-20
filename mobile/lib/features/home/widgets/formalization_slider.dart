import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/business_profile.dart';
import '../../../core/widgets/section_header.dart';

class FormalizationSlider extends StatefulWidget {
  final BusinessProfile businessProfile;
  const FormalizationSlider({super.key, required this.businessProfile});

  @override
  State<FormalizationSlider> createState() => _FormalizationSliderState();
}

class _FormalizationSliderState extends State<FormalizationSlider> {
  final _controller = PageController();
  int _page = 0;
  static const _perPage = 2;

  late final List<_CertItem> _certs = [
    _CertItem('NIB', 'Nomor Induk Berusaha', widget.businessProfile.hasNib),
    _CertItem('SPP-IRT / PIRT', 'Izin pangan rumah tangga', widget.businessProfile.hasPirt),
    _CertItem('Halal', 'Sertifikat Halal MUI / BPJPH', widget.businessProfile.hasHalal),
    _CertItem('BPOM', 'Izin edar BPOM', widget.businessProfile.hasBpom),
    _CertItem('Merek', 'Pendaftaran merek DJKI', widget.businessProfile.hasMerek),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_certs.length / _perPage).ceil();
    final earnedCount = _certs.where((c) => c.earned).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: LucideIcons.checkCircle2,
            title: 'Status Formalisasi',
            iconColor: const Color(0xFF22C55E),
            iconBg: const Color(0xFFDCFCE7),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Text(
                '$earnedCount/5',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 130,
            child: PageView.builder(
              controller: _controller,
              itemCount: totalPages,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, page) {
                final slice = _certs.skip(page * _perPage).take(_perPage).toList();
                return Row(
                  children: slice
                      .map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: _certCard(c))))
                      .toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFF59E0B) : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _certCard(_CertItem c) {
    if (c.earned) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                child: const Icon(LucideIcons.check, size: 12, color: Colors.white),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF166534))),
                  const SizedBox(height: 4),
                  Text(c.desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: Color(0xFF16A34A))),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(c.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF475569))),
            const SizedBox(height: 4),
            Text(c.desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: const Text('Belum selesai', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertItem {
  final String label;
  final String desc;
  final bool earned;
  const _CertItem(this.label, this.desc, this.earned);
}