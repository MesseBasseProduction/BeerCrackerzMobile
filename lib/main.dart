import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

import '/src/beercrackerz.dart';
import '/src/settings/settings_controller.dart';
import '/src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load env variables
  await dotenv.load(
    fileName: '.env',
  );
  // Global app settings controller
  final settingsController = SettingsController(
    SettingsService(),
  );
  // Loading settings during splash screen
  await settingsController.loadSettings();
  // Load tile caching engine
  await FMTCObjectBoxBackend().initialise();
  await const FMTCStore('beercrackerz-cache-storage').manage.create();
  // Finally start BeerCrackerzMobile app
  runApp(
    BeerCrackerzMobile(
      settingsController: settingsController,
    ),
  );
}
