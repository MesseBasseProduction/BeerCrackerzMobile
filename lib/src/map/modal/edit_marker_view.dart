import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '/src/map/map_service.dart';
import '/src/map/map_view.dart';
import '/src/map/marker/marker_data.dart';
import '/src/map/modal/modal_helper.dart';
import '/src/utils/size_config.dart';

class EditMarkerView extends StatefulWidget {
  const EditMarkerView({
    super.key,
    required this.mapView,
    required this.data
  });

  final MapView mapView;
  final MarkerData data;

  @override
  EditMarkerViewState createState() {
    return EditMarkerViewState();
  }
}

class EditMarkerViewState extends State<EditMarkerView> {
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
              (widget.data.type == 'spot')
              ? AppLocalizations.of(context)!.editSpotTitle
              : (widget.data.type == 'shop')
                ? AppLocalizations.of(context)!.editShopTitle
                : AppLocalizations.of(context)!.editBarTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
            ),
            // BottomModal content built depending on switch value
            SingleChildScrollView(
              child: (widget.data.type == 'spot')
                ? buildEditSpotModal(context, widget.mapView, _formKey, widget.data)
                : (widget.data.type == 'shop')
                  ? buildEditShopModal(context, widget.mapView, _formKey, widget.data)
                  : buildEditBarModal(context, widget.mapView, _formKey, widget.data),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildEditSpotModal(
    BuildContext context,
    MapView mapView,
    GlobalKey<FormState> formKey,
    MarkerData data
  ) {
    SizeConfig().init(context);

    void formValidation() async {
      formKey.currentState!.save();
      if (formKey.currentState!.validate()) {
        // Start loading overlay during server call
        context.loaderOverlay.show();
        MapService.patchSpot(await mapView.controller.getAuthToken(), data).then((response) async {
          if (response.statusCode == 200) {
            Navigator.pop(context);
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

  static Widget buildEditShopModal(
    BuildContext context,
    MapView mapView,
    GlobalKey<FormState> formKey,
    MarkerData data
  ) {
    void formValidation() async {
      formKey.currentState!.save();
      if (formKey.currentState!.validate()) {
        // Start loading overlay during server call
        context.loaderOverlay.show();
        MapService.patchShop(await mapView.controller.getAuthToken(), data).then((response) async {
          if (response.statusCode == 200) {
            Navigator.pop(context);
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

  static Widget buildEditBarModal(
    BuildContext context,
    MapView mapView,
    GlobalKey<FormState> formKey,
    MarkerData data
  ) {
    void formValidation() async {
      formKey.currentState!.save();
      if (formKey.currentState!.validate()) {
        // Start loading overlay during server call
        context.loaderOverlay.show();
        MapService.patchBar(await mapView.controller.getAuthToken(), data).then((response) async {
          if (response.statusCode == 200) {
            Navigator.pop(context);
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
