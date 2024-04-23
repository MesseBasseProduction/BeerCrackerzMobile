import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:beercrackerz/src/map/object/marker_data.dart';
import 'package:beercrackerz/src/settings/size_config.dart';

class MarkerView {
  static Marker buildSpotMarkerView(MarkerData data, BuildContext context, MapController mapController, Function animatedMapMove) {
    return Marker(
      height: 30.0,
      width: 30.0,
      point: LatLng(data.lat, data.lng),
      child: GestureDetector(
        onTap: () {
          onMarkerTapped(data, context, mapController, animatedMapMove);
        },
        child: const Image(
          image: AssetImage('assets/images/marker/marker-icon-green.png')
        ),
      ),
    );
  }

  static Marker buildShopMarkerView(MarkerData data, BuildContext context, MapController mapController, Function animatedMapMove) {
    return Marker(
      height: 30.0,
      width: 30.0,
      point: LatLng(data.lat, data.lng),
      child: GestureDetector(
        onTap: () {
          onMarkerTapped(data, context, mapController, animatedMapMove);
        },
        child: const Image(
          image: AssetImage('assets/images/marker/marker-icon-blue.png')
        ),
      ),
    );
  }

  static Marker buildBarMarkerView(MarkerData data, BuildContext context, MapController mapController, Function animatedMapMove) {
    return Marker(
      height: 30.0,
      width: 30.0,
      point: LatLng(data.lat, data.lng),
      child: GestureDetector(
        onTap: () {
          onMarkerTapped(data, context, mapController, animatedMapMove);
        },
        child: const Image(
          image: AssetImage('assets/images/marker/marker-icon-red.png')
        ),
      ),
    );
  }

  static Marker buildWIPMarkerView(LatLng latLng, BuildContext context, MapController mapController) {
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

  static void onMarkerTapped(MarkerData data, BuildContext context, MapController mapController, Function animatedMapMove) {
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

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double mapLatRange = (35 * (mapController.camera.visibleBounds.northWest.latitude - mapController.camera.visibleBounds.southEast.latitude).abs()) / 400;
    // Move map to the marker position
    animatedMapMove(LatLng(data.lat - (mapLatRange / 2), data.lng), mapController.camera.zoom + 2);
    // Display POI informations in scrollable modal bottom sheet
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (BuildContext context) {
        return Container(
          height: (35 * mediaQueryData.size.height) / 100, // Taking 35% of screen height
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ],
              )
            ]),
          ),
        );
      },
    ).whenComplete(() {
      animatedMapMove(LatLng(data.lat, data.lng), mapController.camera.zoom - 2);
    });
  }

  // For POI types and modifiers
  static List<Widget> buildListElements(BuildContext context, String poiType, List<String> poiElements, bool readOnly, List<String> selected, StateSetter setModalState) {
    List<Widget> output = [];
    for (var element in poiElements) {
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

  static Widget buildNewSpotModal(BuildContext context, String type, GlobalKey<FormState> formKey, MarkerData data) {
    SizeConfig().init(context);

    String? nameErrorMsg;
    String? descErrorMsg;

    void formValidation(StateSetter setModalState) {
      setModalState(() {
        nameErrorMsg = null;
        descErrorMsg = null;
      });
      formKey.currentState!.save();
      if (formKey.currentState!.validate()) {
        print('valid input');
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
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
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
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
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
                itemSize: 14,
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

  static Widget buildNewShopModal(BuildContext context, String type, GlobalKey<FormState> formKey) {
    SizeConfig().init(context);

    return 
      Form(
        key: formKey,
        child: Container(
          padding: EdgeInsets.only(
            top: (SizeConfig.defaultSize * 2),
            bottom: (SizeConfig.defaultSize * 2),
            left: (SizeConfig.defaultSize * 2),
            right: (SizeConfig.defaultSize * 2),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.background,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.authLoginUsernameInput,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  filled: true,
                  prefixIcon: Icon(
                    Icons.account_circle,
                    size: (SizeConfig.defaultSize * 2),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorText: 'TMP',
                ),
                inputFormatters: [
                  // See https://github.com/MesseBasseProduction/BeerCrackerz backend for this char limitation
                  //LengthLimitingTextInputFormatter(100),
                ],
                onSaved: (String? value) => {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.emptyInput(AppLocalizations.of(context)!.authLoginUsername);
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      );
  }
}
