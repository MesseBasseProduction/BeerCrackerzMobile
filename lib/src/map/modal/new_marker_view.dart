import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '/src/map/map_service.dart';
import '/src/map/map_view.dart';
import '/src/map/marker/marker_data.dart';
import '/src/map/modal/modal_helper.dart';
import '/src/utils/size_config.dart';

class NewMarkerView extends StatefulWidget {
  const NewMarkerView({
    super.key,
    required this.mapView,
    required this.markerData,
    required this.callback,
  });

  final MapView mapView;
  final MarkerData markerData;
  final Function callback;

  @override
  NewMarkerViewState createState() => NewMarkerViewState();
}

class NewMarkerViewState extends State<NewMarkerView> {
  String markType = 'spot'; // Start modal with default to spot
  // Must be defined in here instead of MarkerView to avoid reset each build call
  final _formKey = GlobalKey<FormState>();
  // Generic build method for each marker type
  @override
  Widget build(
    BuildContext context,
  ) {
    SizeConfig().init(context);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    // In case of new mark we update each setState the WIP marker type
    widget.markerData.type = markType;

    return Container(
      height: (SizeConfig.modalHeightRatio * mediaQueryData.size.height) / 100, // Taking screenHeightRatio % of screen height
      width: mediaQueryData.size.width,
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.padding,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: SizeConfig.padding,
            ),
            // Modal new mark title
            Text(
              (markType == 'spot')
              ? AppLocalizations.of(context)!.newSpotTitle
              : (markType == 'shop')
                ? AppLocalizations.of(context)!.newShopTitle
                : AppLocalizations.of(context)!.newBarTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: SizeConfig.fontTextTitleSize,
              ),
            ),
            SizedBox(
              height: SizeConfig.paddingSmall,
            ),
            // New mark type switch
            ToggleSwitch(
              customWidths: [
                mediaQueryData.size.width / 4,
                mediaQueryData.size.width / 4,
                mediaQueryData.size.width / 4,
              ],
              initialLabelIndex: (markType == 'spot')
                ? 0
                : (markType == 'shop')
                  ? 1
                  : 2,
              totalSwitches: 3,
              labels: [
                AppLocalizations.of(context)!.newMarkSpotType,
                AppLocalizations.of(context)!.newMarkShopType,
                AppLocalizations.of(context)!.newMarkBarType,
              ],
              onToggle: (index) {
                if (index == 0) {
                  setState(() => markType = 'spot');
                } else if (index == 1) {
                  setState(() => markType = 'shop');
                } else {
                  setState(() => markType = 'bar');
                }
              },
            ),
            SizedBox(
              height: SizeConfig.paddingSmall,
            ),
            // BottomModal content built depending on switch value
            SingleChildScrollView(
              child: (markType == 'spot')
                ? buildNewSpotModal()
                : (markType == 'shop')
                  ? buildNewShopModal()
                  : buildNewBarModal(),
            ),
          ],
        ),
      ),
    );
  }
  // New spot modal validation
  Widget buildNewSpotModal() {
    void formValidation() async {
      _formKey.currentState!.save();
      // Dismiss keyboard by removing focus on current input if any
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      if (_formKey.currentState!.validate()) {
        // Start loading overlay during server call
        context.loaderOverlay.show();
        MapService.postSpot(
          await widget.mapView.settingsController.getAuthToken(),
          widget.markerData,
        ).then((response) async {
          if (response.statusCode == 201) {
            final parsedJson = jsonDecode(response.body);
            MarkerData newMark = MarkerData.fromJson(parsedJson);
            widget.callback(
              'spot',
              newMark,
            );
          } else {
            // Invalid/incomplete data sent
            // Error NSP1
            toastification.show(
              context: context,
              title: Text(
                AppLocalizations.of(context)!.editMarkErrorToastTitle,
              ),
              description: Text(
                AppLocalizations.of(context)!.editMarkErrorToastDescription('NSP1'),
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              autoCloseDuration: const Duration(
                seconds: 5,
              ),
              showProgressBar: false,
            );
          }
        }).catchError((handleError) {
          // Unable to perform server call
          // Error NSP2
          toastification.show(
            context: context,
            title: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastTitle,
            ),
            description: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastDescription('NSP2'),
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(
              seconds: 5,
            ),
            showProgressBar: false,
          );
        }).whenComplete(() {
          // Hide overlay loader anyway
          context.loaderOverlay.hide();
        });
      }
    }

    return ModalHelper.markerEditor(
      context,
      _formKey,
      widget.markerData,
      formValidation,
    );
  }
  // New shop modal validation
  Widget buildNewShopModal() {
    void formValidation() async {
      _formKey.currentState!.save();
      // Dismiss keyboard by removing focus on current input if any
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      if (_formKey.currentState!.validate()) {
        // Start loading overlay during server call
        context.loaderOverlay.show();
        MapService.postShop(
          await widget.mapView.settingsController.getAuthToken(),
          widget.markerData,
        ).then((response) async {
          if (response.statusCode == 201) {
            final parsedJson = jsonDecode(response.body);
            MarkerData newMark = MarkerData.fromJson(parsedJson);
            widget.callback(
              'shop',
              newMark,
            );
          } else {
            // Invalid/incomplete data sent
            // Error NSH1
            toastification.show(
              context: context,
              title: Text(
                AppLocalizations.of(context)!.editMarkErrorToastTitle,
              ),
              description: Text(
                AppLocalizations.of(context)!.editMarkErrorToastDescription('NSH1'),
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              autoCloseDuration: const Duration(
                seconds: 5,
              ),
              showProgressBar: false,
            );
          }
        }).catchError((handleError) {
          // Unable to perform server call
          // Error NSH2
          toastification.show(
            context: context,
            title: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastTitle,
            ),
            description: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastDescription('NSH2'),
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(
              seconds: 5,
            ),
            showProgressBar: false,
          );
        }).whenComplete(() {
          // Hide overlay loader anyway
          context.loaderOverlay.hide();
        });
      }
    }

    return ModalHelper.markerEditor(
      context,
      _formKey,
      widget.markerData,
      formValidation,
    );
  }
  // New bar modal validation
  Widget buildNewBarModal() {
    void formValidation() async {
      _formKey.currentState!.save();
      // Dismiss keyboard by removing focus on current input if any
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      if (_formKey.currentState!.validate()) {
        // Start loading overlay during server call
        context.loaderOverlay.show();
        MapService.postBar(
          await widget.mapView.settingsController.getAuthToken(),
          widget.markerData,
        ).then((response) async {
          if (response.statusCode == 201) {
            final parsedJson = jsonDecode(response.body);
            MarkerData newMark = MarkerData.fromJson(parsedJson);
            widget.callback(
              'bar',
              newMark,
            );
          } else {
            // Invalid/incomplete data sent
            // Error NBA1
            toastification.show(
              context: context,
              title: Text(
                AppLocalizations.of(context)!.editMarkErrorToastTitle,
              ),
              description: Text(
                AppLocalizations.of(context)!.editMarkErrorToastDescription('NBA1'),
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              autoCloseDuration: const Duration(
                seconds: 5,
              ),
              showProgressBar: false,
            );
          }
        }).catchError((handleError) {
          // Unable to perform server call
          // Error NSH2
          toastification.show(
            context: context,
            title: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastTitle,
            ),
            description: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastDescription('NSH2'),
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(
              seconds: 5,
            ),
            showProgressBar: false,
          );
        }).whenComplete(() {
          // Hide overlay loader anyway
          context.loaderOverlay.hide();
        });
      }
    }

    return ModalHelper.markerEditor(
      context,
      _formKey,
      widget.markerData,
      formValidation,
    );
  }
}
