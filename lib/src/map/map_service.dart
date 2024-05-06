import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import 'package:beercrackerz/src/map/object/marker_data.dart';
import 'package:beercrackerz/src/map/object/marker_view.dart';

// Utils class to use geolocation, perform HTTP call and build markers
class MapService {

  /* Marker fetching and building */

  static Future<List> fetchMarkersFromType(type) async {
    final response = await http.get(Uri.parse('https://beercrackerz.org/api/$type/'));
    if (response.statusCode == 200) {
      String source = const Utf8Decoder().convert(response.bodyBytes);
      return jsonDecode(source);
    } else {
      // Something went wrong with request
      throw Exception('HTTP call failed : https://beercrackerz.org/api/$type/ returned ${response.statusCode}');
    }
  }

  static Future<List> fetchSpots() async {
    return await fetchMarkersFromType('spot');
  }

  static Future<List> fetchShops() async {
    return await fetchMarkersFromType('shop');
  }

  static Future<List> fetchBars() async {
    return await fetchMarkersFromType('bar');
  }

  static Future<List<MarkerData>> getSpots() async {
    List<MarkerData> output = [];

    await MapService.fetchSpots().then((spots) {
      for (var spot in spots) {
        output.add(MarkerData.fromJson(spot));
      }
    }).catchError((handleError) {
      // An eror occured while creating individual MarkerData
      throw Exception(handleError);
    });

    return output;
  }

  static Future<List<MarkerData>> getShops() async {
    List<MarkerData> output = [];

    await MapService.fetchShops().then((shops) {
      for (var shop in shops) {
        output.add(MarkerData.fromJson(shop));
      }
    }).catchError((handleError) {
      // An eror occured while creating individual MarkerData
      throw Exception(handleError);
    });

    return output;
  }

  static Future<List<MarkerData>> getBars() async {
    List<MarkerData> output = [];

    await MapService.fetchBars().then((bars) {
      for (var bar in bars) {
        output.add(MarkerData.fromJson(bar));
      }
    }).catchError((handleError) {
      // An eror occured while creating individual MarkerData
      throw Exception(handleError);
    });

    return output;
  }

  /* Marker view building, proxyfies methods from MarkerView */

  static Marker buildMarkerView(String type, MarkerData data, BuildContext context, MapController mapController, Function animatedMapMove, int userId) {
    if (type == 'spot') {
      return MarkerView.buildSpotMarkerView(data, context, mapController, animatedMapMove, userId);
    } else if (type == 'shop') {
      return MarkerView.buildShopMarkerView(data, context, mapController, animatedMapMove, userId);
    } else if (type == 'bar') {
      return MarkerView.buildBarMarkerView(data, context, mapController, animatedMapMove, userId);
    } else {
      throw Exception('Invalid type $type to build view from');
    }
  }

  static Marker buildWIPMarkerView(LatLng latLng, BuildContext context, MapController mapController) {
    return MarkerView.buildWIPMarkerView(latLng, context, mapController);
  }

  static Widget buildNewSpotModal(BuildContext context, String type, GlobalKey<FormState> formKey, MarkerData data) {
    return MarkerView.buildNewSpotModal(context, type, formKey, data);
  }

  static Widget buildNewShopModal(BuildContext context, String type, GlobalKey<FormState> formKey) {
    return MarkerView.buildNewShopModal(context, type, formKey);
  }
}
