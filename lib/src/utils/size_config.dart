import 'package:flutter/widgets.dart';
// A util class that gives unified sizes and values
// for a given context. It must be initialized with a
// given context each time it is used in a view.
class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  // Screen dimension and information
  static late double screenWidth;
  static late double screenHeight;
  static late double modalHeightRatio;
  static late double borderRadius;
  static late double defaultSize;
  static late Orientation orientation;
  // Spacing
  static late double paddingTiny;
  static late double paddingSmall;
  static late double padding;
  static late double paddingLarge;
  static late double paddingBig;
  static late double paddingHuge;
  // Icon sizes
  static late double inputIcon;
  static late double iconSize;
  static late double mapMarkerSize;
  // Font sizes
  static late double fontTextSmallSize;
  static late double fontTextSize;
  static late double fontTextLargeSize;
  static late double fontTextBigSize;
  static late double fontTextTitleSize;
  // Init size config for a given context
  void init(
    BuildContext context,
  ) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    modalHeightRatio = 66;
    borderRadius = 10.0;
    orientation = _mediaQueryData.orientation;
    defaultSize = (orientation == Orientation.landscape)
      ? screenHeight * 0.024
      : screenWidth * 0.024;
    // Spacing
    paddingTiny = (defaultSize / 2);
    paddingSmall = defaultSize;
    padding = (defaultSize * 2);
    paddingLarge = (defaultSize * 3);
    paddingBig = (defaultSize * 4);
    paddingHuge = (defaultSize * 6);
    // Icon sizes
    inputIcon = (defaultSize * 2);
    iconSize = 24;
    mapMarkerSize = 30;
    // Font sizes
    fontTextSmallSize = 12;
    fontTextSize = 14;
    fontTextLargeSize = 18;
    fontTextBigSize = 24;
    fontTextTitleSize = 32;
  }
}
