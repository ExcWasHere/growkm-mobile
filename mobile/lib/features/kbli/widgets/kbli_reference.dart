import 'package:flutter/material.dart';
import '../theme/kbli_colors.dart';

class KbliReferenceCard extends StatelessWidget {
  const KbliReferenceCard({super.key});

  static const _examples = [
    {
      'code': '56101',
      'label': 'Restoran',
      'desc': 'Usaha makanan/minuman dengan tempat makan',
      'risk': 'Menengah Rendah',
    },
    {
      'code': '10710',
      'label': 'Industri Produk Roti & Kue',
      'desc': 'Produksi pangan kemasan — butuh SPP-IRT atau BPOM',
      'risk': 'Menengah',
    },
    {
      'code': '56290',
      'label': 'Usaha Jasa Boga Lainnya',
      'desc': 'Katering, nasi kotak rumahan',
      'risk': 'Menengah Rendah',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KbliColors.amber200),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REFERENSI KBLI KULINER UMUM',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: KbliColors.gray500, letterSpacing: 0.4),
          ),
          const SizedBox(height: 12),
          ..._examples.map(_buildItem),
        ],
      ),
    );
  }

  Widget _buildItem(Map<String, String> k) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KbliColors.amber50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KbliColors.amber100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: KbliColors.amber100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              k['code']!,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10.5, color: KbliColors.amber700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(k['label']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: KbliColors.gray800)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: KbliColors.amber200, borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        k['risk']!,
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: KbliColors.amber700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(k['desc']!, style: const TextStyle(fontSize: 11.5, color: KbliColors.gray500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}