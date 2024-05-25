import 'package:flutter/material.dart';

import '/src/beercrackerz.dart';
import '/src/settings/settings_controller.dart';
import '/src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Global app settings controller
  final settingsController = SettingsController(
    SettingsService(),
  );
  // Loading settings during splash screen
  await settingsController.loadSettings();
  // Finally start BeerCrackerzMobile app
  runApp(
    BeerCrackerzMobile(
      settingsController: settingsController,
    ),
  );
}
