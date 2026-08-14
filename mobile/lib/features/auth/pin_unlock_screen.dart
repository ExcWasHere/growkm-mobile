import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_storage_service.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/numeric_keypad.dart';
import '../../core/widgets/pin_dots.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class PinUnlockScreen extends StatefulWidget {
  static const routeName = '/pin-unlock';
  const PinUnlockScreen({super.key});

  @override
  State<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends State<PinUnlockScreen> {
  static const _pinLength = 6;
  final _auth = LocalAuthentication();

  String _pin = '';
  bool _hasError = false;
  bool _isVerifying = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometricUnlock());
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (mounted) {
        setState(() => _biometricAvailable = canCheck && isSupported);
      }
    } catch (_) {
      if (mounted) setState(() => _biometricAvailable = false);
    }
  }

  Future<void> _tryBiometricUnlock() async {
    if (!_biometricAvailable) return;
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Verifikasi identitas kamu buat masuk GrowKM',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (authenticated) _onUnlockSuccess();
    } catch (_) {
    }
  }

  void _onKeyTap(String value) {
    if (_isVerifying || _pin.length >= _pinLength) return;
    setState(() {
      _pin += value;
      _hasError = false;
    });
    if (_pin.length == _pinLength) _verifyPin();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _hasError = false;
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);
    final isValid = await AuthStorageService.instance.verifyPin(_pin);

    if (!mounted) return;

    if (isValid) {
      _onUnlockSuccess();
    } else {
      setState(() {
        _hasError = true;
        _pin = '';
        _isVerifying = false;
      });
    }
  }

  void _onUnlockSuccess() {
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      DashboardScreen.routeName,
      (route) => false,
    );
  }

  Future<void> _logout() async {
    await AuthStorageService.instance.clearAll();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      LoginScreen.routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Text(
                  'Masukkan PIN',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _hasError ? 'PIN salah, coba lagi' : 'Selamat datang kembali',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _hasError ? AppColors.error : null,
                  ),
                ),
                const SizedBox(height: 32),
                PinDots(
                  length: _pinLength,
                  filled: _pin.length,
                  hasError: _hasError,
                ),
                const Spacer(flex: 2),
                NumericKeypad(
                  onKeyTap: _onKeyTap,
                  onBackspace: _onBackspace,
                  onBiometricTap: _biometricAvailable ? _tryBiometricUnlock : null,
                  showBiometric: _biometricAvailable,
                ),
                const Spacer(flex: 1),
                TextButton(
                  onPressed: _logout,
                  child: Text(
                    'Bukan kamu? Keluar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}