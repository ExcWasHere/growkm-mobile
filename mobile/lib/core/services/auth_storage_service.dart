import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  AuthStorageService._();
  static final AuthStorageService instance = AuthStorageService._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyPinHash = 'growkm_pin_hash';
  static const _keyPinSalt = 'growkm_pin_salt';
  static const _keyLastLoginAt = 'growkm_last_login_at';
  static const _keySupabaseRefreshToken = 'growkm_supabase_refresh_token';
  static const _keyProfileComplete = 'growkm_profile_complete';
  static const _keyBiometricEnabled = 'growkm_biometric_enabled';
  static const int _sessionValidDays = 30;

  Future<void> saveSession(String refreshToken) async {
    await _storage.write(key: _keySupabaseRefreshToken, value: refreshToken);
    await _storage.write(
      key: _keyLastLoginAt,
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<bool> hasValidSession() async {
    final refreshToken = await _storage.read(key: _keySupabaseRefreshToken);
    final lastLoginStr = await _storage.read(key: _keyLastLoginAt);
    if (refreshToken == null || lastLoginStr == null) return false;
    final lastLogin = DateTime.tryParse(lastLoginStr);
    if (lastLogin == null) return false;
    final daysSinceLogin = DateTime.now().difference(lastLogin).inDays;
    return daysSinceLogin < _sessionValidDays;
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _keySupabaseRefreshToken);
  }

  Future<void> extendSession() async {
    await _storage.write(
      key: _keyLastLoginAt,
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _keySupabaseRefreshToken);
    await _storage.delete(key: _keyLastLoginAt);
  }

  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _keyPinHash);
    return hash != null;
  }

  Future<void> savePin(String pin) async {
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = _hashPin(pin, salt);
    await _storage.write(key: _keyPinSalt, value: salt);
    await _storage.write(key: _keyPinHash, value: hash);
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(key: _keyPinSalt);
    final storedHash = await _storage.read(key: _keyPinHash);
    if (salt == null || storedHash == null) return false;

    final hash = _hashPin(pin, salt);
    return hash == storedHash;
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _keyPinHash);
    await _storage.delete(key: _keyPinSalt);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$pin:$salt');
    return sha256.convert(bytes).toString();
  }

  Future<void> setBiometricEnabled(bool value) async {
    await _storage.write(key: _keyBiometricEnabled, value: value.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }

  Future<void> setProfileComplete(bool value) async {
    await _storage.write(key: _keyProfileComplete, value: value.toString());
  }

  Future<bool> hasCompletedProfile() async {
    final value = await _storage.read(key: _keyProfileComplete);
    return value == 'true';
  }

  Future<void> clearAll() async {
    await clearSession();
    await clearPin();
    await _storage.delete(key: _keyProfileComplete);
    await _storage.delete(key: _keyBiometricEnabled);
  }
}