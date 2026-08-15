import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/pin_unlock_screen.dart';
import 'features/auth/pin_setup_screen.dart';
import 'features/auth/biometric_setup_screen.dart';
import 'features/onboarding/business_profile_setup_screen.dart';
import 'features/home/home_screen.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  runApp(const GrowKMApp());
}

class GrowKMApp extends StatelessWidget {
  const GrowKMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrowKM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        PinUnlockScreen.routeName: (_) => const PinUnlockScreen(),
        BusinessProfileSetupScreen.routeName: (_) => const BusinessProfileSetupScreen(),
        PinSetupScreen.routeName: (_) => const PinSetupScreen(),
        BiometricSetupScreen.routeName: (_) => const BiometricSetupScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
      },
    );
  }
}