import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
// The service responsible for saving preferences to 
// the device shared preferences so they are persistent
// upon app restart.
class SettingsService {
  // Secure storage for authentification JWT token
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  // Loads the user's preferred ThemeMode from device storage
  Future<ThemeMode> themeMode() async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    // Read preference from device shared preference storage
    String? value = appPreferences.getString('bc-theme');
    if (value == 'light') {
      await appPreferences.setString('bc-theme', 'light');
      return ThemeMode.light;
    } else {
      // Default theme to dark mode
      await appPreferences.setString('bc-theme', 'dark');
      return ThemeMode.dark;
    }
  }
  // Loads the user's preffered Locale from device storage
  Future<Locale> appLocale() async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    // Read preference from device shared preference storage
    String? value = appPreferences.getString('bc-locale');
    // First app start or preferences empty
    if (value == null) {
      String deviceLocale = Platform.localeName.substring(0, 2);
      if (['en', 'fr', 'es', 'de', 'it', 'pt'].contains(value) == false) {
        // English locale by default
        await appPreferences.setString('bc-locale', 'en');
        return const Locale.fromSubtags(languageCode: 'en');
      } else {
        // Use device locale
        await appPreferences.setString('bc-locale', deviceLocale);
        return Locale.fromSubtags(languageCode: deviceLocale);
      }
    } else {
      return Locale.fromSubtags(languageCode: value);      
    }
  }
  // Persists the user's preferred ThemeMode to device storage
  Future<void> updateThemeMode(
    ThemeMode theme,
  ) async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    String value = 'dark'; // Dark theme by default
    if (theme == ThemeMode.light) {
      value = 'light';
    }
    // Update stored app preferences
    await appPreferences.setString('bc-theme', value);
  }
  // Persists the user's preferred Locale to device storage
  Future<void> updateAppLocale(
    Locale locale,
  ) async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    String value = 'en'; // English locale by default
    switch (locale.toString()) {
      case 'fr':
        value = 'fr';
      case 'es':
        value = 'es';
        break;
      case 'de':
        value = 'de';
      case 'it':
        value = 'it';
      case 'pt':
        value = 'pt';
      default:
        value = 'en';
    }
    // Update stored app preferences
    await appPreferences.setString('bc-locale', value);
  }
  // Persists the user's JWT token in device secure storage
  Future<void> updateAuthToken(
    String expiry,
    String token,
  ) async {
    // Don't update token if its identical
    if (expiry == await _secureStorage.read(key: 'auth-expiry') && token == await _secureStorage.read(key: 'auth-token')) return;
    // Otherwise, write expiration and token into secure storage
    await _secureStorage.write(
      key: 'auth-expiry',
      value: expiry,
    );
    await _secureStorage.write(
      key: 'auth-token',
      value: token,
    );
  }
  // Returns a bool state for token expired state
  Future<bool> isAuthTokenExpired() async {
    if (await _secureStorage.read(key: 'auth-expiry') == null) return true;
    final String expiry = (await _secureStorage.read(key: 'auth-expiry'))!;
    try {
      DateTime expiryDateTime = DateTime.parse(expiry);
      DateTime nowDate = DateTime.now();
      // Expiry date is passed
      if (nowDate.isAfter(expiryDateTime)) {
        return true;
      }
      return false;
    } catch (e) {
      return true;
    }
  }
  // Return the user's JWT token if any saved in secure storage
  Future<String> getAuthToken() async {
    if (await _secureStorage.read(key: 'auth-expiry') == null && await _secureStorage.read(key: 'auth-token') == null) return '';
    return (await _secureStorage.read(key: 'auth-token'))!;
  }
}
