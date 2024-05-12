import 'package:beercrackerz/src/map/marker/marker_data.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:beercrackerz/src/map/map_view.dart';
import 'package:beercrackerz/src/map/map_service.dart';

class NewPOIView extends StatefulWidget {
  const NewPOIView({
    super.key,
    required this.mapView,
    required this.data,
    required this.callback
  });

  final MapView mapView;
  final MarkerData data;
  final Function callback;

  @override
  NewPOIViewState createState() {
    return NewPOIViewState();
  }
}

class NewPOIViewState extends State<NewPOIView> {
  String poiType = 'spot';
  // Must be defined in here instead of MarkerView to avoid reset each build call
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    int screenHeightRatio = 66;

    return Container(
      height: (screenHeightRatio * mediaQueryData.size.height) / 100, // Taking screenHeightRatio % of screen height
      width: mediaQueryData.size.width,
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              (poiType == 'spot')
              ? AppLocalizations.of(context)!.newSpotTitle
              : (poiType == 'shop')
                ? AppLocalizations.of(context)!.newShopTitle
                : AppLocalizations.of(context)!.newBarTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
            ),
            // POI type switch
            ToggleSwitch(
              customWidths: [mediaQueryData.size.width / 4, mediaQueryData.size.width / 4, mediaQueryData.size.width / 4],
              initialLabelIndex: (poiType == 'spot') ? 0 : (poiType == 'shop') ? 1 : 2,
              totalSwitches: 3,
              labels: const ['Spot', 'Shop', 'Bar'],
              onToggle: (index) {
                if (index == 0) {
                  setState(() => poiType = 'spot');
                } else if (index == 1) {
                  setState(() => poiType = 'shop');
                } else {
                  setState(() => poiType = 'bar');
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
            ),
            // BottomModal content built depending on switch value
            SingleChildScrollView(
              child: (poiType == 'spot')
                ? MapService.buildNewSpotModal(context, widget.mapView, poiType, _formKey, widget.data, widget.callback)
                : (poiType == 'shop')
                  ? MapService.buildNewShopModal(context, widget.mapView, poiType, _formKey, widget.data, widget.callback)
                  : MapService.buildNewBarModal(context, widget.mapView, poiType, _formKey, widget.data, widget.callback),
            ),
          ],
        ),
      ),
    );
  }
}
