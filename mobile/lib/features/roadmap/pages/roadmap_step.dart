import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/widgets/app_background.dart';
import '../theme/roadmap_colors.dart';
import '../models/roadmap_models.dart';
import '../roadmap_repo.dart';
import '../widgets/roadmap_card.dart';
import '../widgets/roadmap_badge.dart';
import '../widgets/roadmap_week.dart';

enum _PlanState { loading, loaded, error }

class RoadmapStepDetailPage extends StatefulWidget {
  final RoadmapStep step;

  const RoadmapStepDetailPage({super.key, required this.step});

  @override
  State<RoadmapStepDetailPage> createState() => _RoadmapStepDetailPageState();
}

class _RoadmapStepDetailPageState extends State<RoadmapStepDetailPage> {
  final _repository = RoadmapRepository.instance;

  late RoadmapStepStatus _currentStatus = widget.step.status;

  _PlanState _planState = _PlanState.loading;
  String? _planError;
  ActionPlan? _plan;

  bool _updatingStatus = false;

  @override
  void initState() {
    super.initState();
    _generatePlan();
  }

  Future<void> _generatePlan() async {
    setState(() {
      _planState = _PlanState.loading;
      _planError = null;
    });
    try {
      final plan = await _repository.generateActionPlan(widget.step.stepType);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _planState = _PlanState.loaded;
      });
    } on RoadmapBusinessProfileMissingException {
      if (!mounted) return;
      setState(() {
        _planError = 'Lengkapi profil bisnismu dulu di Beranda sebelum bikin rencana aksi.';
        _planState = _PlanState.error;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _planError = 'Gagal membuat rencana aksi. Coba lagi ya.';
        _planState = _PlanState.error;
      });
    }
  }

  Future<void> _updateStatus(RoadmapStepStatus status) async {
    setState(() => _updatingStatus = true);
    try {
      await _repository.updateStepStatus(stepType: widget.step.stepType, status: status);
      if (!mounted) return;
      setState(() => _currentStatus = status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status == RoadmapStepStatus.completed ? 'Mantap, step ini udah selesai! 🎉' : 'Ditandai sedang dikerjakan')),
      );
    } on RoadmapStepLockedException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Step ini masih terkunci, selesaikan step sebelumnya dulu')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui status')));
    } finally {
      if (mounted) setState(() => _updatingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(widget.step.label, style: const TextStyle(color: RoadmapColors.gray800, fontWeight: FontWeight.w800, fontSize: 16)),
          iconTheme: const IconThemeData(color: RoadmapColors.gray800),
        ),
        body: SafeArea(
          top: false,
          child: switch (_planState) {
            _PlanState.loading => const Center(child: CircularProgressIndicator()),
            _PlanState.error => _buildError(),
            _PlanState.loaded => _buildContent(_plan!),
          },
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(_planError ?? 'Gagal memuat', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: RoadmapColors.gray500)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _generatePlan, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ActionPlan plan) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        _buildHeaderCard(plan),
        const SizedBox(height: 12),
        RoadmapPrerequisiteCard(check: plan.prerequisiteCheck),
        const SizedBox(height: 16),
        const Text('RENCANA AKSI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: RoadmapColors.gray400, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        ...plan.weeks.asMap().entries.map(
              (entry) => RoadmapWeekSection(week: entry.value, displayIndex: entry.key),
            ),
        if (plan.importantNotes.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildImportantNotes(plan.importantNotes),
        ],
        const SizedBox(height: 16),
        _buildStatusActions(),
      ],
    );
  }

  Widget _buildHeaderCard(ActionPlan plan) {
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
              Expanded(
                child: Text('${plan.businessName} · ${plan.city}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: RoadmapColors.gray600)),
              ),
              RoadmapStatusBadge(status: _currentStatus),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _infoChip(icon: LucideIcons.clock, label: 'Estimasi Waktu', value: plan.estimatedDuration),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoChip(icon: LucideIcons.wallet, label: 'Estimasi Biaya', value: plan.estimatedCost),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: RoadmapColors.amber50, borderRadius: BorderRadius.circular(12), border: Border.all(color: RoadmapColors.amber200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 12, color: RoadmapColors.orangeDark), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: RoadmapColors.orangeDark))]),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 11, color: RoadmapColors.gray700, height: 1.3), maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildImportantNotes(List<String> notes) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: RoadmapColors.amber50, borderRadius: BorderRadius.circular(16), border: Border.all(color: RoadmapColors.amber200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.info, size: 14, color: RoadmapColors.orangeDark),
              SizedBox(width: 6),
              Text('CATATAN PENTING', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: RoadmapColors.orangeDark, letterSpacing: 0.4)),
            ],
          ),
          const SizedBox(height: 8),
          ...notes.map(
            (n) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.only(top: 5), child: Icon(LucideIcons.dot, size: 14, color: RoadmapColors.orangeDark)),
                  Expanded(child: Text(n, style: const TextStyle(fontSize: 11.5, color: RoadmapColors.orangeDark, height: 1.4))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusActions() {
    if (_currentStatus == RoadmapStepStatus.completed) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: RoadmapColors.green50, borderRadius: BorderRadius.circular(14), border: Border.all(color: RoadmapColors.green200)),
        child: const Row(
          children: [
            Icon(LucideIcons.checkCircle2, size: 16, color: RoadmapColors.green600),
            SizedBox(width: 8),
            Text('Step ini sudah selesai', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: RoadmapColors.green700)),
          ],
        ),
      );
    }

    return Row(
      children: [
        if (_currentStatus != RoadmapStepStatus.inProgress)
          Expanded(
            child: OutlinedButton(
              onPressed: _updatingStatus ? null : () => _updateStatus(RoadmapStepStatus.inProgress),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: RoadmapColors.amber200),
                foregroundColor: RoadmapColors.orangeDark,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Sedang Dikerjakan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
            ),
          ),
        if (_currentStatus != RoadmapStepStatus.inProgress) const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _updatingStatus ? null : () => _updateStatus(RoadmapStepStatus.completed),
            style: ElevatedButton.styleFrom(
              backgroundColor: RoadmapColors.green500,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _updatingStatus
                ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Tandai Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5)),
          ),
        ),
      ],
    );
  }
}