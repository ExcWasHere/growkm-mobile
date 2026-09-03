import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';
import '../theme/kbli_colors.dart';
import 'kbli_repo.dart';
import '../models/kbli_models.dart';
import '../widgets/kbli_info.dart';
import '../widgets/kbli_error.dart';
import '../widgets/kbli_header_card.dart';
import '../widgets/kbli_reference.dart';
import '../widgets/kbli_result.dart';
import '../widgets/kbli_scan_button.dart';

enum _ProfileLoadState { loading, loaded, error }

class KbliMatcherPage extends StatefulWidget {
  const KbliMatcherPage({super.key});

  @override
  State<KbliMatcherPage> createState() => _KbliMatcherPageState();
}

class _KbliMatcherPageState extends State<KbliMatcherPage> {
  final _repository = KbliRepository.instance;

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
      final snapshot = await _repository.fetchBusinessSnapshot();
      setState(() {
        _snapshot = snapshot;
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
      final result = _snapshot.hasKbli
          ? await _repository.validate()
          : await _repository.recommend();
      setState(() => _result = result);
    } catch (e) {
      setState(() => _scanError = 'Gagal menganalisis usahamu: $e. Coba lagi ya!');
    } finally {
      setState(() => _scanLoading = false);
    }
  }

  Future<void> _confirmKbli(String kbliCode) async {
    setState(() => _confirmState = KbliConfirmState.loading);
    try {
      await _repository.confirmKbli(kbliCode);
      setState(() => _confirmState = KbliConfirmState.success);
      _fetchBusinessSnapshot();
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
            color: KbliColors.amber500,
            onRefresh: _fetchBusinessSnapshot,
            child: switch (_profileLoadState) {
              _ProfileLoadState.loading => const Center(
                  child: CircularProgressIndicator(color: KbliColors.amber500),
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
                    style: const TextStyle(fontSize: 13, color: KbliColors.gray600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchBusinessSnapshot,
                    style: ElevatedButton.styleFrom(backgroundColor: KbliColors.amber500),
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
    final result = _result;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        KbliHeaderCard(hasKbli: _snapshot.hasKbli),
        const SizedBox(height: 16),
        KbliContextInfo(snapshot: _snapshot),
        const SizedBox(height: 16),
        KbliScanButton(
          hasKbli: _snapshot.hasKbli,
          loading: _scanLoading,
          onPressed: _runScan,
        ),
        if (_scanError != null) ...[
          const SizedBox(height: 16),
          KbliErrorBox(message: _scanError!),
        ],
        if (result != null) ...[
          const SizedBox(height: 16),
          KbliResultCard(
            result: result,
            currentKbliCode: _snapshot.kbliCode,
            confirmState: _confirmState,
            onConfirm: _confirmKbli,
          ),
        ],
        const SizedBox(height: 16),
        const KbliReferenceCard(),
      ],
    );
  }
}