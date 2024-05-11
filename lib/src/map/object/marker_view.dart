import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:loader_overlay/loader_overlay.dart';

import 'package:beercrackerz/src/map/map_view.dart';
import 'package:beercrackerz/src/map/map_service.dart';
import 'package:beercrackerz/src/map/object/marker_data.dart';
import 'package:beercrackerz/src/settings/size_config.dart';

class MarkerView {
  static Marker buildSpotMarkerView(
    MarkerData data,
    BuildContext context,
    MapView mapView,
    MapController mapController,
    Function animatedMapMove,
    int userId,
    Function removeCallback,
    Function editCallback
  ) {
    return Marker(
      height: 30.0,
      width: 30.0,
      point: LatLng(data.lat, data.lng),
      child: GestureDetector(
        onTap: () {
          onMarkerTapped(data, context, mapView, mapController, animatedMapMove, userId, removeCallback, editCallback);
        },
        child: const Image(
          image: AssetImage('assets/images/marker/marker-icon-green.png')
        ),
      ),
    );
  }

  static Marker buildShopMarkerView(
    MarkerData data,
    BuildContext context,
    MapView mapView,
    MapController mapController,
    Function animatedMapMove,
    int userId,
    Function removeCallback,
    Function editCallback
  ) {
    return Marker(
      height: 30.0,
      width: 30.0,
      point: LatLng(data.lat, data.lng),
      child: GestureDetector(
        onTap: () {
          onMarkerTapped(data, context, mapView, mapController, animatedMapMove, userId, removeCallback, editCallback);
        },
        child: const Image(
          image: AssetImage('assets/images/marker/marker-icon-blue.png')
        ),
      ),
    );
  }

  static Marker buildBarMarkerView(
    MarkerData data,
    BuildContext context,
    MapView mapView,
    MapController mapController,
    Function animatedMapMove,
    int userId,
    Function removeCallback,
    Function editCallback
  ) {
    return Marker(
      height: 30.0,
      width: 30.0,
      point: LatLng(data.lat, data.lng),
      child: GestureDetector(
        onTap: () {
          onMarkerTapped(data, context, mapView, mapController, animatedMapMove, userId, removeCallback, editCallback);
        },
        child: const Image(
          image: AssetImage('assets/images/marker/marker-icon-red.png')
        ),
      ),
    );
  }

  static Marker buildWIPMarkerView(
    LatLng latLng,
    BuildContext context,
    MapController mapController
  ) {
    return Marker(
      height: 30.0,
      width: 30.0,
      point: latLng,
      child: GestureDetector(
        child: const Image(
          image: AssetImage('assets/images/marker/marker-icon-black.png')
        ),
      ),
    );
  }

