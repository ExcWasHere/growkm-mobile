import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/widgets/app_background.dart';
import '../theme/roadmap_colors.dart';
import '../models/roadmap_models.dart';
import '../roadmap_repo.dart';
import '../widgets/roadmap_tile.dart';
import 'roadmap_step.dart';

enum _LoadState { loading, loaded, error }

class RoadmapPage extends StatefulWidget {
  const RoadmapPage({super.key});

  @override
  State<RoadmapPage> createState() => _RoadmapPageState();
}

class _RoadmapPageState extends State<RoadmapPage> {
  final _repository = RoadmapRepository.instance;

  _LoadState _loadState = _LoadState.loading;
  String? _error;
  RoadmapOverview? _overview;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loadState = _LoadState.loading);
    try {
      final overview = await _repository.fetchOverview();
      if (!mounted) return;
      setState(() {
        _overview = overview;
        _loadState = _LoadState.loaded;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loadState = _LoadState.error;
      });
    }
  }

  Future<void> _openStep(RoadmapStep step) async {
    if (step.status == RoadmapStepStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selesaikan step sebelumnya dulu ya')),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RoadmapStepDetailPage(step: step)),
    );
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Guide to Grow', style: TextStyle(color: RoadmapColors.gray800, fontWeight: FontWeight.w800, fontSize: 16)),
          iconTheme: const IconThemeData(color: RoadmapColors.gray800),
        ),
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: _fetch,
            child: switch (_loadState) {
              _LoadState.loading => const Center(child: CircularProgressIndicator()),
              _LoadState.error => _buildErrorState(),
              _LoadState.loaded => _buildContent(_overview!),
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
                  Text(_error ?? 'Gagal memuat roadmap', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: RoadmapColors.gray500)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _fetch, child: const Text('Coba Lagi')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(RoadmapOverview overview) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        _buildProgressCard(overview),
        const SizedBox(height: 16),
        ...overview.steps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RoadmapStepTile(step: step, onTap: () => _openStep(step)),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(RoadmapOverview overview) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RoadmapColors.amber200),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: RoadmapColors.orange,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(LucideIcons.compass, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(overview.businessName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: RoadmapColors.gray800)),
                    Text(
                      overview.city.isNotEmpty ? 'Roadmap legalitas · ${overview.city}' : 'Roadmap legalitas usahamu',
                      style: const TextStyle(fontSize: 11.5, color: RoadmapColors.gray500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: overview.progressPct / 100,
              minHeight: 10,
              backgroundColor: RoadmapColors.gray100,
              valueColor: const AlwaysStoppedAnimation(RoadmapColors.orange),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${overview.completedSteps} dari ${overview.totalSteps} step selesai (${overview.progressPct.toStringAsFixed(0)}%)',
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: RoadmapColors.gray600),
          ),
        ],
      ),
    );
  }
}