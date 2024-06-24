import 'dart:convert';

import 'package:flutter/material.dart';

import '/src/auth/profile_service.dart';
import '/src/settings/settings_service.dart';
// An abstract controller class for handling settings.
// This object may be given to views so they can get and set
// settings values.
class SettingsController with ChangeNotifier {
  SettingsController(
    this._settingsService,
  );
  // Settings service to access device and secure storage
  final SettingsService _settingsService;
  // App stored settings
  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;
  late Locale _appLocale;
  Locale get appLocale => _appLocale;
  late bool _showWelcomeScreen;
  bool get showWelcomeScreen => _showWelcomeScreen;
  // Auth internals / user infos
  late bool isLoggedIn;
  int userId = -1; // Must be iniatialized
  late String username;
  late String email;
  late String ppPath;
  late bool isUserActive;
  late bool isUserStaff;
  // Load settings from storage. Required before loading app
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _appLocale = await _settingsService.appLocale();
    _showWelcomeScreen = await _settingsService.showWelcomeScreen();
    String token = await _settingsService.getAuthToken();
    if (token != '') {
      if (await _settingsService.isAuthTokenExpired() == true) {
        isLoggedIn = false;
      } else {
        // Call server to request user info
        isLoggedIn = await getUserInfo();
      }
    } else {
      isLoggedIn = false;
    }
    // Finally notify listener that settings are loaded, app can be started
    notifyListeners();
  }

  /* App global settings setters */

  // Update app UI theme
  Future<void> updateThemeMode(
    ThemeMode? newThemeMode,
  ) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    await _settingsService.updateThemeMode(newThemeMode);
    notifyListeners();
  }
  // Update app locale
  Future<void> updateAppLocale(
    Locale? newLocale,
  ) async {
    if (newLocale == null) return;
    if (newLocale == _appLocale) return;
    _appLocale = newLocale;
    await _settingsService.updateAppLocale(newLocale);
    notifyListeners();
  }
  // Update show welcome screen
  Future<void> updateShowWelcomeScreen(
    bool? showWelcomeScreen,
  ) async {
    if (showWelcomeScreen == null) return;
    if (showWelcomeScreen == _showWelcomeScreen) return;
    _showWelcomeScreen = showWelcomeScreen;
    await _settingsService.updateShowWelcomeScreen(showWelcomeScreen);
    notifyListeners();
  }

  /* Auth related methods */

  // Update the user JWT token
  Future<bool> updateAuthToken(
    String? expiry,
    String? token,
  ) async {
    if (expiry == null || token == null) return false;
    await _settingsService.updateAuthToken(
      expiry,
      token,
    );
    notifyListeners();
    return true;
  }
  // Test that the user token is expired or not
  Future<bool> isAuthTokenExpired() async {
    return await _settingsService.isAuthTokenExpired();
  }
  // Get JWT token from secured storage
  Future<String> getAuthToken() async {
    return _settingsService.getAuthToken();
  }
  // Fetch user information and store them, only if token if saved on secure storage
  Future<bool> getUserInfo() async {
    bool loggedIn = false;
    String token = await _settingsService.getAuthToken();
    if (token != '') {
      await ProfileService.getUserInfo(token).then((response) {
        if (response.statusCode == 200) {
          final parsedJson = jsonDecode(response.body);
          userId = parsedJson['id'];
          username = parsedJson['username'];
          email = parsedJson['email'];
          ppPath = parsedJson['profilePicture'];
          isUserActive = parsedJson['isActive'];
          isUserStaff = parsedJson['isStaff'];
          loggedIn = true;
        } else {
          loggedIn = false;
        }
      }).catchError((error) {
        loggedIn = false;
      });
    } else {
      loggedIn = false;
    }
    return loggedIn;
  }
  // Clear user info internal, usefull on logout
  bool resetUserInfo() {
    userId = -1;
    username = '';
    email = '';
    ppPath = '';
    isUserActive = false;
    isUserStaff = false;
    return false;
  }
}
