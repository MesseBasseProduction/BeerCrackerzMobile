import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:beercrackerz/src/map/map_service.dart';

import '../auth/login_view.dart';
import '../settings/settings_view.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  static const routeName = '/';

  @override
  MapViewState createState() {
    return MapViewState();
  }
}

class MapViewState extends State<MapView> {
  // Flutter_Map Markers ready to be set on Map
  final List<Marker> _markerViews = [];
  late MapController _mapController;

  // InitState main purpose is to async load spots/shops/bars
  @override
  void initState() {
    super.initState();
    // Create internal MapController
    _mapController = MapController();
    // Must delay call, in order to ensure context is set in buid  
    Future.delayed(Duration.zero, () {
      MapService.getSpots().then((spotMarkersData) {
        for (var markerData in spotMarkersData) {
          _markerViews.add(MapService.buildMarkerView('spot', markerData, context, _mapController));
        }
        // Render UI modifications
        setState(() {});
      });

      MapService.getShops().then((shopMarkersData) {
        for (var markerData in shopMarkersData) {
          _markerViews.add(MapService.buildMarkerView('shop', markerData, context, _mapController));
        }
        // Render UI modifications
        setState(() {});
      });

      MapService.getBars().then((barMarkersData) {
        for (var markerData in barMarkersData) {
          _markerViews.add(MapService.buildMarkerView('bar', markerData, context, _mapController));
        }
        // Render UI modifications
        setState(() {});
      });
    });    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BeerCrackerz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(48.8605277263, 2.34402407374),
          initialZoom: 11.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: _markerViews,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.restorablePushNamed(context, LoginView.routeName);
        },
        foregroundColor: null,
        backgroundColor: null,
        child: const Icon(Icons.account_circle),
      ),
    );
  }
}
