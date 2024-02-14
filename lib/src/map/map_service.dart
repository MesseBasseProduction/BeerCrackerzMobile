import 'package:beercrackerz/src/map/object/spots.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

class MapService {
  late Future<Spots> spots;

  void initState() {
    spots = fetchSpots();
  }

  Future<Spots> fetchSpots() async {
    final response = await http.get(Uri.parse('https://beercrackerz.org/api/spot/'));
      if (response.statusCode == 200) {
        return Spots.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load album');
      }
  }
}
