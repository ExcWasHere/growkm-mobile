import 'package:flutter/material.dart';
import '../../../core/widgets/app_background.dart';
import '../theme/snapcash_colors.dart';
import '../widgets/snapcash_history.dart';
import '../widgets/snapcash_tab.dart';
import '../widgets/snapcash_report.dart';
import '../widgets/snapcash_summary.dart';

class SnapCashPage extends StatefulWidget {
  const SnapCashPage({super.key});

  @override
  State<SnapCashPage> createState() => _SnapCashPageState();
}

class _SnapCashPageState extends State<SnapCashPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['Catat', 'Ringkasan', 'Riwayat', 'Laporan'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildTabBar(),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    SnapCashRecordTab(),
                    SnapCashSummaryTab(),
                    SnapCashHistoryTab(),
                    SnapCashReportTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Snap Cash', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: SnapCashColors.orange)),
          SizedBox(height: 2),
          Text('Catat & pantau kas usahamu', style: TextStyle(fontSize: 12.5, color: SnapCashColors.gray500)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SnapCashColors.amber200)),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(colors: [SnapCashColors.amber, SnapCashColors.orange]),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: SnapCashColors.gray500,
          labelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
          tabs: _tabs.map((t) => Tab(height: 38, text: t)).toList(),
        ),
      ),
    );
  }
}