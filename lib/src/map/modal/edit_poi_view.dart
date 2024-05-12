import 'package:beercrackerz/src/map/marker/marker_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/src/map/map_view.dart';
import '/src/map/map_service.dart';

class EditPOIView extends StatefulWidget {
  const EditPOIView({
    super.key,
    required this.mapView,
    required this.data
  });

  final MapView mapView;
  final MarkerData data;

  @override
  EditPOIViewState createState() {
    return EditPOIViewState();
  }
}

class EditPOIViewState extends State<EditPOIView> {
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
                ? MapService.buildEditSpotModal(context, widget.mapView, _formKey, widget.data)
                : (widget.data.type == 'shop')
                  ? MapService.buildEditShopModal(context, widget.mapView, _formKey, widget.data)
                  : MapService.buildEditBarModal(context, widget.mapView, _formKey, widget.data),
            ),
          ],
        ),
      ),
    );
  }
}
