import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  late Locale _appLocale;
  Locale get appLocale => _appLocale;

  late bool isLoggedIn;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _appLocale = await _settingsService.appLocale();

    if (await _secureStorage.read(key: 'auth-expiry') != null && await _secureStorage.read(key: 'auth-token') != null) {
      if (await isAuthTokenExpired() == true) {
        isLoggedIn = false;      
      } else {
        isLoggedIn = true;        
      }
    } else {
      isLoggedIn = false;
    }

    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateAppLocale(Locale? newLocale) async {
    if (newLocale == null) return;
    if (newLocale == _appLocale) return;
    _appLocale = newLocale;
    notifyListeners();
    await _settingsService.updateAppLocale(newLocale);
  }

  // Auth section

  Future<void> updateAuthToken(String? expiry, String? token) async {
    if (expiry == null || token == null) return;
    if (expiry == await _secureStorage.read(key: 'auth-expiry')) return;
    if (token == await _secureStorage.read(key: 'auth-token')) return;
    await _secureStorage.write(key: 'auth-expiry', value: expiry);
    await _secureStorage.write(key: 'auth-token', value: token);
    notifyListeners();
    await _settingsService.updateAuthToken(expiry, token);
  }

  Future<bool> isAuthTokenExpired() async {
    if (await _secureStorage.read(key: 'auth-expiry') == null) return true;
    final String expiry = (await _secureStorage.read(key: 'auth-expiry'))!;
    try {
      DateTime expiryDateTime = DateTime.parse(expiry);
      DateTime nowDate = DateTime.now();
      // Expiry date is not valid anymore
      if (nowDate.isAfter(expiryDateTime)) {
        return true;
      }
      return false;
    } catch (e) {
      return true;
    }
  }

  Future<String> getAuthToken() async {
    if (await _secureStorage.read(key: 'auth-expiry') == null && await _secureStorage.read(key: 'auth-token') == null) return '';
    return (await _secureStorage.read(key: 'auth-token'))!;
  }
}
