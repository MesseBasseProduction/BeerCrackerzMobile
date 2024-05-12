import 'package:flutter/widgets.dart';
// A util class that gives unified sizes and values
// for a given context.
class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  // Screen dimension and information
  static late double screenWidth;
  static late double screenHeight;
  static late double borderRadius;
  static late double defaultSize;
  static late Orientation orientation;
  // Icon sizes
  static late double inputIcon;
  // Font sizes
  static late double fontTitleSize;
  static late double fontTextSize;
  static late double fontTextLargeSize;
  static late double fontTextBigSize;
  // Init size config for a given context
  void init(
    BuildContext context,
  ) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    borderRadius = 10.0;
    orientation = _mediaQueryData.orientation;
    defaultSize = (orientation == Orientation.landscape)
      ? screenHeight * 0.024
      : screenWidth * 0.024;
    inputIcon = defaultSize * 2;
    // Font sizes
    fontTitleSize = 32;
    fontTextSize = 14;
    fontTextLargeSize = 18;
    fontTextBigSize = 24;
  }
}
