import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/snapcash_colors.dart';
import '../models/snapcash_models.dart';
import '../pages/snapcash_format.dart';
import '../pages/snapcash_repo.dart';
import '../pages/snapcash_saver.dart';
import 'snapcash_stat.dart';

class SnapCashReportTab extends StatefulWidget {
  const SnapCashReportTab({super.key});

  @override
  State<SnapCashReportTab> createState() => _SnapCashReportTabState();
}

enum _DocState { idle, drafting, drafted, previewing, error }

class _SnapCashReportTabState extends State<SnapCashReportTab> {
  final _repository = SnapCashRepository.instance;

  DateTime _selectedMonth = DateTime.now();
  bool _loading = true;
  String? _error;
  FinancialReport? _report;
  bool _downloadingExcel = false;

  _DocState _docState = _DocState.idle;
  String? _docError;

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
      final report = await _repository.fetchReport(year: _selectedMonth.year, month: _selectedMonth.month);
      if (!mounted) return;
      setState(() => _report = report);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Gagal memuat laporan');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() => _selectedMonth = picked);
      _fetch();
    }
  }

  Future<void> _downloadExcel() async {
    setState(() => _downloadingExcel = true);
    try {
      final bytes = await _repository.fetchReportExcelBytes(year: _selectedMonth.year, month: _selectedMonth.month);
      final fileName = 'laporan-kur-${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}.xlsx';
      final opened = await saveAndOpenFile(fileName: fileName, bytes: bytes);
      if (!mounted) return;
      if (!opened) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File tersimpan, tapi tidak ada app buat membukanya')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengunduh laporan excel')));
    } finally {
      if (mounted) setState(() => _downloadingExcel = false);
    }
  }

  Future<void> _draftIngredientList() async {
    setState(() {
      _docState = _DocState.drafting;
      _docError = null;
    });
    try {
      await _repository.draftIngredientList();
      if (!mounted) return;
      setState(() => _docState = _DocState.drafted);
    } on DocumentBusinessProfileMissingException {
      if (!mounted) return;
      setState(() {
        _docState = _DocState.error;
        _docError = 'Lengkapi profil bisnismu dulu di Beranda sebelum bikin draft dokumen.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _docState = _DocState.error;
        _docError = 'Gagal membuat draft dokumen.';
      });
    }
  }

  Future<void> _previewIngredientList() async {
    setState(() => _docState = _DocState.previewing);
    try {
      final html = await _repository.fetchIngredientListPreviewHtml();
      final bytes = Uint8List.fromList(html.codeUnits);
      final opened = await saveAndOpenFile(fileName: 'daftar-bahan-spp-irt.html', bytes: bytes);
      if (!mounted) return;
      setState(() => _docState = _DocState.drafted);
      if (!opened) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File tersimpan, tapi tidak ada app buat membukanya')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _docState = _DocState.error;
        _docError = 'Gagal memuat preview dokumen.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetch,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickMonth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: SnapCashColors.gray200)),
              child: Row(
                children: [
                  const Icon(LucideIcons.calendar, size: 15, color: SnapCashColors.orange),
                  const SizedBox(width: 8),
                  Text('${monthName(_selectedMonth.month)} ${_selectedMonth.year}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: SnapCashColors.gray800)),
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
          else if (_report != null) ...[
            _buildReportHeader(_report!),
            const SizedBox(height: 12),
            _buildKurReadiness(_report!.kurReadiness),
            const SizedBox(height: 12),
            _buildDailyBreakdown(_report!),
            const SizedBox(height: 12),
            _buildExcelButton(),
            const SizedBox(height: 16),
            _buildDocumentsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildReportHeader(FinancialReport r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SnapCashColors.amber200),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.businessName ?? 'Usahamu', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: SnapCashColors.gray800)),
          Text('${r.businessType} · ${r.period}', style: const TextStyle(fontSize: 11.5, color: SnapCashColors.gray500)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: SnapCashStatBox(label: 'Total Masuk', value: formatRupiah(r.summary.totalIncome), bg: SnapCashColors.green100, fg: SnapCashColors.green700)),
              const SizedBox(width: 8),
              Expanded(child: SnapCashStatBox(label: 'Total Keluar', value: formatRupiah(r.summary.totalExpense), bg: SnapCashColors.red100, fg: SnapCashColors.red600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: SnapCashStatBox(label: 'Laba Kotor', value: formatRupiah(r.summary.grossProfit), bg: SnapCashColors.amber100, fg: SnapCashColors.orangeDark, sublabel: '${r.summary.grossMarginPct.toStringAsFixed(0)}% margin')),
              const SizedBox(width: 8),
              Expanded(child: SnapCashStatBox(label: 'Konsistensi', value: '${r.summary.consistencyPct.toStringAsFixed(0)}%', bg: SnapCashColors.blue50, fg: SnapCashColors.blue500, sublabel: '${r.summary.recordingDays} hari nyatat')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKurReadiness(KurReadiness k) {
    final ready = k.hasNib && k.has30DaysRecords;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ready ? SnapCashColors.green50 : SnapCashColors.amber50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ready ? SnapCashColors.green200 : SnapCashColors.amber200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ready ? LucideIcons.badgeCheck : LucideIcons.alertCircle, size: 16, color: ready ? SnapCashColors.green600 : SnapCashColors.orangeDark),
              const SizedBox(width: 8),
              Text('Kesiapan Ajukan KUR', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: ready ? SnapCashColors.green700 : SnapCashColors.orangeDark)),
            ],
          ),
          const SizedBox(height: 8),
          _buildChecklistRow('Punya NIB', k.hasNib),
          const SizedBox(height: 4),
          _buildChecklistRow('Catatan keuangan 30 hari (${k.daysRecorded} hari tercatat)', k.has30DaysRecords),
          const SizedBox(height: 8),
          Text(k.message, style: TextStyle(fontSize: 11.5, color: ready ? SnapCashColors.green700 : SnapCashColors.orangeDark, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildChecklistRow(String label, bool checked) {
    return Row(
      children: [
        Icon(checked ? LucideIcons.checkCircle2 : LucideIcons.xCircle, size: 14, color: checked ? SnapCashColors.green600 : SnapCashColors.gray400),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: SnapCashColors.gray600))),
      ],
    );
  }

  Widget _buildDailyBreakdown(FinancialReport r) {
    if (r.dailyBreakdown.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: SnapCashColors.gray200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RINCIAN HARIAN', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: SnapCashColors.gray400, letterSpacing: 0.4)),
          const SizedBox(height: 8),
          ...r.dailyBreakdown.map(
            (d) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(width: 70, child: Text(d.date, style: const TextStyle(fontSize: 11.5, color: SnapCashColors.gray600))),
                  Expanded(child: Text('+${formatRupiah(d.income)}', style: const TextStyle(fontSize: 11, color: SnapCashColors.green600))),
                  Expanded(child: Text('-${formatRupiah(d.expense)}', style: const TextStyle(fontSize: 11, color: SnapCashColors.red600))),
                  Text(formatRupiah(d.profit), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: SnapCashColors.gray800)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExcelButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _downloadingExcel ? null : _downloadExcel,
        icon: _downloadingExcel
            ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: SnapCashColors.orangeDark))
            : const Icon(LucideIcons.fileSpreadsheet, size: 16),
        label: Text(_downloadingExcel ? 'Menyiapkan file...' : 'Unduh Laporan Excel'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: SnapCashColors.amber200),
          foregroundColor: SnapCashColors.orangeDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
        ),
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SnapCashColors.amber200),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: SnapCashColors.orange, borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.fileText, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Draft Daftar Bahan (SPP-IRT)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: SnapCashColors.gray800)),
                    Text('Dibuat otomatis dari data belanja SnapCash', style: TextStyle(fontSize: 11, color: SnapCashColors.gray500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_docError != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: SnapCashColors.red50, borderRadius: BorderRadius.circular(12), border: Border.all(color: SnapCashColors.red200)),
              child: Text(_docError!, style: const TextStyle(fontSize: 11.5, color: SnapCashColors.red600)),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _docState == _DocState.drafting ? null : _draftIngredientList,
                    style: ElevatedButton.styleFrom(backgroundColor: SnapCashColors.orange, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _docState == _DocState.drafting
                        ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Buat Draft', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5)),
                  ),
                ),
              ),
              if (_docState == _DocState.drafted) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: _docState == _DocState.previewing ? null : _previewIngredientList,
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: SnapCashColors.amber200), foregroundColor: SnapCashColors.orangeDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _docState == _DocState.previewing
                          ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: SnapCashColors.orangeDark))
                          : const Text('Lihat Preview', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}