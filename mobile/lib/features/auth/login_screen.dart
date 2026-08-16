import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_auth_service.dart';
import '../../core/services/auth_storage_service.dart';
import '../../core/services/product_tour_service.dart';
import '../../core/services/product_tour_step.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/google_logo.dart';
import '../../core/widgets/product_tour_dialog.dart';
import '../home/home_screen.dart';
import '../onboarding/business_profile_setup_screen.dart';
import 'pin_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _googleAuthInProgress = false;
  late final StreamSubscription<AuthState> _authSub;

  final _emailFieldKey = GlobalKey();
  final _googleButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      _onAuthStateChange,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProductTourDialog.showIfNeeded(
        context,
        tourKey: 'login_screen_tour',
        store: ProductTourService.instance,
        steps: [
          const ProductTourStep(
            title: 'Selamat Datang di GrowKM',
            description:
                'Masuk buat lanjutin roadmap legalitas usaha kamu, atau daftar dulu kalau belum punya akun.',
            icon: Icons.storefront_outlined,
          ),
          ProductTourStep(
            title: 'Masukin Email & Password',
            description: 'Isi email dan password akun kamu di sini.',
            icon: Icons.email_outlined,
            targetKey: _emailFieldKey,
          ),
          ProductTourStep(
            title: 'Atau Pakai Google',
            description:
                'Males inget password? Masuk langsung pakai akun Google kamu.',
            icon: Icons.login,
            targetKey: _googleButtonKey,
          ),
        ],
      );
    });
  }

  Future<void> _onAuthStateChange(AuthState data) async {
    if (data.event != AuthChangeEvent.signedIn) return;
    if (!_googleAuthInProgress) return;
    _googleAuthInProgress = false;

    await SupabaseAuthService.instance.persistCurrentSession();

    if (!mounted) return;
    setState(() => _isLoading = true);
    await _routeAfterLogin();
  }

  @override
  void dispose() {
    _authSub.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Format email belum bener';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  Future<void> _routeAfterLogin() async {
    final hasProfile = await AuthStorageService.instance.hasCompletedProfile();
    final hasPin = await AuthStorageService.instance.hasPin();

    if (!mounted) return;

    if (!hasProfile) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        BusinessProfileSetupScreen.routeName,
        (route) => false,
      );
    } else if (!hasPin) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        PinSetupScreen.routeName,
        (route) => false,
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        HomeScreen.routeName,
        (route) => false,
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await SupabaseAuthService.instance.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      await _routeAfterLogin();
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _googleAuthInProgress = true;
    });
    try {
      final launched = await SupabaseAuthService.instance.signInWithGoogle();
      if (!launched) {
        _googleAuthInProgress = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membuka halaman Google Sign In')),
          );
        }
      }
    } on AuthException catch (e) {
      _googleAuthInProgress = false;
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted && !_googleAuthInProgress) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.brandTextGradient.createShader(bounds),
                    child: Text(
                      'Selamat datang di GrowKM',
                      style: theme.textTheme.displaySmall
                          ?.copyWith(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Masuk buat lanjutin roadmap legalitas usaha kamu',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    key: _emailFieldKey,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'nama@email.com',
                      prefixIcon:
                          Icon(Icons.email_outlined, color: AppColors.primaryDark),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: AppColors.primaryDark),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.inkMuted,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.white,
                            ),
                          )
                        : const Text('Masuk'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                          child: Divider(color: AppColors.ink.withValues(alpha: 0.15))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('atau', style: theme.textTheme.bodyMedium),
                      ),
                      Expanded(
                          child: Divider(color: AppColors.ink.withValues(alpha: 0.15))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    key: _googleButtonKey,
                    onPressed: _isLoading ? null : _loginWithGoogle,
                    icon: const GoogleLogo(size: 20),
                    label: const Text('Masuk dengan Google'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: BorderSide(color: AppColors.ink.withValues(alpha: 0.15)),
                      foregroundColor: AppColors.ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}