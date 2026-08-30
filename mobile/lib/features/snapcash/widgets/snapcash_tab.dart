import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/snapcash_colors.dart';
import '../models/snapcash_models.dart';
import '../pages/snapcash_format.dart';
import '../pages/snapcash_repo.dart';
import 'snapcash_stat.dart';

class SnapCashRecordTab extends StatefulWidget {
  const SnapCashRecordTab({super.key});

  @override
  State<SnapCashRecordTab> createState() => _SnapCashRecordTabState();
}

class _SnapCashRecordTabState extends State<SnapCashRecordTab> {
  final _repository = SnapCashRepository.instance;
  final _messageController = TextEditingController();
  final _imagePicker = ImagePicker();

  DateTime _recordDate = DateTime.now();
  final List<XFile> _attachedImages = [];
  bool _submitting = false;
  String? _error;
  RecordTransactionResult? _result;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    Navigator.of(context).maybePop();
    final file = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 80, maxWidth: 1600);
    if (file != null) setState(() => _attachedImages.add(file));
  }

  Future<void> _pickFromGallery() async {
    Navigator.of(context).maybePop();
    final files = await _imagePicker.pickMultiImage(imageQuality: 80, maxWidth: 1600);
    if (files.isNotEmpty) setState(() => _attachedImages.addAll(files));
  }

  void _showAttachSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: SnapCashColors.gray200, borderRadius: BorderRadius.circular(4))),
            ListTile(
              leading: const Icon(LucideIcons.camera, color: SnapCashColors.orange),
              title: const Text('Ambil Foto'),
              onTap: _pickFromCamera,
            ),
            ListTile(
              leading: const Icon(LucideIcons.image, color: SnapCashColors.orange),
              title: const Text('Pilih dari Galeri'),
              subtitle: const Text('Bisa pilih beberapa foto sekaligus'),
              onTap: _pickFromGallery,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recordDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _recordDate = picked);
  }

  Future<void> _submit() async {
    final message = _messageController.text.trim();
    if (message.length < 2 || _submitting) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      List<String>? uploadedUrls;
      if (_attachedImages.isNotEmpty) {
        final uploads = await Future.wait(
          _attachedImages.map((file) async {
            final bytes = await file.readAsBytes();
            final ext = file.path.split('.').last.toLowerCase();
            final contentType = (ext == 'png') ? 'image/png' : 'image/jpeg';
            return ReceiptImageUpload(fileName: file.name, contentType: contentType, bytes: bytes);
          }),
        );
        uploadedUrls = await _repository.uploadReceiptImages(uploads);
      }

      final result = await _repository.recordTransaction(
        message: message,
        recordDate: _recordDate,
        images: uploadedUrls,
      );

      if (!mounted) return;
      setState(() {
        _result = result;
        _messageController.clear();
        _attachedImages.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Gagal mencatat transaksi: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Container(
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
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [SnapCashColors.amber, SnapCashColors.orange]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Ganti ke Material icon bawaan Flutter — LucideIcons.penLine /
                    // .pencilLine tidak ada di package lucide_icons versi ini.
                    child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Ceritain transaksinya, biar AI yang catat',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SnapCashColors.gray800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Contoh: Jual 20 porsi nasi @25rb. Belanja bahan 180rb.',
                  hintStyle: const TextStyle(color: SnapCashColors.gray400, fontSize: 12.5),
                  filled: true,
                  fillColor: SnapCashColors.gray50,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: SnapCashColors.gray200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: SnapCashColors.gray200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: SnapCashColors.amber, width: 1.4)),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(color: SnapCashColors.amber50, borderRadius: BorderRadius.circular(10), border: Border.all(color: SnapCashColors.amber200)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.calendar, size: 13, color: SnapCashColors.orangeDark),
                          const SizedBox(width: 6),
                          Text(formatShortDate(_recordDate), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: SnapCashColors.orangeDark)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _showAttachSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(color: SnapCashColors.gray50, borderRadius: BorderRadius.circular(10), border: Border.all(color: SnapCashColors.gray200)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.paperclip, size: 13, color: SnapCashColors.gray500),
                          const SizedBox(width: 6),
                          Text(
                            _attachedImages.isNotEmpty ? '${_attachedImages.length} foto terpasang' : 'Lampirkan nota',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: SnapCashColors.gray500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_attachedImages.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 84,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _attachedImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final file = _attachedImages[index];
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(File(file.path), height: 84, width: 84, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => setState(() => _attachedImages.removeAt(index)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(LucideIcons.x, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SnapCashColors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Catat Transaksi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5)),
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: SnapCashColors.red50, borderRadius: BorderRadius.circular(14), border: Border.all(color: SnapCashColors.red200)),
            child: Text(_error!, style: const TextStyle(fontSize: 12.5, color: SnapCashColors.red600)),
          ),
        ],
        if (_result != null) ...[
          const SizedBox(height: 16),
          _buildResult(_result!),
        ],
      ],
    );
  }

  Widget _buildResult(RecordTransactionResult r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SnapCashColors.green50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SnapCashColors.green200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarkdownBody(
            data: r.aiResponse,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 13, color: SnapCashColors.gray800, height: 1.5),
              strong: const TextStyle(fontWeight: FontWeight.w800, color: SnapCashColors.gray800),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: SnapCashStatBox(label: 'Pemasukan', value: formatRupiah(r.dailySummary.income), bg: SnapCashColors.green100, fg: SnapCashColors.green700)),
              const SizedBox(width: 8),
              Expanded(child: SnapCashStatBox(label: 'Pengeluaran', value: formatRupiah(r.dailySummary.expense), bg: SnapCashColors.red100, fg: SnapCashColors.red600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: SnapCashStatBox(label: 'Profit', value: formatRupiah(r.dailySummary.profit), bg: SnapCashColors.amber100, fg: SnapCashColors.orangeDark)),
              const SizedBox(width: 8),
              Expanded(child: SnapCashStatBox(label: 'Margin', value: '${r.dailySummary.marginPct.toStringAsFixed(0)}%', bg: SnapCashColors.blue50, fg: SnapCashColors.blue500)),
            ],
          ),
          if (r.streakDays > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text('${r.streakDays} hari berturut-turut nyatat!', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SnapCashColors.orangeDark)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}