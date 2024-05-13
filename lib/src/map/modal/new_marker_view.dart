import 'dart:convert';

import 'package:beercrackerz/src/map/modal/modal_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '/src/map/map_service.dart';
import '/src/map/map_view.dart';
import '/src/map/marker/marker_data.dart';

class NewMarkerView extends StatefulWidget {
  const NewMarkerView({
    super.key,
    required this.mapView,
    required this.data,
    required this.callback
  });

  final MapView mapView;
  final MarkerData data;
  final Function callback;

  @override
  NewMarkerViewState createState() {
    return NewMarkerViewState();
  }
}

class NewMarkerViewState extends State<NewMarkerView> {
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
                ? buildNewSpotModal(context, widget.mapView, poiType, _formKey, widget.data, widget.callback)
                : (poiType == 'shop')
                  ? buildNewShopModal(context, widget.mapView, poiType, _formKey, widget.data, widget.callback)
                  : buildNewBarModal(context, widget.mapView, poiType, _formKey, widget.data, widget.callback),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildNewSpotModal(
    BuildContext context,
    MapView mapView,
    String type,
    GlobalKey<FormState> formKey,
    MarkerData data,
    Function callback
  ) {
    void formValidation() async {
      formKey.currentState!.save();
      if (formKey.currentState!.validate()) {
        // Start loading overlay during server call
        context.loaderOverlay.show();
        MapService.postSpot(await mapView.controller.getAuthToken(), data).then((response) async {
          if (response.statusCode == 201) {
            final parsedJson = jsonDecode(response.body);
            MarkerData newMark = MarkerData.fromJson(parsedJson);
            callback('spot', newMark);
          }
        }).catchError((handleError) {
          print(handleError);
        }).whenComplete(() {
          // Hide overlay loader anyway
          context.loaderOverlay.hide();
        });
      }
    }

    return ModalHelper.markerEditor(
      context,
      formKey,
      data,
      formValidation,
    );
  }

  static Widget buildNewShopModal(
    BuildContext context,
    MapView mapView,
    String type,
    GlobalKey<FormState> formKey,
    MarkerData data,
    Function callback
  ) {
    void formValidation() async {
      formKey.currentState!.save();
      if (formKey.currentState!.validate()) {
        // Start loading overlay during server call
        context.loaderOverlay.show();
        MapService.postShop(await mapView.controller.getAuthToken(), data).then((response) async {
          if (response.statusCode == 201) {
            final parsedJson = jsonDecode(response.body);
            MarkerData newMark = MarkerData.fromJson(parsedJson);
            callback('shop', newMark);
          }
        }).catchError((handleError) {
          print(handleError);
        }).whenComplete(() {
          // Hide overlay loader anyway
          context.loaderOverlay.hide();
        });
      }
    }

    return ModalHelper.markerEditor(
      context,
      formKey,
      data,
      formValidation,
    );
  }

  static Widget buildNewBarModal(
    BuildContext context,
    MapView mapView,
    String type,
    GlobalKey<FormState> formKey,
    MarkerData data,
    Function callback
  ) {
    void formValidation() async {
      formKey.currentState!.save();
      if (formKey.currentState!.validate()) {
        // Start loading overlay during server call
        context.loaderOverlay.show();
        MapService.postBar(await mapView.controller.getAuthToken(), data).then((response) async {
          if (response.statusCode == 201) {
            final parsedJson = jsonDecode(response.body);
            MarkerData newMark = MarkerData.fromJson(parsedJson);
            callback('bar', newMark);
          }
        }).catchError((handleError) {
          print(handleError);
        }).whenComplete(() {
          // Hide overlay loader anyway
          context.loaderOverlay.hide();
        });
      }
    }

    return ModalHelper.markerEditor(
      context,
      formKey,
      data,
      formValidation,
    );
  }
}
