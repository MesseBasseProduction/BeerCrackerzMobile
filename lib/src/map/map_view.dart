import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

import 'package:beercrackerz/src/map/map_service.dart';
import 'package:beercrackerz/src/auth/auth_view.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  static const routeName = '/map';

  @override
  MapViewState createState() {
    return MapViewState();
  }
}

class MapViewState extends State<MapView> with TickerProviderStateMixin {
  // Flutter_Map Markers ready to be set on Map
  final List<Marker> _spotMarkerView = [];
  final List<Marker> _shopMarkerView = [];
  final List<Marker> _barMarkerView = [];
  late MapController _mapController;

  bool showSpots = true;
  bool showShops = true;
  bool showBars = true;

  late AlignOnUpdate _alignPositionOnUpdate;
  late final StreamController<double?> _alignPositionStreamController;

  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final camera = _mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    // Note this method of encoding the target destination is a workaround.
    // When proper animated movement is supported (see #1263) we should be able
    // to detect an appropriate animated movement event which contains the
    // target zoom/center.
    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void displayFilteringModal() {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (BuildContext context) {
        return Container(
          height: (35 * mediaQueryData.size.height) / 100, // Taking 35% of screen height
          color: Theme.of(context).colorScheme.background,
          child: Center(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                ),
                const Text(
                  'Map layers',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                ),
                GestureDetector(
                  onTap: () {
                    showSpots = !showSpots;
                    setState(() {});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage('assets/images/marker/marker-icon-green.png')
                      ),
                      Text(
                        (showSpots == true) ? 'Hide spots' : 'Show spots',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showShops = !showShops;
                    setState(() {});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage('assets/images/marker/marker-icon-blue.png')
                      ),
                      Text(
                        (showShops == true) ? 'Hide shops' : 'Show shops',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showBars = !showBars;
                    setState(() {});
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage('assets/images/marker/marker-icon-red.png')
                      ),
                      Text(
                        (showBars == true) ? 'Hide bars' : 'Show bars',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // InitState main purpose is to async load spots/shops/bars
  @override
  void initState() {
    super.initState();
    // User location stream controller
    _alignPositionOnUpdate = AlignOnUpdate.never;
    _alignPositionStreamController = StreamController<double?>();
    // Create internal MapController
    _mapController = MapController();
    // Must delay data server calls to ensure context is set in buid
    Future.delayed(Duration.zero, () {
      MapService.getSpots().then((spotMarkersData) {
        for (var markerData in spotMarkersData) {
          _spotMarkerView.add(MapService.buildMarkerView('spot', markerData, context, _mapController, _animatedMapMove));
        }
        // Render UI modifications
        setState(() {});
      });

      MapService.getShops().then((shopMarkersData) {
        for (var markerData in shopMarkersData) {
          _shopMarkerView.add(MapService.buildMarkerView('shop', markerData, context, _mapController, _animatedMapMove));
        }
        // Render UI modifications
        setState(() {});
      });

      MapService.getBars().then((barMarkersData) {
        for (var markerData in barMarkersData) {
          _barMarkerView.add(MapService.buildMarkerView('bar', markerData, context, _mapController, _animatedMapMove));
        }
        // Render UI modifications
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    // Release user position stream on dispose widget
    _alignPositionStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(48.8605277263, 2.34402407374),
          initialZoom: 11.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag
          ),
          minZoom: 0,
          maxZoom: 19,
          onPositionChanged: (MapPosition position, bool hasGesture) {
            if (hasGesture && _alignPositionOnUpdate != AlignOnUpdate.never) {
              setState(() => _alignPositionOnUpdate = AlignOnUpdate.never);
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.beercrackerz',
          ),
          CurrentLocationLayer(
            alignPositionStream: _alignPositionStreamController.stream,
            alignPositionOnUpdate: _alignPositionOnUpdate,
            style: const LocationMarkerStyle(
              showHeadingSector: false,
              showAccuracyCircle: true
            ),
          ),
          MarkerLayer(
            markers: (showSpots == true) ? _spotMarkerView : [],
          ),
          MarkerLayer(
            markers: (showShops == true) ? _shopMarkerView : [],
          ),
          MarkerLayer(
            markers: (showBars == true) ? _barMarkerView : [],
          ),
        ],
      ),
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        children: <Widget>[
          // Map filtering operztions
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: FloatingActionButton(
              heroTag: 'filterButton',
              onPressed: () => displayFilteringModal(),
              foregroundColor: null,
              backgroundColor: null,
              child: const Icon(
                Icons.filter_alt_rounded,
              ),
            ),
          ),
          // Center on user (and lock position on it)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: FloatingActionButton(
              heroTag: 'centerOnButton',
              onPressed: () {
                if (_alignPositionOnUpdate == AlignOnUpdate.never) {
                  setState(() {
                    _alignPositionOnUpdate = AlignOnUpdate.always;
                  });
                  _alignPositionStreamController.add(18);
                } else {
                  setState(() {
                    _alignPositionOnUpdate = AlignOnUpdate.never;
                  });
                }
              },
              foregroundColor: null,
              backgroundColor: null,
              child: Icon(
                Icons.gps_fixed,
                color: (_alignPositionOnUpdate == AlignOnUpdate.always) ? Theme.of(context).colorScheme.secondary : null,
              ),
            ),
          ),
          // Auth/Profile section
          FloatingActionButton(
            heroTag: 'profileButton',
            onPressed: () {
              Navigator.restorablePushNamed(context, AuthView.routeName);
            },
            foregroundColor: null,
            backgroundColor: null,
            child: const Icon(
              Icons.account_circle,
            ),
          ),
        ],
      ),
    );
  }
}
