import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConst {
  static const String appVersion = '0.0.8';
  static const String serverVersion = '0.1.0';
  // The server URL to reach, ensure no trailing slash remains
  static const String baseURL = 'https://beercrackerz.org';
  // Local assets to  be used on the map
  static const String spotImagePath = 'assets/images/marker/marker-icon-green.png';
  static const String shopImagePath = 'assets/images/marker/marker-icon-blue.png';
  static const String barImagePath = 'assets/images/marker/marker-icon-red.png';
  static const String wipMarkerImagePath = 'assets/images/marker/marker-icon-black.png';
  static const List<String> supportedLang = ['en', 'fr', 'es', 'de', 'it', 'pt'];
  static const int maxDistanceForRoute = 10000; // 10km is max range for route to be computed
  static String? osrApiKey = dotenv.env['OSR_API_KEY'];
}
