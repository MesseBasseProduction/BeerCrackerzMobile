import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/src/utils/app_const.dart';
// The service responsible for saving preferences to
// the device shared preferences so they are persistent
// upon app restart.
class SettingsService {
  // Secure storage for authentification JWT token
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /* Getters */

  // Loads the user's preferred ThemeMode from device storage
  Future<ThemeMode> themeMode() async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    // Read preference from device shared preference storage
    String? value = appPreferences.getString('bc-theme');
    if (value == 'light') {
      await appPreferences.setString(
        'bc-theme',
        'light',
      );
      return ThemeMode.light;
    } else {
      // Default theme to dark mode
      await appPreferences.setString(
        'bc-theme',
        'dark',
      );
      return ThemeMode.dark;
    }
  }
  // Loads the user's preffered Locale from device storage
  Future<Locale> appLocale() async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    // Read preference from device shared preference storage
    String? value = appPreferences.getString('bc-locale');
    // First app start or preferences are empty
    if (value == null) {
      // Extract device locale
      String deviceLocale = Platform.localeName.substring(0, 2);
      if (AppConst.supportedLang.contains(value) == false) {
        // English locale by default, device locale not supported in app
        await appPreferences.setString(
          'bc-locale',
          'en',
        );
        return const Locale.fromSubtags(
          languageCode: 'en',
        );
      } else {
        // Use device locale, set saved preference
        await appPreferences.setString(
          'bc-locale',
          deviceLocale,
        );
        return Locale.fromSubtags(
          languageCode: deviceLocale,
        );
      }
    } else {
      // Retrun saved preference for locale
      return Locale.fromSubtags(
        languageCode: value,
      );
    }
  }
  // Wether to display the welcome screen poresentingbeercrackerz to the user
  Future<bool> showWelcomeScreen() async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    // Read preference from device shared preference storage
    String? value = appPreferences.getString('bc-show-welcome-screen');
    // First app launch, set pref value to true and return true
    if (value == null) {
      await appPreferences.setString(
        'bc-show-welcome-screen',
        'true',
      );
      return true;
    } else {
      // Else read saved value
      if (value == 'true') {
        return true;
      } else {
        return false;        
      }
    }
  }
  // Returns left handed preference
  Future<bool> leftHanded() async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    // Read preference from device shared preference storage
    String? value = appPreferences.getString('bc-left-handed');
    // First app launch, set pref value to true and return true
    if (value == null) {
      await appPreferences.setString(
        'bc-left-handed',
        'false',
      );
      return false;
    } else {
      // Else read saved value
      if (value == 'true') {
        return true;
      } else {
        return false;        
      }
    }
  }
  
  // The map base layer to use
  Future<String> mapLayer() async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    // Read preference from device shared preference storage
    String? value = appPreferences.getString('bc-map-layer');
    // First app launch, set pref value to true and return true
    if (value == null) {
      await appPreferences.setString(
        'bc-map-layer',
        'osm',
      );
      return 'osm';
    } else {
      return value;
    }
  }
  // Map filtering to display spots on map or not
  Future<bool> showSpots() async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    // Read preference from device shared preference storage
    String? value = appPreferences.getString('bc-show-spots');
    // First app launch, set pref value to true and return true
    if (value == null) {
      await appPreferences.setString(
        'bc-show-spots',
        'true',
      );
      return true;
    } else {
      // Else read saved value
      if (value == 'true') {
        return true;
      } else {
        return false;        
      }
    }
  }
  // Map filtering to display shops on map or not
  Future<bool> showShops() async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    // Read preference from device shared preference storage
    String? value = appPreferences.getString('bc-show-shops');
    // First app launch, set pref value to true and return true
    if (value == null) {
      await appPreferences.setString(
        'bc-show-shops',
        'true',
      );
      return true;
    } else {
      // Else read saved value
      if (value == 'true') {
        return true;
      } else {
        return false;        
      }
    }
  }
  // Map filtering to display bars on map or not
  Future<bool> showBars() async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    // Read preference from device shared preference storage
    String? value = appPreferences.getString('bc-show-bars');
    // First app launch, set pref value to true and return true
    if (value == null) {
      await appPreferences.setString(
        'bc-show-bars',
        'true',
      );
      return true;
    } else {
      // Else read saved value
      if (value == 'true') {
        return true;
      } else {
        return false;        
      }
    }
  }
  // Display only the user's marks on the map
  Future<bool> showOnlySelf() async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    // Read preference from device shared preference storage
    String? value = appPreferences.getString('bc-show-self');
    // First app launch, set pref value to true and return true
    if (value == null) {
      await appPreferences.setString(
        'bc-show-self',
        'false',
      );
      return false;
    } else {
      // Else read saved value
      if (value == 'true') {
        return true;
      } else {
        return false;        
      }
    }
  }
  // Returns initial stored lat position
  Future<double> initialLat() async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    double? value = appPreferences.getDouble('bc-initial-pos-lat');
    if (value == null) {
      await appPreferences.setDouble(
        'bc-initial-pos-lat',
        48.8605277263,
      );
      return 48.8605277263;
    } else {
      return value;
    }
  }
  // Returns initial stored lng position
  Future<double> initialLng() async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    double? value = appPreferences.getDouble('bc-initial-pos-lng');
    if (value == null) {
      await appPreferences.setDouble(
        'bc-initial-pos-lng',
        2.34402407374,
      );
      return 2.34402407374;
    } else {
      return value;
    }
  }
  // Returns initial stored lng position
  Future<double> initialZoom() async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    double? value = appPreferences.getDouble('bc-initial-pos-zoom');
    if (value == null) {
      await appPreferences.setDouble(
        'bc-initial-pos-zoom',
        11.0,
      );
      return 11.0;
    } else {
      return value;
    }
  }

  /* Setters */

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
    await appPreferences.setString(
      'bc-theme',
      value,
    );
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
    await appPreferences.setString(
      'bc-locale',
      value,
    );
  }
  // Update the saved preference for show welcome screen
  Future<void> updateShowWelcomeScreen(
    bool value,
  ) async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    if (value == true) {
      await appPreferences.setString(
        'bc-show-welcome-screen',
        'true',
      );      
    } else {
      await appPreferences.setString(
        'bc-show-welcome-screen',
        'false',
      );      
    }
  }
  // Update left handed saved value
  Future<void> updateLeftHanded(
    bool value,
  ) async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    if (value == true) {
      await appPreferences.setString(
        'bc-left-handed',
        'true',
      );      
    } else {
      await appPreferences.setString(
        'bc-left-handed',
        'false',
      );      
    }
  }
  
  // Update the saved preference for the map base layer
  Future<void> updateMapLayer(
    String mapLayer
  ) async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    String value = 'osm';
    if (mapLayer == 'esri') {
      value = 'esri';
    }
    // Update stored app preferences
    await appPreferences.setString(
      'bc-map-layer',
      value,
    );    
  }
  // Update the saved preference to only display spots
  Future<void> updateShowSpots(
    bool value
  ) async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    if (value == true) {
      await appPreferences.setString(
        'bc-show-spots',
        'true',
      );      
    } else {
      await appPreferences.setString(
        'bc-show-spots',
        'false',
      );      
    }
  }
  // Update the saved preference to only display shops
  Future<void> updateShowShops(
    bool value
  ) async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    if (value == true) {
      await appPreferences.setString(
        'bc-show-shops',
        'true',
      );      
    } else {
      await appPreferences.setString(
        'bc-show-shops',
        'false',
      );      
    }
  }
  // Update the saved preference to only display bars
  Future<void> updateShowBars(
    bool value
  ) async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    if (value == true) {
      await appPreferences.setString(
        'bc-show-bars',
        'true',
      );      
    } else {
      await appPreferences.setString(
        'bc-show-bars',
        'false',
      );      
    }
  }
  // Update the saved preference to only display user's marks
  Future<void> updateShowOnlySelf(
    bool value
  ) async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    if (value == true) {
      await appPreferences.setString(
        'bc-show-self',
        'true',
      );      
    } else {
      await appPreferences.setString(
        'bc-show-self',
        'false',
      );      
    }
  }
  // Update the saved initial position to restore map to latest view position on map
  Future<void> updateInitialPosition(
    double lat,
    double lng,
    double zoom,
  ) async {
    final SharedPreferences appPreferences = await SharedPreferences.getInstance();
    await appPreferences.setDouble(
      'bc-initial-pos-lat',
      lat,
    );
    await appPreferences.setDouble(
      'bc-initial-pos-lng',
      lng,
    );
    await appPreferences.setDouble(
      'bc-initial-pos-zoom',
      zoom,
    );
  }
  
  /* Auth */
  
  // Persists the user's JWT token in device secure storage
  Future<void> updateAuthToken(
    String expiry,
    String token,
  ) async {
    // Extract token expiry and value from secure storage
    String? tokenExpiry = await _secureStorage.read(
      key: 'auth-expiry',
    );
    String? tokenValue = await _secureStorage.read(
      key: 'auth-token',
    );
    // Don't update token if its identical
    if (expiry == tokenExpiry && token == tokenValue) return;
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
    // Extract token expiration from secure storage
    String? expiry = await _secureStorage.read(
      key: 'auth-expiry',
    );
    // Expiry not saved in secure storage, return true
    if (expiry == null) return true;
    try {
      // Perform date parsing on token expiration string
      DateTime expiryDateTime = DateTime.parse(expiry);
      DateTime nowDate = DateTime.now();
      // Expiry date is passed
      if (nowDate.isAfter(expiryDateTime)) {
        return true;
      }
      return false;
    } catch (e) {
      // Return false if anything went wrong in the date parsing process
      return true;
    }
  }
  // Return the user's JWT token if any saved in secure storage
  Future<String> getAuthToken() async {
    // Extract expiry and token from secure storage
    String? expiry = await _secureStorage.read(
      key: 'auth-expiry',
    );
    String? token = await _secureStorage.read(
      key: 'auth-token',
    );
    // If null, return empty string to caller
    if (expiry == null && token == null) return '';
    // Otherwise, send token back
    return token!;
  }
}
