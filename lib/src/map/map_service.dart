import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '/src/map/marker/marker_data.dart';
import '/src/utils/app_const.dart';
// Utils class to perform HTTP calls for spots/shops/bars
class MapService {

  /* Marker fetching and building */

  static Future<List> getMark(
    type,
  ) async {
    final response = await http.get(Uri.parse('${AppConst.baseURL}/api/$type/'));
    if (response.statusCode == 200) {
      String source = const Utf8Decoder().convert(response.bodyBytes);
      return jsonDecode(source);
    } else {
      // Something went wrong with request
      throw Exception('HTTP call failed : ${AppConst.baseURL}/api/$type/ returned ${response.statusCode}');
    }
  }

  static Future<List<MarkerData>> getSpots() async {
    List<MarkerData> output = [];
    await MapService.getMark('spot').then((spots) {
      for (var spot in spots) {
        output.add(
          MarkerData.fromJson(spot),
        );
      }
    }).catchError((handleError) {
      // An eror occured while creating individual MarkerData
      throw Exception(handleError);
    });
    return output;
  }

  static Future<List<MarkerData>> getShops() async {
    List<MarkerData> output = [];
    await MapService.getMark('shop').then((shops) {
      for (var shop in shops) {
        output.add(
          MarkerData.fromJson(shop),
        );
      }
    }).catchError((handleError) {
      // An eror occured while creating individual MarkerData
      throw Exception(handleError);
    });
    return output;
  }

  static Future<List<MarkerData>> getBars() async {
    List<MarkerData> output = [];
    await MapService.getMark('bar').then((bars) {
      for (var bar in bars) {
        output.add(
          MarkerData.fromJson(bar),
        );
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
      Uri.parse('${AppConst.baseURL}/api/spot/'),
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
      Uri.parse('${AppConst.baseURL}/api/shop/'),
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
      Uri.parse('${AppConst.baseURL}/api/bar/'),
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
      Uri.parse('${AppConst.baseURL}/api/spot/${markerData.id}/'),
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
      Uri.parse('${AppConst.baseURL}/api/shop/${markerData.id}/'),
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
      Uri.parse('${AppConst.baseURL}/api/bar/${markerData.id}/'),
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

  static Future<http.Response> deleteMark(
    String type,
    String token,
    int id,
  ) async {
    return await http.delete(
      Uri.parse('${AppConst.baseURL}/api/$type/$id/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
  }

  static Future<http.Response> deleteSpot(
    String token,
    int id,
  ) async {
    return deleteMark(
      'spot',
      token,
      id,
    );
  }

  static Future<http.Response> deleteShop(
    String token,
    int id,
  ) async {
    return deleteMark(
      'shop',
      token,
      id,
    );
  }

  static Future<http.Response> deleteBar(
    String token,
    int id,
  ) async {
    return deleteMark(
      'bar',
      token,
      id,
    );
  }
}
