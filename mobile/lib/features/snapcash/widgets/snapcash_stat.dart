import 'package:flutter/material.dart';
import '../theme/snapcash_colors.dart';

class SnapCashStatBox extends StatelessWidget {
  final String label;
  final String value;
  final String? sublabel;
  final Color bg;
  final Color fg;

  const SnapCashStatBox({
    super.key,
    required this.label,
    required this.value,
    required this.bg,
    required this.fg,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg.withOpacity(0.85))),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: fg),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 2),
            Text(sublabel!, style: TextStyle(fontSize: 9.5, color: fg.withOpacity(0.7))),
          ],
        ],
      ),
    );
  }
}