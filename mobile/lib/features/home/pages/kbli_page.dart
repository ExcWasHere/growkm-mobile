import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/api_client.dart';
import '../../../core/widgets/app_background.dart';
import '../models/kbli_models.dart';

enum _ProfileLoadState { loading, loaded, error }

class KbliMatcherPage extends StatefulWidget {
  const KbliMatcherPage({super.key});

  @override
  State<KbliMatcherPage> createState() => _KbliMatcherPageState();
}

class _KbliMatcherPageState extends State<KbliMatcherPage> {
  static const _kbliExamples = [
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

  _ProfileLoadState _profileLoadState = _ProfileLoadState.loading;
  KbliBusinessSnapshot _snapshot = const KbliBusinessSnapshot();
  String? _profileError;

  bool _scanLoading = false;
  KbliScanResult? _result;
  String? _scanError;
  KbliConfirmState _confirmState = KbliConfirmState.idle;

  @override
  void initState() {
    super.initState();
    _fetchBusinessSnapshot();
  }

  Future<void> _fetchBusinessSnapshot() async {
    setState(() => _profileLoadState = _ProfileLoadState.loading);
    try {
      final response = await ApiClient.instance.get('/api/users/me');
      if (response.statusCode != 200) {
        throw Exception('Gagal memuat data (${response.statusCode})');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? {};
      final bpJson = data['business_profile'] as Map<String, dynamic>?;
      setState(() {
        _snapshot = KbliBusinessSnapshot.fromJson(bpJson);
        _profileLoadState = _ProfileLoadState.loaded;
      });
    } catch (e) {
      setState(() {
        _profileError = e.toString();
        _profileLoadState = _ProfileLoadState.error;
      });
    }
  }

  Future<void> _runScan() async {
    setState(() {
      _scanLoading = true;
      _result = null;
      _scanError = null;
      _confirmState = KbliConfirmState.idle;
    });

    try {
      final path = _snapshot.hasKbli
          ? '/api/users/business-profile/kbli/validate'
          : '/api/users/business-profile/kbli/recommend';
      final response = await ApiClient.instance.post(path, const {});

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        final message = decoded['message'] as String? ?? 'HTTP ${response.statusCode}';
        throw Exception(message);
      }
      final data = decoded['data'] as Map<String, dynamic>? ?? {};

      setState(() {
        _result = _snapshot.hasKbli
            ? KbliScanResult.validate(data)
            : KbliScanResult.recommend(data);
      });
    } catch (e) {
      setState(() {
        _scanError = 'Gagal menganalisis usahamu: $e. Coba lagi ya!';
      });
    } finally {
      setState(() => _scanLoading = false);
    }
  }

  Future<void> _confirmKbli(String kbliCode) async {
    setState(() => _confirmState = KbliConfirmState.loading);
    try {
      final response = await ApiClient.instance.patch(
        '/api/users/business-profile/kbli',
        {'kbli_code': kbliCode},
      );
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      setState(() => _confirmState = KbliConfirmState.success);
    } catch (e) {
      setState(() => _confirmState = KbliConfirmState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFFF97316),
            onRefresh: _fetchBusinessSnapshot,
            child: switch (_profileLoadState) {
              _ProfileLoadState.loading => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFF97316)),
                ),
              _ProfileLoadState.error => _buildProfileErrorState(),
              _ProfileLoadState.loaded => _buildContent(),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileErrorState() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 40, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(
                    _profileError ?? 'Gagal memuat data',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchBusinessSnapshot,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
                    child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _buildHeaderCard(),
        const SizedBox(height: 16),
        _buildContextInfo(),
        const SizedBox(height: 16),
        _buildScanButton(),
        if (_scanError != null) ...[
          const SizedBox(height: 16),
          _buildErrorBox(_scanError!),
        ],
        if (_result != null) ...[
          const SizedBox(height: 16),
          _buildResult(_result!),
        ],
        const SizedBox(height: 16),
        _buildReferenceCard(),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF97316), Color(0xFFEF4444)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x33F97316), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: const Icon(LucideIcons.shieldCheck, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KBLI Matcher',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 2),
                Text(
                  _snapshot.hasKbli
                      ? 'Validasi kesesuaian KBLI dengan deskripsi usahamu'
                      : 'Deteksi KBLI yang tepat berdasarkan deskripsi usahamu',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(LucideIcons.info, size: 16, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _snapshot.hasKbli
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13.5, color: Color(0xFF374151)),
                          children: [
                            const TextSpan(text: 'KBLI saat ini: '),
                            TextSpan(
                              text: _snapshot.kbliCode,
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'AI akan memvalidasi apakah KBLI ini sesuai dengan deskripsi usahamu.',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Belum ada KBLI yang tersimpan.',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                      ),
                      const SizedBox(height: 2),
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                          children: [
                            const TextSpan(text: 'AI akan merekomendasikan KBLI berdasarkan deskripsi usahamu: '),
                            TextSpan(
                              text: '"${_snapshot.description ?? '—'}"',
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    final label = _scanLoading
        ? (_snapshot.hasKbli ? 'Memvalidasi KBLI...' : 'Menganalisis usahamu...')
        : (_snapshot.hasKbli ? 'Validasi KBLI Saya' : 'Rekomendasikan KBLI');

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _scanLoading ? null : _runScan,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF97316),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_scanLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else
              const Icon(LucideIcons.search, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.xCircle, size: 20, color: Color(0xFFEF4444)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFFB91C1C))),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(KbliScanResult r) {
    return r.mode == KbliScanMode.recommend ? _buildRecommendResult(r) : _buildValidateResult(r);
  }

  Widget _buildRecommendResult(KbliScanResult r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(LucideIcons.checkCircle, size: 22, color: Color(0xFF22C55E)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(r.kbliCode, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                        const Text('  —  ', style: TextStyle(color: Color(0xFF9CA3AF))),
                        Text(r.kbliTitle ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF374151))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Confidence: ', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                        Text(
                          '${((r.confidence ?? 0) * 100).round()}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(r.explanation, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          _buildConfirmSection(r.kbliCode),
        ],
      ),
    );
  }

  Widget _buildValidateResult(KbliScanResult r) {
    final hasMismatch = r.hasMismatch;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasMismatch ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasMismatch ? const Color(0xFFFED7AA) : const Color(0xFFBBF7D0)),
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
                  hasMismatch ? LucideIcons.alertTriangle : LucideIcons.checkCircle,
                  size: 22,
                  color: hasMismatch ? const Color(0xFFF97316) : const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(r.kbliCode, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                        const Text('  —  ', style: TextStyle(color: Color(0xFF9CA3AF))),
                        Text(r.kbliName ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF374151))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(r.explanation, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          if (hasMismatch && r.mismatchAlert != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KBLI TIDAK SESUAI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFC2410C), letterSpacing: 0.4),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        r.mismatchAlert!.userKbli,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.lineThrough,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 8),
                      Text(
                        r.mismatchAlert!.recommendedKbli,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFEA580C)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(r.mismatchAlert!.reason, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.4)),
                  _buildConfirmSection(r.mismatchAlert!.recommendedKbli),
                ],
              ),
            ),
          ],
          if (!hasMismatch) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.shieldCheck, size: 18, color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF15803D)),
                        children: [
                          const TextSpan(text: 'KBLI '),
                          TextSpan(text: _snapshot.kbliCode ?? '', style: const TextStyle(fontWeight: FontWeight.w900)),
                          const TextSpan(text: ' sudah valid untuk usahamu.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (r.warnings.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'KBLI YANG SERING TERTUKAR',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6B7280), letterSpacing: 0.4),
            ),
            const SizedBox(height: 8),
            ...r.warnings.map(
              (w) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(LucideIcons.xCircle, size: 15, color: Color(0xFFF87171)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(w.wrongKbli, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF374151))),
                          const SizedBox(height: 2),
                          Text(w.reason, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280), height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmSection(String kbliCode) {
    if (_confirmState == KbliConfirmState.success) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.shieldCheck, size: 18, color: Color(0xFF16A34A)),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF15803D)),
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

    if (_confirmState == KbliConfirmState.error) {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.xCircle, size: 18, color: Color(0xFFEF4444)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Gagal menyimpan KBLI. Coba lagi ya!', style: TextStyle(fontSize: 13, color: Color(0xFFB91C1C))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () => _confirmKbli(kbliCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
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

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(LucideIcons.info, size: 14, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Pastikan KBLI ini sudah sesuai sebelum dikonfirmasi. KBLI yang dipilih akan tersimpan di profil bisnismu.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF4B5563), height: 1.4),
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
            onPressed: _confirmState == KbliConfirmState.loading ? null : () => _confirmKbli(kbliCode),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              disabledBackgroundColor: const Color(0xFF22C55E).withOpacity(0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_confirmState == KbliConfirmState.loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                else
                  const Icon(LucideIcons.shieldCheck, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  _confirmState == KbliConfirmState.loading ? 'Menyimpan...' : 'Konfirmasi KBLI $kbliCode',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REFERENSI KBLI KULINER UMUM',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF6B7280), letterSpacing: 0.4),
          ),
          const SizedBox(height: 12),
          ..._kbliExamples.map(
            (k) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFEF3C7)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      k['code']!,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10.5, color: Color(0xFFB45309)),
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
                            Text(k['label']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1F2937))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFFDE68A), borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                k['risk']!,
                                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(k['desc']!, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}