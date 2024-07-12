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
  late ThemeMode themeMode;
  late Locale appLocale;
  late bool showWelcomeScreen;
  late bool leftHanded;
  // Map saved settings
  late String mapLayer;
  late bool showSpots;
  late bool showShops;
  late bool showBars;
  late bool showOnlySelf; // Display only user's markers
  late double initLat;
  late double initLng;
  late double initZoom;
  // Auth internals & user infos
  late bool isLoggedIn;
  int userId = -1; // Must be iniatialized
  late String username;
  late String email;
  late String ppPath;
  late bool isUserActive;
  late bool isUserStaff;
  // Mark stats
  int totalMarks = 0;
  late int userSpotAdded;
  late int userShopAdded;
  late int userBarAdded;

  // Load settings from storage. Required before loading app
  Future<void> loadSettings() async {
    // App settings loading
    themeMode = await _settingsService.themeMode();
    appLocale = await _settingsService.appLocale();
    showWelcomeScreen = await _settingsService.showWelcomeScreen();
    leftHanded = await _settingsService.leftHanded();
    // Map settings loading
    mapLayer = await _settingsService.mapLayer();
    showSpots = await _settingsService.showSpots();
    showShops = await _settingsService.showShops();
    showBars = await _settingsService.showBars();
    showOnlySelf = await _settingsService.showOnlySelf();
    initLat = await _settingsService.initialLat();
    initLng = await _settingsService.initialLng();
    initZoom = await _settingsService.initialZoom();
    // Auth loading
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
    if (newThemeMode == themeMode) return;
    themeMode = newThemeMode;
    await _settingsService.updateThemeMode(themeMode);
    notifyListeners();
  }
  // Update app locale
  Future<void> updateAppLocale(
    Locale? newLocale,
  ) async {
    if (newLocale == null) return;
    if (newLocale == appLocale) return;
    appLocale = newLocale;
    await _settingsService.updateAppLocale(appLocale);
    notifyListeners();
  }
  // Update show welcome screen
  Future<void> updateShowWelcomeScreen(
    bool newShowWelcomeScreen,
  ) async {
    if (showWelcomeScreen == newShowWelcomeScreen) return;
    showWelcomeScreen = newShowWelcomeScreen;
    await _settingsService.updateShowWelcomeScreen(showWelcomeScreen);
    notifyListeners();
  }
  // Update left handed preference
  Future<void> updateLeftHanded(
    bool newLeftHanded,
  ) async {
    if (leftHanded == newLeftHanded) return;
    leftHanded = newLeftHanded;
    await _settingsService.updateLeftHanded(leftHanded);
    notifyListeners(); 
  }
  
  // Update the saved preference for the map base layer
  Future<void> updateMapLayer(
    String newMapLayer
  ) async {
    if (newMapLayer != 'osm' && newMapLayer != 'esri') return;
    if (mapLayer == newMapLayer) return;
    mapLayer = newMapLayer;
    await _settingsService.updateMapLayer(mapLayer);
    notifyListeners();
  }
  // Update the saved preference to only display spots
  Future<void> updateShowSpots(
    bool value
  ) async {
    if (showSpots == value) return;
    showSpots = value;
    await _settingsService.updateShowSpots(showSpots);
    notifyListeners();
  }
  // Update the saved preference to only display shops
  Future<void> updateShowShops(
    bool value
  ) async {
    if (showShops == value) return;
    showShops = value;
    await _settingsService.updateShowShops(showShops);
    notifyListeners();
  }
  // Update the saved preference to only display bars
  Future<void> updateShowBars(
    bool value
  ) async {
    if (showBars == value) return;
    showBars = value;
    await _settingsService.updateShowBars(showBars);
    notifyListeners();
  }
  // Update the saved preference to only display user's marks
  Future<void> updateShowOnlySelf(
    bool value
  ) async {
    if (showOnlySelf == value) return;
    showOnlySelf = value;
    await _settingsService.updateShowOnlySelf(showOnlySelf);
    notifyListeners();
  }
  // Update initial lat/lng position
  Future<void> updateInitialPosition(
    double lat,
    double lng,
    double zoom,
  ) async {
    if (lat < -90 || lat > 90) return;
    if (lng < -180 || lng > 180) return;
    if (zoom < 2 || zoom > 19) return;
    initLat = lat;
    initLng = lng;
    initZoom = zoom;
    await _settingsService.updateInitialPosition(lat, lng, zoom);
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
          if (parsedJson['profilePicture'] == null) {
            ppPath = 'assets/images/icon/profile.png';
          } else {
            ppPath = parsedJson['profilePicture'];
          }
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

  /* Marks stats */
  void updateMarkStats(
    int newTotalMarks,
    int newUserSpotAdded,
    int newUserShopAdded,
    int newUserBarAdded,
  ) {
    totalMarks = newTotalMarks;
    userSpotAdded = newUserSpotAdded;
    userShopAdded = newUserShopAdded;
    userBarAdded = newUserBarAdded;
  }
}
