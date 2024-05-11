import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double defaultSize;
  static late double borderRadius;
  static late double inputIcon;
  static late Orientation orientation;
  static late double fontTitleSize;
  static late double fontTextSize;
  static late double fontTextLargeSize;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    defaultSize = (orientation == Orientation.landscape)
      ? screenHeight * 0.024
      : screenWidth * 0.024;
    borderRadius = 10.0;
    inputIcon = defaultSize * 2;
    // Font sizes
    fontTitleSize = 32;
    fontTextSize = 14;
    fontTextLargeSize = 18;
  }
}
