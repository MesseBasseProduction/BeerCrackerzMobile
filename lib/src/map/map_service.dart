import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '/src/map/marker/marker_data.dart';

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

  static Future<http.Response> postSpot(
    String token,
    MarkerData markerData,
  ) async {
    return await http.post(
      Uri.parse('https://beercrackerz.org/api/spot/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': markerData.name,
        'description': markerData.description,
        'lat': markerData.lat,
        'lng': markerData.lng,
        'rate': markerData.rate,
        'types': markerData.types,
        'modifiers': markerData.modifiers
      }),
    );
  }

  static Future<http.Response> postShop(
    String token,
    MarkerData markerData,
  ) async {
    return await http.post(
      Uri.parse('https://beercrackerz.org/api/shop/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': markerData.name,
        'description': markerData.description,
        'lat': markerData.lat,
        'lng': markerData.lng,
        'rate': markerData.rate,
        'price': markerData.price,
        'types': markerData.types,
        'modifiers': markerData.modifiers
      }),
    );
  }

  static Future<http.Response> postBar(
    String token,
    MarkerData markerData,
  ) async {
    return await http.post(
      Uri.parse('https://beercrackerz.org/api/bar/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': markerData.name,
        'description': markerData.description,
        'lat': markerData.lat,
        'lng': markerData.lng,
        'rate': markerData.rate,
        'price': markerData.price,
        'types': markerData.types,
        'modifiers': markerData.modifiers
      }),
    );
  }
  
  static Future<http.Response> patchSpot(
    String token,
    MarkerData markerData,
  ) async {
    return await http.patch(
      Uri.parse('https://beercrackerz.org/api/spot/${markerData.id}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': markerData.name,
        'description': markerData.description,
        'lat': markerData.lat,
        'lng': markerData.lng,
        'rate': markerData.rate,
        'price': markerData.price,
        'types': markerData.types,
        'modifiers': markerData.modifiers
      }),
    );
  }

  static Future<http.Response> patchShop(
    String token,
    MarkerData markerData,
  ) async {
    return await http.patch(
      Uri.parse('https://beercrackerz.org/api/shop/${markerData.id}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': markerData.name,
        'description': markerData.description,
        'lat': markerData.lat,
        'lng': markerData.lng,
        'rate': markerData.rate,
        'price': markerData.price,
        'types': markerData.types,
        'modifiers': markerData.modifiers
      }),
    );
  }

  static Future<http.Response> patchBar(
    String token,
    MarkerData markerData,
  ) async {
    return await http.patch(
      Uri.parse('https://beercrackerz.org/api/bar/${markerData.id}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': markerData.name,
        'description': markerData.description,
        'lat': markerData.lat,
        'lng': markerData.lng,
        'rate': markerData.rate,
        'price': markerData.price,
        'types': markerData.types,
        'modifiers': markerData.modifiers
      }),
    );
  }

  static Future<http.Response> deleteSpot(
    String token,
    int id,
  ) async {
    return await http.delete(
      Uri.parse('https://beercrackerz.org/api/spot/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
  }

  static Future<http.Response> deleteShop(
    String token,
    int id,
  ) async {
    return await http.delete(
      Uri.parse('https://beercrackerz.org/api/shop/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
  }

  static Future<http.Response> deleteBar(
    String token,
    int id,
  ) async {
    return await http.delete(
      Uri.parse('https://beercrackerz.org/api/bar/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
  }
}
