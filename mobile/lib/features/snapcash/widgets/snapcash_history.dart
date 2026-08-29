import 'package:flutter/material.dart';
import '../theme/snapcash_colors.dart';
import '../models/snapcash_models.dart';
import '../pages/snapcash_repo.dart';
import 'snapcash_transaction.dart';

class SnapCashHistoryTab extends StatefulWidget {
  const SnapCashHistoryTab({super.key});

  @override
  State<SnapCashHistoryTab> createState() => _SnapCashHistoryTabState();
}

class _SnapCashHistoryTabState extends State<SnapCashHistoryTab> {
  final _repository = SnapCashRepository.instance;

  TransactionType? _typeFilter;
  bool _loading = true;
  String? _error;
  GetRecordsResult? _result;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repository.fetchRecords(type: _typeFilter);
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Gagal memuat riwayat transaksi');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Row(
            children: [
              Expanded(child: _buildFilterChip('Semua', null)),
              const SizedBox(width: 8),
              Expanded(child: _buildFilterChip('Pemasukan', TransactionType.income)),
              const SizedBox(width: 8),
              Expanded(child: _buildFilterChip('Pengeluaran', TransactionType.expense)),
            ],
          ),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Padding(padding: const EdgeInsets.only(top: 40), child: Center(child: Text(_error!, style: const TextStyle(color: SnapCashColors.gray500))))
          else if (_result == null || _result!.records.isEmpty)
            const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: Text('Belum ada transaksi tercatat', style: TextStyle(color: SnapCashColors.gray400))))
          else ...[
            Text('${_result!.total} transaksi', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: SnapCashColors.gray500)),
            const SizedBox(height: 10),
            ..._result!.records.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SnapCashTransactionTile(transaction: t),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionType? type) {
    final selected = _typeFilter == type;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() => _typeFilter = type);
        _fetch();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          gradient: selected ? const LinearGradient(colors: [SnapCashColors.amber, SnapCashColors.orange]) : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.transparent : SnapCashColors.gray200),
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : SnapCashColors.gray600)),
        ),
      ),
    );
  }
}