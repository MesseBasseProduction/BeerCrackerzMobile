import 'dart:async';

import 'package:beercrackerz/src/map/modal/new_poi_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:beercrackerz/src/map/map_service.dart';
import 'package:beercrackerz/src/auth/auth_view.dart';
import 'package:beercrackerz/src/settings/settings_controller.dart';

class MapView extends StatefulWidget {
  const MapView({
    super.key,
    required this.controller
  });

  static const routeName = '/map';

  final SettingsController controller;

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
  final List<Marker> wipMarker = []; // Temporary marker when user wants to add a new poi

  late MapController _mapController;

  bool showSpots = true;
  bool showShops = true;
  bool showBars = true;
  bool showWIP = false;
  String mapLayer = 'osm';

  late AlignOnUpdate _alignPositionOnUpdate;
  late final StreamController<double?> _alignPositionStreamController;

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

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = _mapController.camera;
    final latTween = Tween<double>(begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);
    final controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    final startIdWithTarget = 'AnimatedMapController#MoveStarted#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = 'AnimatedMapController#MoveFinished';
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = 'AnimatedMapController#MoveInProgress';
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

  void displayNewPOIModal(LatLng latLng, double mapLatRange) {
//    MediaQueryData mediaQueryData = MediaQuery.of(context);

//    String poiType = 'spot';
/**/

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (BuildContext context) {
        return NewPOIView(controller: widget.controller);
      },
    ).whenComplete(() {
      _animatedMapMove(LatLng(latLng.latitude - (mapLatRange / 2), latLng.longitude), _mapController.camera.zoom - 2);
      showWIP = false;
      wipMarker.clear();
      setState(() {});
    });
/**/
  }

  void displayFilteringModal() {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            height: (35 * mediaQueryData.size.height) / 100, // Taking 35% of screen height
            color: Theme.of(context).colorScheme.background,
            child: Center(
              child: ListView(
                children: [
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                      ),
                      const Text(
                        'Map options',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                      ),
                      const Text(
                        'Map layer style',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                      ToggleSwitch(
                        customWidths: [mediaQueryData.size.width / 3, mediaQueryData.size.width / 3],
                        initialLabelIndex: (mapLayer == 'osm') ? 0 : 1,
                        totalSwitches: 2,
                        labels: const ['Plan', 'Satellite'],
                        onToggle: (index) {
                          if (index == 0) {
                            setState(() => mapLayer = 'osm');
                            setModalState(() {});
                          } else {
                            setState(() => mapLayer = 'esri');
                            setModalState(() {});
                          }
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      const Text(
                        'Points of interest',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0)
                          ),
                          const Image(
                            image: AssetImage('assets/images/marker/marker-icon-green.png'),
                            height: 24.0,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0)
                          ),
                          const Text(
                            'Display spots',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: showSpots,
                            onChanged: (value) {
                              setState(() => showSpots = !showSpots);
                              setModalState(() {});
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0)
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0)
                          ),
                          const Image(
                            image: AssetImage('assets/images/marker/marker-icon-blue.png'),
                            height: 24.0,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0)
                          ),
                          const Text(
                            'Display shops',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: showShops,
                            onChanged: (value) {
                              setState(() => showShops = !showShops);
                              setModalState(() {});
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0)
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0)
                          ),
                          const Image(
                            image: AssetImage('assets/images/marker/marker-icon-red.png'),
                            height: 24.0,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0)
                          ),
                          const Text(
                            'Display bars',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: showBars,
                            onChanged: (value) {
                              setState(() => showBars = !showBars);
                              setModalState(() {});
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0)
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      resizeToAvoidBottomInset: false, // Do not move map when keyboard appear
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
          onPositionChanged:  (MapPosition position, bool hasGesture) {
            if (hasGesture && _alignPositionOnUpdate != AlignOnUpdate.never) {
              setState(() => _alignPositionOnUpdate = AlignOnUpdate.never);
            }
          },
          onTap: (widget.controller.isLoggedIn == true) 
            ? (TapPosition position, LatLng latLng) {
              double mapLatRange = (80 * (_mapController.camera.visibleBounds.northWest.latitude - _mapController.camera.visibleBounds.southEast.latitude).abs()) / 400;
              if (showWIP == false) {
                wipMarker.add(MapService.buildWIPMarkerView(latLng, context, _mapController));
                // Move map to the marker position
                _animatedMapMove(LatLng(latLng.latitude - (mapLatRange / 2), latLng.longitude), _mapController.camera.zoom + 2);
                displayNewPOIModal(latLng, mapLatRange);
              }
              showWIP = !showWIP;
              setState(() {});
            }
            : (TapPosition position, LatLng latLng) {},
        ),
        children: [
          TileLayer(
            urlTemplate: (mapLayer == 'osm') ?
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png' :
              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
            ,
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
          MarkerLayer(
            markers: (showWIP == true) ? wipMarker : [],
          ),
          RichAttributionWidget(
            alignment: AttributionAlignment.bottomLeft,
            showFlutterMapAttribution: false,
            popupBackgroundColor: Theme.of(context).colorScheme.primary,
            closeButton: (BuildContext context, Function close) {
              return IconButton(
                icon: const Icon(Icons.cancel_outlined),
                color: Theme.of(context).colorScheme.surface,
                onPressed: () => close(),
                style: const ButtonStyle(),
              );
            },
            attributions: [
              TextSourceAttribution(
                (mapLayer == 'osm') ? 
                  'OpenStreeMap contributors' :
                  'Powered by Esri'
                ,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontStyle: FontStyle.italic,
                ),
                onTap: () => launchUrl(
                  (mapLayer == 'osm') ? 
                    Uri.parse('https://openstreetmap.org/copyright') :
                    Uri.parse('https://www.esri.com'),
                ),
              ),
              TextSourceAttribution(
                'Flutter Map developers',
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontStyle: FontStyle.italic,
                ),
                onTap: () => launchUrl(Uri.parse('https://github.com/fleaflet/flutter_map')),
              ),
            ],
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
                Icons.map,
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
                  setState(() => _alignPositionOnUpdate = AlignOnUpdate.always);
                  _alignPositionStreamController.add(18);
                } else {
                  setState(() => _alignPositionOnUpdate = AlignOnUpdate.never);
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
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: FloatingActionButton(
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
          ),
        ],
      ),
    );
  }
}
