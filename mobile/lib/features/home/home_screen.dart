import 'package:flutter/material.dart';
import '../../core/services/supabase_auth_service.dart';
import '../auth/login_screen.dart';
import '../kbli/pages/kbli_page.dart';
import '../lexa/pages/lexa_chat.dart';
import 'widgets/bottom_navbar.dart';
import 'widgets/coming_soon.dart';
import 'pages/beranda_page.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppPage _currentPage = AppPage.beranda;

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
          BerandaPage(onLogout: _logout, onNavigateTab: _navigateToTab),
          const KbliMatcherPage(),
          const LexaChatPage(),
          const ComingSoonPage(
            title: 'Snap Cash',
            emoji: '💸',
            description: 'Catat & pantau kas usahamu di sini.',
          ),
          const ComingSoonPage(
            title: 'Market Gate',
            emoji: '🛍️',
            description: 'Buka akses pasar buat produk UMKM kamu.',
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentPage: _currentPage,
        onNavigate: _navigateToTab,
      ),
    );
  }
}