  static void onMarkerTapped(
    MarkerData data,
    BuildContext context,
    MapView mapView,
    MapController mapController,
    Function animatedMapMove,
    int userId,
    Function removeCallback,
    Function editCallback
  ) {
    // Internal method to build types/modifiers "button"-like elements
    List<Widget> buildListElements(types) {
      List<Widget> output = [];
      for (var element in types) {
        Container typeElem = Container(
          margin: const EdgeInsets.all(4.0),
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: SizedBox(
            height: 18,
            child: RichText(
              text: TextSpan(
                children: [
                  const WidgetSpan(
                    child: SizedBox(width: 4.0),
                  ),
                  WidgetSpan(
                    child: SvgPicture.asset(
                      'assets/images/icon/$element.svg',
                      width: 14.0,
                      height: 14.0,
                    ),
                  ),
                  const WidgetSpan(
                    child: SizedBox(width: 4.0),
                  ),
                  TextSpan(
                    text: (data.type == 'spot')
                      ? AppLocalizations.of(context)!.spotFeatures(element)
                      : ((data.type == 'shop')
                        ? AppLocalizations.of(context)!.shopFeatures(element)
                        : AppLocalizations.of(context)!.barFeatures(element)),
                  ),
                  const WidgetSpan(
                    child: SizedBox(width: 4.0),
                  ),
                ],
              ),
            ),
          ),
        );
        output.add(typeElem);
      }
      return output;
    }

    bool noAnimation = false;

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    int screenHeightRatio = 66;
    double mapLatRange = (screenHeightRatio * (mapController.camera.visibleBounds.northWest.latitude - mapController.camera.visibleBounds.southEast.latitude).abs()) / 400;
    // Move map to the marker position
    animatedMapMove(LatLng(data.lat - (mapLatRange / 2), data.lng), mapController.camera.zoom + 2);
    // Display POI informations in scrollable modal bottom sheet
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (BuildContext context) {
        return Container(
          height: (screenHeightRatio * mediaQueryData.size.height) / 100, // Taking screenHeightRatio % of screen height
          color: Theme.of(context).colorScheme.background,
          child: Center(
            child: ListView(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  Text(
                    data.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Un spot découvert par ',
                              style: TextStyle(
                                  fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                            TextSpan(
                                text: data.user,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Depuis le ',
                              style: TextStyle(
                                  fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                            TextSpan(
                                text: data.creationDate,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  RatingBarIndicator(
                    rating: data.rate + 1,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemSize: 14,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: buildListElements(data.types)
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Center(
                      child: Text(
                        data.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: buildListElements(data.modifiers)
                  ),
                  // Check if currentMak is created by user, allow him to delete/edit
                  (userId == data.userId)
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                          ),
                          iconSize: 24,
                          onPressed: () {
                            noAnimation = true; // Forbid animation when bottom sheet switch to edit
                            Navigator.of(context).pop(false);
                            editCallback(data);
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                          ),
                          iconSize: 24,
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(AppLocalizations.of(context)!.deleteMarkDialogTitle),
                                    content: Text(AppLocalizations.of(context)!.deleteMarkDialogDescription),
                                    actions: [
                                      ElevatedButton(
                                        child: Text(AppLocalizations.of(context)!.deleteMarkDialogNo),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      ElevatedButton(
                                        child: Text(AppLocalizations.of(context)!.deleteMarkDialogYes),
                                        onPressed: () async {
                                          if (data.type == 'spot') {
                                            MapService.deleteSpot(await mapView.controller.getAuthToken(), data.id);
                                          } else if (data.type == 'shop') {
                                            MapService.deleteShop(await mapView.controller.getAuthToken(), data.id);
                                          } else if (data.type == 'bar') {
                                            MapService.deleteBar(await mapView.controller.getAuthToken(), data.id);
                                          }
                                          // Now remove from view to end process
                                          removeCallback(data);
                                          if (context.mounted) {
                                            Navigator.of(context).pop(false);
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                          },
                        ),
                      ],
                    )
                    : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                ],
              )
            ]),
          ),
        );
      },
    ).whenComplete(() {
      // Move back camera only if allowed
      if (noAnimation == false) {
        animatedMapMove(LatLng(data.lat, data.lng), mapController.camera.zoom - 2);
      }
    });
  }

  // For POI types and modifiers
  static List<Widget> buildListElements(
    BuildContext context,
    String poiType,
    List<String> poiElements,
    bool readOnly,
    List<String> selected,
    StateSetter setModalState
  ) {
    List<Widget> output = [];
    for (var element in poiElements) {
      element = element.replaceAll('_', '');
      Container typeElem = Container(
        margin: const EdgeInsets.all(4.0),
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected.contains(element) 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: SizedBox(
          height: 18,
          child: RichText(
            text: TextSpan(
              children: [
                const WidgetSpan(
                  child: SizedBox(width: 4.0),
                ),
                WidgetSpan(
                  child: SvgPicture.asset(
                    'assets/images/icon/$element.svg',
                    width: 14.0,
                    height: 14.0,
                    colorFilter: selected.contains(element) 
                      ? ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn)
                      : ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
                  ),
                ),
                const WidgetSpan(
                  child: SizedBox(width: 4.0),
                ),
                TextSpan(
                  text: (poiType == 'spot')
                    ? AppLocalizations.of(context)!.spotFeatures(element)
                    : ((poiType == 'shop')
                      ? AppLocalizations.of(context)!.shopFeatures(element)
                      : AppLocalizations.of(context)!.barFeatures(element)),
                  style: TextStyle(
                    color: selected.contains(element) 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const WidgetSpan(
                  child: SizedBox(width: 4.0),
                ),
              ],
            ),
          ),
        ),
      );
      if (readOnly == true) {
        output.add(typeElem);
      } else {
        output.add(
          InkWell(
            child: typeElem,
            onTap: () {
              if (selected.contains(element)) {
                selected.remove(element);
              } else {
                selected.add(element);
              }
              setModalState(() {});
            },
          ),
        );
      }
    }

    return output;
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
        MapService.postNewSpot(await mapView.controller.getAuthToken(), data).then((response) async {
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
                itemSize: 24,
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
        MapService.postNewShop(await mapView.controller.getAuthToken(), data).then((response) async {
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
                        itemSize: 24,
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
                        itemSize: 24,
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
        MapService.postNewBar(await mapView.controller.getAuthToken(), data).then((response) async {
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
                        itemSize: 24,
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
                        itemSize: 24,
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

  static Widget buildEditSpotModal(
    BuildContext context,
    MapView mapView,
    GlobalKey<FormState> formKey,
    MarkerData data
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
        MapService.patchEditSpot(await mapView.controller.getAuthToken(), data).then((response) async {
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
                initialValue: data.name,
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
                children: MarkerView.buildListElements(context, data.type, SpotTypes.values.map((e) => e.name).toList(), false, data.types, setModalState),
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
                initialValue: data.description,
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
                children: MarkerView.buildListElements(context, data.type, SpotModifiers.values.map((e) => e.name).toList(), false, data.modifiers, setModalState),
              ),
              SizedBox(
                height: (SizeConfig.defaultSize * 2),
              ),
              Text(
                AppLocalizations.of(context)!.newSpotRatingTitle,
                textAlign: TextAlign.center,
              ),
              RatingBar.builder(
                initialRating: data.rate + 1,
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: 24,
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

  static Widget buildEditShopModal(
    BuildContext context,
    MapView mapView,
    GlobalKey<FormState> formKey,
    MarkerData data
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
        MapService.patchEditShop(await mapView.controller.getAuthToken(), data).then((response) async {
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
                children: MarkerView.buildListElements(context, data.type, ShopTypes.values.map((e) => e.name).toList(), false, data.types, setModalState),
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
                children: MarkerView.buildListElements(context, data.type, ShopModifiers.values.map((e) => e.name).toList(), false, data.modifiers, setModalState),
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
                        itemSize: 24,
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
                        initialRating: data.price!.toDouble(),
                        direction: Axis.horizontal,
                        itemCount: 3,
                        itemSize: 24,
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

  static Widget buildEditBarModal(
    BuildContext context,
    MapView mapView,
    GlobalKey<FormState> formKey,
    MarkerData data
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
        MapService.patchEditBar(await mapView.controller.getAuthToken(), data).then((response) async {
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
                children: MarkerView.buildListElements(context, data.type, BarTypes.values.map((e) => e.name).toList(), false, data.types, setModalState),
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
                children: MarkerView.buildListElements(context, data.type, BarModifiers.values.map((e) => e.name).toList(), false, data.modifiers, setModalState),
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
                        itemSize: 24,
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
                        itemSize: 24,
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
