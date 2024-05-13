import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '/src/map/map_service.dart';
import '/src/map/map_view.dart';
import '/src/map/marker/marker_data.dart';
import '/src/map/marker/marker_enums.dart';
import '/src/map/marker/marker_view.dart';
import '/src/utils/size_config.dart';

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
    SizeConfig().init(context);

    String? nameErrorMsg;
    String? descErrorMsg;

    void formValidation(StateSetter setModalState) async {
      setModalState(() {
        nameErrorMsg = null;
        descErrorMsg = null;
      });
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

    return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
      return Form(
        key: formKey,
        child: Container(
          padding: EdgeInsets.only(
            top: (SizeConfig.defaultSize * 2),
            bottom: (SizeConfig.defaultSize * 2),
            left: (SizeConfig.defaultSize * 2),
            right: (SizeConfig.defaultSize * 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.newSpotInformation,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // POI name
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newSpotNameInput,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  filled: true,
                  prefixIcon: Icon(
                    Icons.label,
                    size: (SizeConfig.defaultSize * 2),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorText: nameErrorMsg,
                ),
                inputFormatters: [
                  // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                  LengthLimitingTextInputFormatter(50),
                ],
                onSaved: (String? value) => data.name = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.newSpotNameInputEmpty);
                  }
                  return null;
                },
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newSpotTypesTitle,
                textAlign: TextAlign.center,
              ),
              // POI types
              Wrap(
                alignment: WrapAlignment.center,
                children: MarkerView.buildListElements(context, type, SpotTypes.values.map((e) => e.name).toList(), false, data.types, setModalState),
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // POI description
              TextFormField(
                minLines: 3,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newSpotDescriptionInput,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  filled: true,
                  prefixIcon: Icon(
                    Icons.edit,
                    size: (SizeConfig.defaultSize * 2),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorText: descErrorMsg,
                ),
                inputFormatters: [
                  // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                  LengthLimitingTextInputFormatter(500),
                ],
                onSaved: (String? value) => data.description = value!,
                // No validator as this fiel is optionnal
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newSpotModifiersTitle,
                textAlign: TextAlign.center,
              ),
              // POI Modifiers
              Wrap(
                alignment: WrapAlignment.center,
                children: MarkerView.buildListElements(context, type, SpotModifiers.values.map((e) => e.name).toList(), false, data.modifiers, setModalState),
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newSpotRatingTitle,
                textAlign: TextAlign.center,
              ),
              RatingBar.builder(
                initialRating: data.rate,
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: SizeConfig.iconSize,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  data.rate = rating;
                },
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // Submit new spot
              ButtonTheme(
                height: (SizeConfig.defaultSize * 5),
                minWidth: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () => formValidation(setModalState),
                  child: Text(AppLocalizations.of(context)!.newSpotSubmit),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static Widget buildNewShopModal(
    BuildContext context,
    MapView mapView,
    String type,
    GlobalKey<FormState> formKey,
    MarkerData data,
    Function callback
  ) {
    SizeConfig().init(context);

    String? nameErrorMsg;
    String? descErrorMsg;

    void formValidation(StateSetter setModalState) async {
      setModalState(() {
        nameErrorMsg = null;
        descErrorMsg = null;
      });
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

    return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
      return Form(
        key: formKey,
        child: Container(
          padding: EdgeInsets.only(
            top: (SizeConfig.defaultSize * 2),
            bottom: (SizeConfig.defaultSize * 2),
            left: (SizeConfig.defaultSize * 2),
            right: (SizeConfig.defaultSize * 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.newShopInformation,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // POI name
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newShopNameInput,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  filled: true,
                  prefixIcon: Icon(
                    Icons.label,
                    size: (SizeConfig.defaultSize * 2),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorText: nameErrorMsg,
                ),
                inputFormatters: [
                  // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                  LengthLimitingTextInputFormatter(50),
                ],
                onSaved: (String? value) => data.name = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.newShopNameInputEmpty);
                  }
                  return null;
                },
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newShopTypesTitle,
                textAlign: TextAlign.center,
              ),
              // POI types
              Wrap(
                alignment: WrapAlignment.center,
                // We must replace $ char from Shop enum
                children: MarkerView.buildListElements(context, type, ShopTypes.values.map((e) => e.name).toList(), false, data.types, setModalState),
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // POI description
              TextFormField(
                minLines: 3,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newShopDescriptionInput,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  filled: true,
                  prefixIcon: Icon(
                    Icons.edit,
                    size: (SizeConfig.defaultSize * 2),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorText: descErrorMsg,
                ),
                inputFormatters: [
                  // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                  LengthLimitingTextInputFormatter(500),
                ],
                onSaved: (String? value) => data.description = value!,
                // No validator as this fiel is optionnal
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newShopModifiersTitle,
                textAlign: TextAlign.center,
              ),
              // POI Modifiers
              Wrap(
                alignment: WrapAlignment.center,
                children: MarkerView.buildListElements(context, type, ShopModifiers.values.map((e) => e.name).toList(), false, data.modifiers, setModalState),
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.newShopRatingTitle,
                        textAlign: TextAlign.center,
                      ),
                      RatingBar.builder(
                        initialRating: data.rate,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemSize: SizeConfig.iconSize,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          data.rate = rating;
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.newShopPriceTitle,
                        textAlign: TextAlign.center,
                      ),
                      RatingBar.builder(
                        initialRating: data.price!.toDouble() + 1,
                        direction: Axis.horizontal,
                        itemCount: 3,
                        itemSize: SizeConfig.iconSize,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),
                        onRatingUpdate: (rating) {
                          data.price = rating.toInt();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // Submit new spot
              ButtonTheme(
                height: (SizeConfig.defaultSize * 5),
                minWidth: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () => formValidation(setModalState),
                  child: Text(AppLocalizations.of(context)!.newShopSubmit),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static Widget buildNewBarModal(
    BuildContext context,
    MapView mapView,
    String type,
    GlobalKey<FormState> formKey,
    MarkerData data,
    Function callback
  ) {
    SizeConfig().init(context);

    String? nameErrorMsg;
    String? descErrorMsg;

    void formValidation(StateSetter setModalState) async {
      setModalState(() {
        nameErrorMsg = null;
        descErrorMsg = null;
      });
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

    return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
      return Form(
        key: formKey,
        child: Container(
          padding: EdgeInsets.only(
            top: (SizeConfig.defaultSize * 2),
            bottom: (SizeConfig.defaultSize * 2),
            left: (SizeConfig.defaultSize * 2),
            right: (SizeConfig.defaultSize * 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.newBarInformation,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // POI name
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newBarNameInput,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  filled: true,
                  prefixIcon: Icon(
                    Icons.label,
                    size: (SizeConfig.defaultSize * 2),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorText: nameErrorMsg,
                ),
                inputFormatters: [
                  // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                  LengthLimitingTextInputFormatter(50),
                ],
                onSaved: (String? value) => data.name = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.newBarNameInputEmpty);
                  }
                  return null;
                },
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newBarTypesTitle,
                textAlign: TextAlign.center,
              ),
              // POI types
              Wrap(
                alignment: WrapAlignment.center,
                // We must replace $ char from Shop enum
                children: MarkerView.buildListElements(context, type, BarTypes.values.map((e) => e.name).toList(), false, data.types, setModalState),
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // POI description
              TextFormField(
                minLines: 3,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newBarDescriptionInput,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  filled: true,
                  prefixIcon: Icon(
                    Icons.edit,
                    size: (SizeConfig.defaultSize * 2),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.borderRadius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorText: descErrorMsg,
                ),
                inputFormatters: [
                  // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                  LengthLimitingTextInputFormatter(500),
                ],
                onSaved: (String? value) => data.description = value!,
                // No validator as this fiel is optionnal
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newBarModifiersTitle,
                textAlign: TextAlign.center,
              ),
              // POI Modifiers
              Wrap(
                alignment: WrapAlignment.center,
                children: MarkerView.buildListElements(context, type, BarModifiers.values.map((e) => e.name).toList(), false, data.modifiers, setModalState),
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.newBarRatingTitle,
                        textAlign: TextAlign.center,
                      ),
                      RatingBar.builder(
                        initialRating: data.rate,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemSize: SizeConfig.iconSize,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          data.rate = rating;
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.newBarPriceTitle,
                        textAlign: TextAlign.center,
                      ),
                      RatingBar.builder(
                        initialRating: data.price!.toDouble(),
                        direction: Axis.horizontal,
                        itemCount: 3,
                        itemSize: SizeConfig.iconSize,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),
                        onRatingUpdate: (rating) {
                          data.price = rating.toInt();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              // Submit new spot
              ButtonTheme(
                height: (SizeConfig.defaultSize * 5),
                minWidth: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () => formValidation(setModalState),
                  child: Text(AppLocalizations.of(context)!.newBarSubmit),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
