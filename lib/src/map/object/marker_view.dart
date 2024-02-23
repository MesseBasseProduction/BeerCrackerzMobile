import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:beercrackerz/src/map/object/marker_data.dart';

class MarkerView {
  static Marker buildSpotMarkerView(
      MarkerData data, BuildContext context, MapController mapController) {
    return Marker(
      height: 30.0,
      width: 30.0,
      point: LatLng(data.lat, data.lng),
      child: GestureDetector(
        onTap: () {
          onMarkerTapped(data, context, mapController);
        },
        child: const Image(
            image: AssetImage('assets/images/marker/marker-icon-green.png')),
      ),
    );
  }

  static Marker buildShopMarkerView(
      MarkerData data, BuildContext context, MapController mapController) {
    return Marker(
      height: 30.0,
      width: 30.0,
      point: LatLng(data.lat, data.lng),
      child: GestureDetector(
        onTap: () {
          onMarkerTapped(data, context, mapController);
        },
        child: const Image(
            image: AssetImage('assets/images/marker/marker-icon-blue.png')),
      ),
    );
  }

  static Marker buildBarMarkerView(
      MarkerData data, BuildContext context, MapController mapController) {
    return Marker(
      height: 30.0,
      width: 30.0,
      point: LatLng(data.lat, data.lng),
      child: GestureDetector(
        onTap: () {
          onMarkerTapped(data, context, mapController);
        },
        child: const Image(
            image: AssetImage('assets/images/marker/marker-icon-red.png')),
      ),
    );
  }

  static void onMarkerTapped(
      MarkerData data, BuildContext context, MapController mapController) {
    // Internal method to build types/modifiers "button"-like elements
    List<Widget> buildListElements(types) {
      List<Widget> output = [];
      for (var element in types) {
        Container typeElem = Container(
          margin: const EdgeInsets.all(4.0),
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white, // TODO text color
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
                            ? AppLocalizations.of(context)!
                                .shopFeatures(element)
                            : AppLocalizations.of(context)!
                                .barFeatures(element)),
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

    // Move map to the marker position (TODO, improve offset from zoom)
    mapController.move(LatLng(data.lat, data.lng), mapController.camera.zoom);
    // Display POI informations in scrollable modal bottom sheet
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (BuildContext context) {
        return Container(
          height: 250,
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
    );
  }
}
