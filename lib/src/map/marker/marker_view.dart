import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

import '/src/map/map_service.dart';
import '/src/map/map_view.dart';
import '/src/map/marker/marker_data.dart';
import '/src/map/utils/map_utils.dart';
import '/src/utils/size_config.dart';
// MarkerView clas shandle the whole content for the flutter_map ;
// the pin on map, and the modal sheet that opens when marker is clicked. 
class MarkerView {
  // Generic marker creator, used for Shops, Spots and bars
  static Marker buildMarkerView(
    BuildContext context,
    MapController mapController,
    MapView mapView,
    MarkerData markerData,
    TickerProvider tickerProvider,
    Function removeCallback,
    Function editCallback,
  ) {
    String iconPath = '';
    switch (markerData.type) {
      case 'spot':
        iconPath = 'assets/images/marker/marker-icon-green.png';
        break;
      case 'shop':
        iconPath = 'assets/images/marker/marker-icon-blue.png';
        break;
      case 'bar':
        iconPath = 'assets/images/marker/marker-icon-red.png';
        break;
    }
    return Marker(
      height: 30.0,
      width: 30.0,
      point: LatLng(
        markerData.lat,
        markerData.lng,
      ),
      child: GestureDetector(
        onTap: () => onMarkerTapped(
          context,
          mapController,
          mapView,
          markerData,
          tickerProvider,
          removeCallback,
          editCallback,
        ),
        child: Image(
          image: AssetImage(
            iconPath,
          ),
        ),
      ),
    );
  }
  // Marker callback when clicked to display its information
  static void onMarkerTapped(
    BuildContext context,
    MapController mapController,
    MapView mapView,
    MarkerData markerData,
    TickerProvider tickerProvider,
    Function removeCallback,
    Function editCallback,
  ) {
    SizeConfig().init(context);
    // Internal bool to lock animation if user tried to edit its mark
    bool noAnimation = false;
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    int screenHeightRatio = 66;
    double mapLatRange = (screenHeightRatio * (mapController.camera.visibleBounds.northWest.latitude - mapController.camera.visibleBounds.southEast.latitude).abs()) / 400;
    // Move map to the marker position
    MapUtils.animatedMapMove(
      LatLng(markerData.lat - (mapLatRange / 2), markerData.lng),
      mapController.camera.zoom + 2,
      mapController,
      tickerProvider,
    );
    // Display POI informations in scrollable modal bottom sheet
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (
        BuildContext context,
      ) {
        return Container(
          height: (screenHeightRatio * mediaQueryData.size.height) / 100, // Taking screenHeightRatio % of screen height
          color: Theme.of(context).colorScheme.background,
          padding: EdgeInsets.only(
            bottom: (SizeConfig.defaultSize * 2),
            left: (SizeConfig.defaultSize * 2),
            right: (SizeConfig.defaultSize * 2),
            top: (SizeConfig.defaultSize * 2),
          ),
          child: Center(
            child: ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Mark name
                    Text(
                      markerData.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.fontTextTitleSize,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.defaultSize,
                    ),
                    // User that discovered the mark
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: (markerData.type == 'spot')
                                ? AppLocalizations.of(context)!.spotDiscoveredBy
                                : (markerData.type == 'shop')
                                  ? AppLocalizations.of(context)!.shopDiscoveredBy
                                  : AppLocalizations.of(context)!.barDiscoveredBy,
                              style: TextStyle(
                                fontSize: SizeConfig.fontTextSmallSize,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextSpan(
                              text: ' ${markerData.user}',
                              style: TextStyle(
                                fontSize: SizeConfig.fontTextSmallSize,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Mark creation date
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: AppLocalizations.of(context)!.markDiscoveredSince,
                              style: TextStyle(
                                fontSize: SizeConfig.fontTextSmallSize,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextSpan(
                                text: ' ${markerData.creationDate}',
                                style: TextStyle(
                                  fontSize: SizeConfig.fontTextSmallSize,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.defaultSize,
                    ),
                    // Mark rating
                    RatingBarIndicator(
                      rating: markerData.rate + 1,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemSize: SizeConfig.iconSize,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                    // Mark price if type is shop or bar
                    (markerData.type != 'spot')
                      ? RatingBarIndicator(
                        rating: markerData.price! + 1,
                        direction: Axis.horizontal,
                        itemCount: 3,
                        itemSize: SizeConfig.iconSize,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),
                      )
                    : const SizedBox.shrink(),
                    SizedBox(
                      height: (SizeConfig.defaultSize * 2),
                    ),
                    // Mark types
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: MarkerView.buildListElements(context, markerData.type, markerData.types, false, [], (fn) => {}),
                    ),
                    SizedBox(
                      height: (SizeConfig.defaultSize * 2),
                    ),
                    // Mark description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Center(
                        child: Text(
                          markerData.description,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: (SizeConfig.defaultSize * 2),
                    ),
                    // Mark modifiers
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: MarkerView.buildListElements(context, markerData.type, markerData.modifiers, false, [], (fn) => {}),
                    ),
                    SizedBox(
                      height: (SizeConfig.defaultSize * 2),
                    ),
                    // Check if currentMark is created by user, allow him to delete/edit if so
                    (mapView.controller.userId == markerData.userId)
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Edit mark button
                          ElevatedButton(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit,
                                ),
                                SizedBox(
                                  width: SizeConfig.defaultSize,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.markEdit,
                                ),
                              ],
                            ),
                            onPressed: () {
                              // Forbid animation when bottom sheet switch to edit
                              noAnimation = true;
                              Navigator.of(context).pop(false);
                              editCallback(markerData);
                            },
                          ),
                          SizedBox(
                            width: (SizeConfig.defaultSize * 2),
                          ),
                          // Delete mark button
                          ElevatedButton(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete,
                                ),
                                SizedBox(
                                  width: SizeConfig.defaultSize,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.markDelete,
                                ),
                              ],
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      AppLocalizations.of(context)!.deleteMarkDialogTitle,
                                    ),
                                    content: Text(
                                      AppLocalizations.of(context)!.deleteMarkDialogDescription,
                                    ),
                                    actions: [
                                      ElevatedButton(
                                        child: Text(
                                          AppLocalizations.of(context)!.deleteMarkDialogNo,
                                        ),
                                        onPressed: () => Navigator.of(context).pop(false),
                                      ),
                                      ElevatedButton(
                                        child: Text(AppLocalizations.of(context)!.deleteMarkDialogYes),
                                        onPressed: () async {
                                          if (markerData.type == 'spot') {
                                            MapService.deleteSpot(await mapView.controller.getAuthToken(), markerData.id);
                                          } else if (markerData.type == 'shop') {
                                            MapService.deleteShop(await mapView.controller.getAuthToken(), markerData.id);
                                          } else if (markerData.type == 'bar') {
                                            MapService.deleteBar(await mapView.controller.getAuthToken(), markerData.id);
                                          }
                                          // Now remove from view to end process
                                          removeCallback(markerData);
                                          if (context.mounted) Navigator.of(context).pop(false);
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
                      : const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      // Move back camera only if allowed
      if (noAnimation == false) {
        MapUtils.animatedMapMove(
          LatLng(markerData.lat, markerData.lng),
          mapController.camera.zoom - 2,
          mapController,
          tickerProvider,
        );
      }
    });
  }
  // Build a temporary marker, used when a new marker is being created
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
          image: AssetImage(
            'assets/images/marker/marker-icon-black.png',
          ),
        ),
      ),
    );
  }
  // Util method for POI types and modifiers lists
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
      element = element.replaceAll('_', ''); // Clear special chars
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
          height: SizeConfig.fontTextBigSize,
          child: RichText(
            text: TextSpan(
              children: [
                const WidgetSpan(
                  child: SizedBox(width: 4.0),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: SvgPicture.asset(
                    'assets/images/icon/$element.svg',
                    width: SizeConfig.iconSize,
                    height: SizeConfig.iconSize,
                    colorFilter: selected.contains(element) 
                      ? ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn)
                      : ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn),
                  ),
                ),
                const WidgetSpan(
                  child: SizedBox(width: 8.0),
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
      // Make item interactive or not
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
}
