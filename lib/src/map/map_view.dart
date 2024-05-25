import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '/src/auth/auth_view.dart';
import '/src/map/map_service.dart';
import '/src/map/marker/marker_data.dart';
import '/src/map/marker/marker_view.dart';
import '/src/map/modal/edit_marker_view.dart';
import '/src/map/modal/map_options_view.dart';
import '/src/map/modal/new_marker_view.dart';
import '/src/map/utils/map_utils.dart';
import '/src/settings/settings_controller.dart';
import '/src/utils/size_config.dart';
// Hold the main widget map view, that contains
// all spots, shops and bars saved on server. Handle
// the user interctaion with map to add/edit/remove markers.
class MapView extends StatefulWidget {
  const MapView({
    super.key,
    required this.settingsController,
  });

  static const routeName = '/map';
  final SettingsController settingsController;

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
  // Temporary marker when user wants to add a new mark
  final List<Marker> wipMarker = [];
  // FlutterMap controller
  late MapController _mapController;
  // Map user session settings (not saved upon restart)
  bool showSpots = true;
  bool showShops = true;
  bool showBars = true;
  bool showWIP = false;
  String mapLayer = 'osm';
  // Position alignment stream controller
  late AlignOnUpdate _alignPositionOnUpdate;
  late final StreamController<double?> _alignPositionStreamController;
  double restoredZoomed = 0; // To restore zoom level when unlocking position
  // InitState main purpose is to async load spots/shops/bars
  @override
  void initState() {
    super.initState();
    // User location stream controller
    _alignPositionOnUpdate = AlignOnUpdate.never;
    _alignPositionStreamController = StreamController<double?>();
    // Create internal MapController
    _mapController = MapController();
    // Allow map build while gettings marks from server
    setState(() {});
    // Fetch and build Spots, Shops and Bars.
    // Must delay data server calls to ensure context is set in buid
    Future.delayed(Duration.zero, () {
      MapService.getSpots().then((spotMarkersData) {
        for (var markerData in spotMarkersData) {
          _spotMarkerView.add(
            MarkerView.buildMarkerView(
              context,
              _mapController,
              widget,
              markerData,
              this,
              removeMarker,
              editMarker,
            ),
          );
        }
        // Render UI modifications
        setState(() {});
      });

      MapService.getShops().then((shopMarkersData) {
        for (var markerData in shopMarkersData) {
          _shopMarkerView.add(
            MarkerView.buildMarkerView(
              context,
              _mapController,
              widget,
              markerData,
              this,
              removeMarker,
              editMarker,
            ),
          );
        }
        // Render UI modifications
        setState(() {});
      });

      MapService.getBars().then((barMarkersData) {
        for (var markerData in barMarkersData) {
          _barMarkerView.add(
            MarkerView.buildMarkerView(
              context,
              _mapController,
              widget,
              markerData,
              this,
              removeMarker,
              editMarker,
            ),
          );
        }
        // Render UI modifications
        setState(() {});
      });
    });
  }
  // Clear position stream upon dispose
  @override
  void dispose() {
    // Release user position stream on dispose widget
    _alignPositionStreamController.close();
    super.dispose();
  }
  // Add new marker callback, must be called from bottom modal sheet
  void addMarker(
    String type,
    MarkerData markerData,
  ) {
    // Create marker
    Marker marker = MarkerView.buildMarkerView(
      context,
      _mapController,
      widget,
      markerData,
      this,
      removeMarker,
      editMarker,
    );
    // Push it to associated Marker List
    if (type == 'spot') {
      _spotMarkerView.add(marker);
    } else if (type == 'shop') {
      _shopMarkerView.add(marker);
    } else if (type == 'bar') {
      _barMarkerView.add(marker);
    }
    // Render UI modifications
    setState(() {});
    // Close bottom sheet as this callback is performed upon success
    Navigator.pop(context);
  }
  // Remove marker callback, must be called from bottom modal sheet
  void removeMarker(
    MarkerData markerData,
  ) {
    if (markerData.type == 'spot') {
      for (var mark in _spotMarkerView) {
        if (mark.point.latitude == markerData.lat && mark.point.longitude == markerData.lng) {
          _spotMarkerView.remove(mark);
          break;
        }
      }
    } else if (markerData.type == 'shop') {
      for (var mark in _shopMarkerView) {
        if (mark.point.latitude == markerData.lat && mark.point.longitude == markerData.lng) {
          _shopMarkerView.remove(mark);
          break;
        }
      }
    } else if (markerData.type == 'bar') {
      for (var mark in _barMarkerView) {
        if (mark.point.latitude == markerData.lat && mark.point.longitude == markerData.lng) {
          _barMarkerView.remove(mark);
          break;
        }
      }
    }
    // Render UI modifications
    setState(() {});
    // Close bottom sheet as this callback is performed upon success
    Navigator.pop(context);
  }
  // Edit marker modal sheet
  void editMarker(
    MarkerData markerData,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      barrierColor: Colors.black.withOpacity(0.1),
      shape: const RoundedRectangleBorder(),
      builder: (
        BuildContext context,
      ) {
        return EditMarkerView(
          mapView: widget,
          markerData: markerData,
        );
      },
    ).whenComplete(() {
      MapUtils.animatedMapMove(
        LatLng(
          markerData.lat,
          markerData.lng,
        ),
        _mapController.camera.zoom - 2,
        _mapController,
        this,
      );
      setState(() {});
    });
  }
  // New marker modal sheet
  void newMarkerModal(
    LatLng latLng,
    double mapLatRange,
  ) {
    // Fake data, won't be sent to server
    MarkerData markerData = MarkerData(
      id: 42,
      type: 'spot',
      name: '',
      description: '',
      lat: latLng.latitude,
      lng: latLng.longitude,
      rate: 3.0,
      types: [],
      modifiers: [],
      user: widget.settingsController.username,
      userId: widget.settingsController.userId,
      creationDate: '',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      barrierColor: Colors.black.withOpacity(0.1),
      shape: const RoundedRectangleBorder(),
      builder: (
        BuildContext context,
      ) {
        return NewMarkerView(
          mapView: widget,
          markerData: markerData,
          callback: addMarker,
        );
      },
    ).whenComplete(() {
      MapUtils.animatedMapMove(
        LatLng(
          latLng.latitude - (mapLatRange / 2),
          latLng.longitude,
        ),
        _mapController.camera.zoom - 2,
        _mapController,
        this,
      );
      showWIP = false;
      wipMarker.clear();
      setState(() {});
    });
  }
  // Map options modal sheet
  void mapOptionsModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (
        BuildContext context,
      ) {
        return MapOptionsView(
          mapLayer: mapLayer,
          showSpots: showSpots,
          showShops: showShops,
          showBars: showBars,
          setter: mapOptionsSetter,
        );
      },
    );
  }
  // Calback function to set MapView internal values according to option changed
  void mapOptionsSetter(
    String type,
    dynamic value,
  ) {
    if (type == 'mapLayer') {
      mapLayer = value;
    } else if (type == 'showSpots') {
      showSpots = value;
    } else if (type == 'showShops') {
      showShops = value;
    } else if (type == 'showBars') {
      showBars = value;
    }
    setState(() {});
  }
  // Map widget builing
  @override
  Widget build(
    BuildContext context,
  ) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: null,
      resizeToAvoidBottomInset: false, // Do not move map when keyboard appear
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(
            48.8605277263,
            2.34402407374,
          ),
          initialZoom: 11.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag
          ),
          minZoom: 0,
          maxZoom: 19,
          // user position tracking on map
          onPositionChanged: (
            MapPosition position,
            bool hasGesture,
          ) {
            if (hasGesture && _alignPositionOnUpdate != AlignOnUpdate.never) {
              setState(() => _alignPositionOnUpdate = AlignOnUpdate.never);
            }
          },
          // Map clicked callback, add marker only if logged in
          onTap: (widget.settingsController.isLoggedIn == true)
            ? (
                TapPosition position,
                LatLng latLng,
              ) {
                if (showWIP == false) {
                  // Add temporary marker
                  wipMarker.add(
                    MarkerView.buildWIPMarkerView(
                      context,
                      _mapController,
                      latLng,
                    ),
                  );
                  // Compute current map bound and lat/lng range for those bounds
                  LatLngBounds bounds = _mapController.camera.visibleBounds;
                  double mapLatRange = (SizeConfig.modalHeightRatio * (bounds.northWest.latitude - bounds.southEast.latitude).abs()) / 400;
                  // Move map to the marker position, with modal opened offset
                  MapUtils.animatedMapMove(
                    LatLng(
                      latLng.latitude - (mapLatRange / 2),
                      latLng.longitude,
                    ),
                    _mapController.camera.zoom + 2,
                    _mapController,
                    this,
                  );
                  // Then create new marker modal
                  newMarkerModal(
                    latLng,
                    mapLatRange,
                  );
                }
                // Invert wip state
                showWIP = !showWIP;
                setState(() {});
              }
            : (
                TapPosition position,
                LatLng latLng,
              ) {}, // Do nothing on click if user is not logged in
        ),
        children: [
          TileLayer(
            urlTemplate: (mapLayer == 'osm')
              ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
              : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: 'com.example.beercrackerz',
          ),
          CurrentLocationLayer(
            alignPositionStream: _alignPositionStreamController.stream,
            alignPositionOnUpdate: _alignPositionOnUpdate,
            style: const LocationMarkerStyle(
              showHeadingSector: false,
              showAccuracyCircle: true,
            ),
          ),
          MarkerLayer(
            markers: (showSpots == true)
              ? _spotMarkerView
              : [],
          ),
          MarkerLayer(
            markers: (showShops == true)
              ? _shopMarkerView
              : [],
          ),
          MarkerLayer(
            markers: (showBars == true)
              ? _barMarkerView
              : [],
          ),
          MarkerLayer(
            markers: (showWIP == true)
              ? wipMarker
              : [],
          ),
          RichAttributionWidget(
            alignment: AttributionAlignment.bottomLeft,
            showFlutterMapAttribution: false,
            popupBackgroundColor: Theme.of(context).colorScheme.primary,
            closeButton: (
              BuildContext context,
              Function close,
            ) {
              return IconButton(
                icon: const Icon(
                  Icons.cancel_outlined,
                ),
                color: Theme.of(context).colorScheme.surface,
                onPressed: () => close(),
                style: const ButtonStyle(),
              );
            },
            attributions: [
              TextSourceAttribution(
                (mapLayer == 'osm')
                  ? AppLocalizations.of(context)!.mapOSMContributors
                  : AppLocalizations.of(context)!.mapEsriContributors,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontStyle: FontStyle.italic,
                ),
                onTap: () => launchUrl(
                  (mapLayer == 'osm')
                    ? Uri.parse('https://openstreetmap.org/copyright')
                    : Uri.parse('https://www.esri.com'),
                ),
              ),
              TextSourceAttribution(
                AppLocalizations.of(context)!.mapFlutterMapContributors,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontStyle: FontStyle.italic,
                ),
                onTap: () => launchUrl(
                  Uri.parse('https://github.com/fleaflet/flutter_map'),
                ),
              ),
            ],
          ),
        ],
      ),
      // Map buttons for profile, centerOn user and map options
      floatingActionButton: Wrap(
        direction: Axis.vertical,
        children: <Widget>[
          // Map filtering operztions
          Container(
            margin: EdgeInsets.symmetric(
              vertical: SizeConfig.paddingTiny,
            ),
            child: FloatingActionButton(
              heroTag: 'filterButton',
              onPressed: () => mapOptionsModal(),
              foregroundColor: null,
              backgroundColor: null,
              child: const Icon(
                Icons.map,
              ),
            ),
          ),
          // Center on user (and lock position on it)
          Container(
            margin: EdgeInsets.symmetric(
              vertical: SizeConfig.paddingTiny,
            ),
            child: FloatingActionButton(
              heroTag: 'centerOnButton',
              onPressed: () {
                if (_alignPositionOnUpdate == AlignOnUpdate.never) {
                  restoredZoomed = _mapController.camera.zoom;
                  _alignPositionStreamController.add(18);
                  setState(() => _alignPositionOnUpdate = AlignOnUpdate.always);
                } else {
                  MapUtils.animatedMapMove(
                    _mapController.camera.visibleBounds.center,
                    restoredZoomed,
                    _mapController,
                    this,
                  );
                  setState(() => _alignPositionOnUpdate = AlignOnUpdate.never);
                }
              },
              foregroundColor: null,
              backgroundColor: null,
              child: Icon(
                Icons.gps_fixed,
                color: (_alignPositionOnUpdate == AlignOnUpdate.always)
                  ? Theme.of(context).colorScheme.secondary
                  : null,
              ),
            ),
          ),
          // Auth/Profile section
          Container(
            margin: EdgeInsets.symmetric(
              vertical: SizeConfig.paddingTiny,
            ),
            child: FloatingActionButton(
              heroTag: 'profileButton',
              onPressed: () => Navigator.restorablePushNamed(
                context,
                AuthView.routeName,
              ),
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
