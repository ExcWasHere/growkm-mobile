import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/api_client.dart';
import '../../../core/widgets/app_background.dart';
import '../models/business_profile.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/greeting_card.dart';
import '../widgets/level_banner.dart';
import '../widgets/profile_card.dart';
import '../widgets/feature_grid.dart';
import '../widgets/formalization_slider.dart';
import '../widgets/badges_card.dart';

enum _LoadState { loading, loaded, error }

class BerandaPage extends StatefulWidget {
  final VoidCallback onLogout;
  final ValueChanged<AppPage> onNavigateTab;
  final GlobalKey? profileCardKey;
  final GlobalKey? roadmapCardKey;

  const BerandaPage({
    super.key,
    required this.onLogout,
    required this.onNavigateTab,
    this.profileCardKey,
    this.roadmapCardKey,
  });

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  _LoadState _loadState = _LoadState.loading;
  String? _errorMessage;

  UserProfile? _userProfile;
  BusinessProfile? _businessProfile;
  GreetingData _greeting = const GreetingData(hasGreeting: false);
  List<dynamic> _roadmap = [];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _loadState = _LoadState.loading);
    try {
      final response = await ApiClient.instance.get('/api/users/me');

      if (response.statusCode != 200) {
        throw Exception('Gagal memuat data (${response.statusCode})');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? {};

      final userJson = data['user'] as Map<String, dynamic>?;
      final bpJson = data['business_profile'] as Map<String, dynamic>?;
      final greetingJson = data['greeting'] as Map<String, dynamic>?;
      final roadmapJson = data['roadmap'] as List<dynamic>? ?? [];

      setState(() {
        _userProfile = userJson != null
            ? UserProfile.fromJson(userJson)
            : const UserProfile(name: 'Sobat UMKM', email: '');
        _businessProfile = bpJson != null
            ? BusinessProfile.fromJson(bpJson)
            : const BusinessProfile(businessName: 'Usahaku', businessType: '-', city: '-');
        _greeting = GreetingData.fromJson(greetingJson);
        _roadmap = roadmapJson;
        _loadState = _LoadState.loaded;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _loadState = _LoadState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          color: const Color(0xFFF97316),
          onRefresh: _fetchProfile,
          child: switch (_loadState) {
            _LoadState.loading => const Center(
                child: CircularProgressIndicator(color: Color(0xFFF97316)),
              ),
            _LoadState.error => _buildErrorState(),
            _LoadState.loaded => _buildContent(),
          },
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
                  Text(
                    _errorMessage ?? 'Gagal memuat data',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchProfile,
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
    final u = _userProfile!;
    final p = _businessProfile!;
    return CustomScrollView(
      slivers: [
        _buildAppBar(u),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (_greeting.hasGreeting) ...[
                GreetingCard(greeting: _greeting, onNavigateTab: widget.onNavigateTab),
                const SizedBox(height: 16),
              ],
              LevelBanner(businessProfile: p),
              const SizedBox(height: 16),
              KeyedSubtree(
                key: widget.profileCardKey,
                child: ProfileCard(businessProfile: p),
              ),
              const SizedBox(height: 16),
              FeatureGrid(onNavigateTab: widget.onNavigateTab, roadmapCardKey: widget.roadmapCardKey),
              const SizedBox(height: 16),
              FormalizationSlider(businessProfile: p),
              const SizedBox(height: 16),
              BadgesCard(businessProfile: p),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(UserProfile u) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: false,
      floating: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFF97316),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Halo, ${u.name}! 👋',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const Text(
                      'Solusi Digital untuk UMKM Indonesia',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout_rounded, size: 20),
                color: Colors.red.shade400,
                tooltip: 'Keluar',
              ),
            ],
          ),
        ),
      ),
      expandedHeight: 78,
    );
  }
}