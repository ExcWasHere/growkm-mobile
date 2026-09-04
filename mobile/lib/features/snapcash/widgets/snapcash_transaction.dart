import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/snapcash_colors.dart';
import '../models/snapcash_models.dart';
import '../pages/snapcash_format.dart';

class SnapCashTransactionTile extends StatelessWidget {
  final Transaction transaction;

  const SnapCashTransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final isIncome = t.type == TransactionType.income;
    final color = isIncome ? SnapCashColors.green600 : SnapCashColors.red600;
    final bg = isIncome ? SnapCashColors.green50 : SnapCashColors.red50;

    final qtyInfo = (t.quantity != null && t.unitPrice != null)
        ? '${t.quantity} x ${formatRupiah(t.unitPrice!)}'
        : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SnapCashColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(isIncome ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight, size: 17, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.displayLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SnapCashColors.gray800)),
                const SizedBox(height: 2),
                Text(
                  qtyInfo ?? formatShortDate(t.createdAt),
                  style: const TextStyle(fontSize: 11, color: SnapCashColors.gray500),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${formatRupiah(t.amount)}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}