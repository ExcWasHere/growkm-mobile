import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';
import 'market_repo.dart';
import '../models/market_models.dart';
import '../widgets/market_advisor.dart';
import '../widgets/market_filter.dart';
import '../widgets/market_opportunity.dart';
import '../widgets/market_summary.dart';
import '../widgets/market_detail.dart';

enum _LoadState { loading, loaded, error }

class MarketGatePage extends StatefulWidget {
  const MarketGatePage({super.key});

  @override
  State<MarketGatePage> createState() => _MarketGatePageState();
}

class _MarketGatePageState extends State<MarketGatePage> {
  final _repository = MarketRepository.instance;

  _LoadState _loadState = _LoadState.loading;
  String? _loadError;
  OpportunitiesResult? _opportunitiesResult;
  bool _matchRefreshing = false;

  MatchStatus? _selectedFilter;

  bool _advisorLoading = true;
  String? _advisorError;
  AdvisorResult? _advisorResult;
  bool _advisorExpanded = true;

  @override
  void initState() {
    super.initState();
    _fetchOpportunities();
    _fetchAdvisor();
  }

  Future<void> _fetchOpportunities() async {
    setState(() => _loadState = _LoadState.loading);
    try {
      final result = await _repository.fetchOpportunities();
      if (!mounted) return;
      setState(() {
        _opportunitiesResult = result;
        _loadState = _LoadState.loaded;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loadState = _LoadState.error;
      });
    }
  }

  Future<void> _fetchAdvisor() async {
    setState(() {
      _advisorLoading = true;
      _advisorError = null;
    });
    try {
      final result = await _repository.fetchAdvisor();
      if (!mounted) return;
      setState(() => _advisorResult = result);
    } on AdvisorProfileIncompleteException {
      if (!mounted) return;
      setState(() => _advisorError = 'Lengkapi profil bisnismu dulu di Beranda supaya Lexa bisa kasih rekomendasi.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _advisorError = 'Gagal memuat rekomendasi AI.');
    } finally {
      if (mounted) setState(() => _advisorLoading = false);
    }
  }

  Future<void> _refreshMatch() async {
    setState(() => _matchRefreshing = true);
    try {
      await _repository.triggerMatch();
      await _fetchOpportunities();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui status peluang')),
      );
    } finally {
      if (mounted) setState(() => _matchRefreshing = false);
    }
  }

  List<Opportunity> get _filteredOpportunities {
    final all = _opportunitiesResult?.opportunities ?? [];
    if (_selectedFilter == null) return all;
    return all.where((o) => o.matchStatus == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([_fetchOpportunities(), _fetchAdvisor()]);
            },
            child: switch (_loadState) {
              _LoadState.loading => const Center(child: CircularProgressIndicator()),
              _LoadState.error => _buildErrorState(),
              _LoadState.loaded => _buildContent(),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
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
                  Text(_loadError ?? 'Gagal memuat data', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _fetchOpportunities, child: const Text('Coba Lagi')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final summary = _opportunitiesResult!.summary;
    final filtered = _filteredOpportunities;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        MarketSummaryCard(summary: summary, refreshing: _matchRefreshing, onRefresh: _refreshMatch),
        const SizedBox(height: 16),
        MarketAdvisorCard(
          loading: _advisorLoading,
          error: _advisorError,
          result: _advisorResult,
          expanded: _advisorExpanded,
          onToggleExpand: () => setState(() => _advisorExpanded = !_advisorExpanded),
          onRefresh: _fetchAdvisor,
        ),
        const SizedBox(height: 16),
        const Text('FEED PELUANG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6B7280), letterSpacing: 0.5)),
        const SizedBox(height: 10),
        MarketFilterTabs(selected: _selectedFilter, summary: summary, onSelect: (s) => setState(() => _selectedFilter = s)),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text('Belum ada peluang di kategori ini', style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500)),
            ),
          )
        else
          ...filtered.map(
            (o) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MarketOpportunityCard(
                opportunity: o,
                onTapDetail: () => showMarketDetailSheet(context, o),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Market Gate', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFF97316))),
          SizedBox(height: 2),
          Text('Solusi Digital untuk UMKM Indonesia', style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}