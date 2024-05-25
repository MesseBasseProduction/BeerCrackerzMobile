import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '/src/utils/app_const.dart';
import '/src/utils/size_config.dart';

class MapOptionsView extends StatefulWidget {
  const MapOptionsView({
    super.key,
    required this.mapLayer,
    required this.showSpots,
    required this.showShops,
    required this.showBars,
    required this.setter,
  });

  final String mapLayer;
  final bool showSpots;
  final bool showShops;
  final bool showBars;
  final Function setter;

  @override
  MapOptionsViewState createState() {
    return MapOptionsViewState();
  }
}

class MapOptionsViewState extends State<MapOptionsView> {
  @override
  Widget build(
    BuildContext context,
  ) {
    SizeConfig().init(context);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    // Local working values
    String mapLayer = widget.mapLayer;
    bool showSpots = widget.showSpots;
    bool showShops = widget.showShops;
    bool showBars = widget.showBars;

    return StatefulBuilder(
      builder: (
        BuildContext context,
        StateSetter setModalState,
      ) {
        return Container(
          height: (SizeConfig.modalHeightRatio * mediaQueryData.size.height) / 100,
          color: Theme.of(context).colorScheme.background,
          // Modal inner padding
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.padding,
          ),
          child: Center(
            child: ListView(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: SizeConfig.padding,
                    ),
                    // Modal title
                    Text(
                      AppLocalizations.of(context)!.mapOptionsTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.fontTextTitleSize,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.padding,
                    ),
                    // Map layer type subtitle
                    Text(
                      AppLocalizations.of(context)!.mapOptionsLayerStyle,
                      style: TextStyle(
                        fontSize: SizeConfig.fontTextLargeSize,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.paddingSmall,
                    ),
                    // Map layer type switch
                    ToggleSwitch(
                      customWidths: [
                        mediaQueryData.size.width / 3,
                        mediaQueryData.size.width / 3,
                      ],
                      initialLabelIndex: (mapLayer == 'osm')
                        ? 0
                        : 1,
                      totalSwitches: 2,
                      labels: [
                        AppLocalizations.of(context)!.mapOptionsLayerPlan,
                        AppLocalizations.of(context)!.mapOptionsLayerSatellite,
                      ],
                      onToggle: (
                        index,
                      ) {
                        if (index == 0) {
                          mapLayer = 'osm';
                          widget.setter(
                            'mapLayer',
                            mapLayer,
                          );
                          setModalState(() {});
                        } else {
                          mapLayer = 'esri';
                          widget.setter(
                            'mapLayer',
                            mapLayer,
                          );
                          setModalState(() {});
                        }
                      },
                    ),
                    SizedBox(
                      height: SizeConfig.paddingLarge,
                    ),
                    // Displayed marker subtitle
                    Text(
                      AppLocalizations.of(context)!.mapOptionsDisplayedMarkers,
                      style: TextStyle(
                        fontSize: SizeConfig.fontTextLargeSize,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.paddingSmall,
                    ),
                    // Display spots
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image(
                          image: const AssetImage(
                            AppConst.spotImagePath,
                          ),
                          height: SizeConfig.iconSize,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.paddingSmall,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.mapOptionsDisplaySpots,
                          style: TextStyle(
                            fontSize: SizeConfig.fontTextLargeSize,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: showSpots,
                          onChanged: (
                            value,
                          ) {
                            showSpots = !showSpots;
                            widget.setter(
                              'showSpots',
                              showSpots,
                            );
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                    // Display shops
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image(
                          image: const AssetImage(
                            AppConst.shopImagePath,
                          ),
                          height: SizeConfig.iconSize,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.paddingSmall,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.mapOptionsDisplayShops,
                          style: TextStyle(
                            fontSize: SizeConfig.fontTextLargeSize,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: showShops,
                          onChanged: (
                            value,
                          ) {
                            showShops = !showShops;
                            widget.setter(
                              'showShops',
                              showShops,
                            );
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                    // Display bars
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image(
                          image: const AssetImage(
                            AppConst.barImagePath,
                          ),
                          height: SizeConfig.iconSize,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.paddingSmall,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.mapOptionsDisplayBars,
                          style: TextStyle(
                            fontSize: SizeConfig.fontTextLargeSize,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: showBars,
                          onChanged: (
                            value,
                          ) {
                            showBars = !showBars;
                            widget.setter(
                              'showBars',
                              showBars,
                            );
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: SizeConfig.padding,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
