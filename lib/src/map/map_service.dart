import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import 'package:beercrackerz/src/map/map_view.dart';
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

  /* Marker submission, edition and deletion */

  static Future<http.Response> postNewSpot(String token, MarkerData marker) async {
    return await http.post(
      Uri.parse('https://beercrackerz.org/api/spot/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': marker.name,
        'description': marker.description,
        'lat': marker.lat,
        'lng': marker.lng,
        'rate': marker.rate,
        'types': marker.types,
        'modifiers': marker.modifiers
      }),
    );
  }

  static Future<http.Response> postNewShop(String token, MarkerData marker) async {
    return await http.post(
      Uri.parse('https://beercrackerz.org/api/shop/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': marker.name,
        'description': marker.description,
        'lat': marker.lat,
        'lng': marker.lng,
        'rate': marker.rate,
        'price': marker.price,
        'types': marker.types,
        'modifiers': marker.modifiers
      }),
    );
  }

  static Future<http.Response> postNewBar(String token, MarkerData marker) async {
    return await http.post(
      Uri.parse('https://beercrackerz.org/api/bar/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': marker.name,
        'description': marker.description,
        'lat': marker.lat,
        'lng': marker.lng,
        'rate': marker.rate,
        'price': marker.price,
        'types': marker.types,
        'modifiers': marker.modifiers
      }),
    );
  }
  
  static Future<http.Response> patchEditSpot(String token, MarkerData marker) async {
    return await http.patch(
      Uri.parse('https://beercrackerz.org/api/spot/${marker.id}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': marker.name,
        'description': marker.description,
        'lat': marker.lat,
        'lng': marker.lng,
        'rate': marker.rate,
        'price': marker.price,
        'types': marker.types,
        'modifiers': marker.modifiers
      }),
    );
  }

  static Future<http.Response> patchEditShop(String token, MarkerData marker) async {
    return await http.patch(
      Uri.parse('https://beercrackerz.org/api/shop/${marker.id}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': marker.name,
        'description': marker.description,
        'lat': marker.lat,
        'lng': marker.lng,
        'rate': marker.rate,
        'price': marker.price,
        'types': marker.types,
        'modifiers': marker.modifiers
      }),
    );
  }

  static Future<http.Response> patchEditBar(String token, MarkerData marker) async {
    return await http.patch(
      Uri.parse('https://beercrackerz.org/api/bar/${marker.id}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': marker.name,
        'description': marker.description,
        'lat': marker.lat,
        'lng': marker.lng,
        'rate': marker.rate,
        'price': marker.price,
        'types': marker.types,
        'modifiers': marker.modifiers
      }),
    );
  }

  static Future<http.Response> deleteSpot(String token, int id) async {
    return await http.delete(
      Uri.parse('https://beercrackerz.org/api/spot/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
  }

  static Future<http.Response> deleteShop(String token, int id) async {
    return await http.delete(
      Uri.parse('https://beercrackerz.org/api/shop/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
  }

  static Future<http.Response> deleteBar(String token, int id) async {
    return await http.delete(
      Uri.parse('https://beercrackerz.org/api/bar/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
  }

  /* Marker view building, proxyfies methods from MarkerView */

  static Marker buildMarkerView(
    String type,
    MarkerData data,
    BuildContext context, 
    MapView mapView,
    MapController mapController,
    Function animatedMapMove,
    int userId,
    Function removeCallback,
    Function editCallback
  ) {
    if (type == 'spot') {
      return MarkerView.buildSpotMarkerView(data, context, mapView, mapController, animatedMapMove, userId, removeCallback, editCallback);
    } else if (type == 'shop') {
      return MarkerView.buildShopMarkerView(data, context, mapView, mapController, animatedMapMove, userId, removeCallback, editCallback);
    } else if (type == 'bar') {
      return MarkerView.buildBarMarkerView(data, context, mapView, mapController, animatedMapMove, userId, removeCallback, editCallback);
    } else {
      throw Exception('Invalid type $type to build view from');
    }
  }

  static Marker buildWIPMarkerView(LatLng latLng, BuildContext context, MapController mapController) {
    return MarkerView.buildWIPMarkerView(latLng, context, mapController);
  }

// TODo remove type from arg, as its in method name duh
  static Widget buildNewSpotModal(BuildContext context, MapView mapView, String type, GlobalKey<FormState> formKey, MarkerData data, Function callback) {
    return MarkerView.buildNewSpotModal(context, mapView, type, formKey, data, callback);
  }

  static Widget buildNewShopModal(BuildContext context, MapView mapView, String type, GlobalKey<FormState> formKey, MarkerData data, Function callback) {
    return MarkerView.buildNewShopModal(context, mapView, type, formKey, data, callback);
  }

  static Widget buildNewBarModal(BuildContext context, MapView mapView, String type, GlobalKey<FormState> formKey, MarkerData data, Function callback) {
    return MarkerView.buildNewBarModal(context, mapView, type, formKey, data, callback);
  }

  static Widget buildEditSpotModal(BuildContext context, MapView mapView, GlobalKey<FormState> formKey, MarkerData data) {
    return MarkerView.buildEditSpotModal(context, mapView, formKey, data);
  }

  static Widget buildEditShopModal(BuildContext context, MapView mapView, GlobalKey<FormState> formKey, MarkerData data) {
    return MarkerView.buildEditShopModal(context, mapView, formKey, data);
  }

  static Widget buildEditBarModal(BuildContext context, MapView mapView, GlobalKey<FormState> formKey, MarkerData data) {
    return MarkerView.buildEditBarModal(context, mapView, formKey, data);
  }
}
