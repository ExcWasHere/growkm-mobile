import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/snapcash_colors.dart';
import '../models/snapcash_models.dart';
import '../pages/snapcash_format.dart';
import '../pages/snapcash_repo.dart';
import 'snapcash_stat.dart';

class SnapCashSummaryTab extends StatefulWidget {
  const SnapCashSummaryTab({super.key});

  @override
  State<SnapCashSummaryTab> createState() => _SnapCashSummaryTabState();
}

class _SnapCashSummaryTabState extends State<SnapCashSummaryTab> {
  final _repository = SnapCashRepository.instance;

  SummaryPeriod _period = SummaryPeriod.daily;
  DateTime _selectedDate = DateTime.now();

  bool _loading = true;
  String? _error;
  FinancialSummary? _summary;

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
      final summary = await _repository.fetchSummary(
        period: _period,
        date: _period == SummaryPeriod.daily ? _selectedDate : null,
        year: _period == SummaryPeriod.monthly ? _selectedDate.year : null,
        month: _period == SummaryPeriod.monthly ? _selectedDate.month : null,
      );
      if (!mounted) return;
      setState(() => _summary = summary);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Gagal memuat ringkasan');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    if (_period == SummaryPeriod.daily) {
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        setState(() => _selectedDate = picked);
        _fetch();
      }
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.year,
      );
      if (picked != null) {
        setState(() => _selectedDate = picked);
        _fetch();
      }
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
              Expanded(child: _buildPeriodChip(SummaryPeriod.daily)),
              const SizedBox(width: 8),
              Expanded(child: _buildPeriodChip(SummaryPeriod.monthly)),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: SnapCashColors.gray200)),
              child: Row(
                children: [
                  const Icon(LucideIcons.calendar, size: 15, color: SnapCashColors.orange),
                  const SizedBox(width: 8),
                  Text(
                    _period == SummaryPeriod.daily ? formatShortDate(_selectedDate) : '${monthName(_selectedDate.month)} ${_selectedDate.year}',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: SnapCashColors.gray800),
                  ),
                  const Spacer(),
                  const Icon(LucideIcons.chevronDown, size: 14, color: SnapCashColors.gray400),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Padding(padding: const EdgeInsets.only(top: 40), child: Center(child: Text(_error!, style: const TextStyle(color: SnapCashColors.gray500))))
          else if (_summary != null)
            _buildSummary(_summary!),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(SummaryPeriod period) {
    final selected = _period == period;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() => _period = period);
        _fetch();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? const LinearGradient(colors: [SnapCashColors.amber, SnapCashColors.orange]) : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.transparent : SnapCashColors.gray200),
        ),
        child: Center(
          child: Text(period.label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : SnapCashColors.gray600)),
        ),
      ),
    );
  }

  Widget _buildSummary(FinancialSummary s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: SnapCashStatBox(label: 'Pemasukan', value: formatRupiah(s.income), bg: SnapCashColors.green100, fg: SnapCashColors.green700)),
            const SizedBox(width: 8),
            Expanded(child: SnapCashStatBox(label: 'Pengeluaran', value: formatRupiah(s.expense), bg: SnapCashColors.red100, fg: SnapCashColors.red600)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: SnapCashStatBox(label: 'Profit', value: formatRupiah(s.profit), bg: SnapCashColors.amber100, fg: SnapCashColors.orangeDark)),
            const SizedBox(width: 8),
            Expanded(child: SnapCashStatBox(label: 'Margin', value: '${s.marginPct.toStringAsFixed(0)}%', bg: SnapCashColors.blue50, fg: SnapCashColors.blue500)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SnapCashColors.gray200)),
          child: Row(
            children: [
              const Icon(LucideIcons.receipt, size: 16, color: SnapCashColors.gray500),
              const SizedBox(width: 8),
              Text('${s.transactionCount} transaksi tercatat', style: const TextStyle(fontSize: 12.5, color: SnapCashColors.gray600, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}