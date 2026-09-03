import 'package:flutter/material.dart';
import '../../core/services/supabase_auth_service.dart';
import '../../core/services/product_tour_service.dart';
import '../../core/services/product_tour_step.dart';
import '../../core/widgets/product_tour_dialog.dart';
import '../auth/login_screen.dart';
import '../kbli/pages/kbli_page.dart';
import '../lexa/pages/lexa_chat.dart';
import '../market/pages/market_gate_page.dart';
import '../snapcash/pages/snapcash_page.dart';
import 'widgets/bottom_navbar.dart';
import 'pages/beranda_page.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppPage _currentPage = AppPage.beranda;

  final _berandaTabKey = GlobalKey();
  final _kbliTabKey = GlobalKey();
  final _lexaTabKey = GlobalKey();
  final _financeTabKey = GlobalKey();
  final _marketTabKey = GlobalKey();
  final _profileCardKey = GlobalKey();
  final _roadmapCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowHomeTour());
  }

  Future<void> _maybeShowHomeTour() async {
    await ProductTourDialog.showIfNeeded(
      context,
      tourKey: 'home_screen_tour',
      store: ProductTourService.instance,
      steps: [
        ProductTourStep(
          title: 'Beranda',
          description: 'Ringkasan usahamu, progress, dan aktivitas terbaru ada di sini.',
          icon: Icons.home_outlined,
          targetKey: _berandaTabKey,
        ),
        ProductTourStep(
          title: 'KBLI Matcher',
          description: 'Bingung KBLI usahamu apa? AI kami bantu carikan atau validasi kode yang tepat.',
          icon: Icons.shield_outlined,
          targetKey: _kbliTabKey,
        ),
        ProductTourStep(
          title: 'Lexa AI',
          description: 'Tanya apa saja soal legalitas dan perizinan usaha ke Lexa, asisten AI kamu 24/7.',
          icon: Icons.chat_bubble_outline,
          targetKey: _lexaTabKey,
        ),
        ProductTourStep(
          title: 'Snap Cash',
          description: 'Catat pemasukan & pengeluaran harian usahamu, cukup ceritain lewat chat.',
          icon: Icons.attach_money,
          targetKey: _financeTabKey,
        ),
        ProductTourStep(
          title: 'Market Gate',
          description: 'Temukan peluang pasar, program pemerintah, dan pembiayaan yang cocok buat usahamu.',
          icon: Icons.storefront_outlined,
          targetKey: _marketTabKey,
        ),
        ProductTourStep(
          title: 'Profil Usaha',
          description: 'Ini profil usahamu. Data di sini dipakai buat kasih rekomendasi yang lebih personal.',
          icon: Icons.store_outlined,
          targetKey: _profileCardKey,
        ),
        ProductTourStep(
          title: 'Guide to Grow',
          description: 'Roadmap langkah legalitas usahamu, dari NIB sampai Halal, dipandu step-by-step.',
          icon: Icons.explore_outlined,
          targetKey: _roadmapCardKey,
        ),
      ],
    );
  }

  Future<void> _logout() async {
    await SupabaseAuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      LoginScreen.routeName,
      (route) => false,
    );
  }

  void _navigateToTab(AppPage page) {
    setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: AppPage.values.indexOf(_currentPage),
        children: [
          BerandaPage(
            onLogout: _logout,
            onNavigateTab: _navigateToTab,
            profileCardKey: _profileCardKey,
            roadmapCardKey: _roadmapCardKey,
          ),
          const KbliMatcherPage(),
          const LexaChatPage(),
          const SnapCashPage(),
          const MarketGatePage(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentPage: _currentPage,
        onNavigate: _navigateToTab,
        tabKeys: {
          AppPage.beranda: _berandaTabKey,
          AppPage.scanner: _kbliTabKey,
          AppPage.chatbot: _lexaTabKey,
          AppPage.finance: _financeTabKey,
          AppPage.market: _marketTabKey,
        },
      ),
    );
  }
}