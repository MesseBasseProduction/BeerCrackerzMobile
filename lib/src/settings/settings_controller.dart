import 'package:flutter/material.dart';

import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  late Locale _appLocale;
  Locale get appLocale => _appLocale;


  late bool isLoggedIn;
  late String savedExpiry = '';
  late String savedToken = '';

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _appLocale = await _settingsService.appLocale();
    isLoggedIn = false;
    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;
    // Otherwise, store the new ThemeMode in memory
    _themeMode = newThemeMode;
    // Important! Inform listeners a change has occurred.
    notifyListeners();
    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateThemeMode(newThemeMode);
  }

  /// Update and persist the app locale
  Future<void> updateAppLocale(Locale? newLocale) async {
    if (newLocale == null) return;
    if (newLocale == _appLocale) return;
    _appLocale = newLocale;
    notifyListeners();
    await _settingsService.updateAppLocale(newLocale);
  }

  Future<void> updateAuthToken(String? expiry, String? token) async {
    if (expiry == null || token == null) return;
    if (expiry == savedExpiry) return;
    if (token == savedToken) return;
    savedExpiry = expiry;
    savedToken = token;
    notifyListeners();
    await _settingsService.updateAuthToken(expiry, token);
  }
}
