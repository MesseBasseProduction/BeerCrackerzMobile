import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

import '/src/map/map_service.dart';
import '/src/map/map_view.dart';
import '/src/map/marker/marker_data.dart';
import '/src/map/modal/modal_helper.dart';
import '/src/utils/size_config.dart';

class EditMarkerView extends StatefulWidget {
  const EditMarkerView({
    super.key,
    required this.mapView,
    required this.markerData,
  });

  final MapView mapView;
  final MarkerData markerData;

  @override
  EditMarkerViewState createState() {
    return EditMarkerViewState();
  }
}

class EditMarkerViewState extends State<EditMarkerView> {
  // Must be defined in here instead of inside build
  final _formKey = GlobalKey<FormState>();
  // Generic build method for each marker type
  @override
  Widget build(
    BuildContext context,
  ) {
    SizeConfig().init(context);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    // Bottom sheet modal content to be injected
    return Container(
      height: (SizeConfig.modalHeightRatio * mediaQueryData.size.height) / 100,
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
            // Modal edit mark title
            Text(
              (widget.markerData.type == 'spot')
              ? AppLocalizations.of(context)!.editSpotTitle
              : (widget.markerData.type == 'shop')
                ? AppLocalizations.of(context)!.editShopTitle
                : AppLocalizations.of(context)!.editBarTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: SizeConfig.fontTextTitleSize,
              ),
            ),
            // No SizedBox has its handled in ModalHelper
            // BottomModal content built depending on switch value
            SingleChildScrollView(
              child: (widget.markerData.type == 'spot')
                ? buildEditSpotModal()
                : (widget.markerData.type == 'shop')
                  ? buildEditShopModal()
                  : buildEditBarModal(),
            ),
          ],
        ),
      ),
    );
  }
  // Edit spot modal validation
  Widget buildEditSpotModal() {
    // Specific form validation
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
        MapService.patchSpot(
          await widget.mapView.settingsController.getAuthToken(),
          widget.markerData,
        ).then((response) async {
          if (response.statusCode == 200) {
            Navigator.pop(context);
          } else {
            // Invalid/incomplete data sent
            // Error ESP1
            toastification.show(
              context: context,
              title: Text(
                AppLocalizations.of(context)!.editMarkErrorToastTitle,
              ),
              description: Text(
                AppLocalizations.of(context)!.editMarkErrorToastDescription('ESP1'),
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
          // Error ESP2
          toastification.show(
            context: context,
            title: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastTitle,
            ),
            description: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastDescription('ESP2'),
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
    // Build modal content from generic helper
    return ModalHelper.markerEditor(
      context,
      _formKey,
      widget.markerData,
      formValidation,
    );
  }
  // Edit shop modal validation
  Widget buildEditShopModal() {
    // Specific form validation
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
        MapService.patchShop(
          await widget.mapView.settingsController.getAuthToken(),
          widget.markerData,
        ).then((response) async {
          if (response.statusCode == 200) {
            Navigator.pop(context);
          } else {
            // Invalid/incomplete data sent
            // Error ESH1
            toastification.show(
              context: context,
              title: Text(
                AppLocalizations.of(context)!.editMarkErrorToastTitle,
              ),
              description: Text(
                AppLocalizations.of(context)!.editMarkErrorToastDescription('ESH1'),
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
          // Error ESH2
          toastification.show(
            context: context,
            title: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastTitle,
            ),
            description: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastDescription('ESH2'),
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
    // Build modal content from generic helper
    return ModalHelper.markerEditor(
      context,
      _formKey,
      widget.markerData,
      formValidation,
    );
  }
  // Edit bar modal validation
  Widget buildEditBarModal() {
    // Specific form validation
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
        MapService.patchBar(
          await widget.mapView.settingsController.getAuthToken(),
          widget.markerData,
        ).then((response) async {
          if (response.statusCode == 200) {
            Navigator.pop(context);
          } else {
            // Invalid/incomplete data sent
            // Error EBA1
            toastification.show(
              context: context,
              title: Text(
                AppLocalizations.of(context)!.editMarkErrorToastTitle,
              ),
              description: Text(
                AppLocalizations.of(context)!.editMarkErrorToastDescription('EBA1'),
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
          // Error EBA2
          toastification.show(
            context: context,
            title: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastTitle,
            ),
            description: Text(
              AppLocalizations.of(context)!.httpFrontErrorToastDescription('EBA2'),
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
    // Build modal content from generic helper
    return ModalHelper.markerEditor(
      context,
      _formKey,
      widget.markerData,
      formValidation,
    );
  }
}
