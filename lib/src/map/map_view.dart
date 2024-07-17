import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

import '/src/auth/auth_view.dart';
import '/src/help/about_view.dart';
import '/src/map/map_service.dart';
import '/src/map/marker/marker_data.dart';
import '/src/map/marker/marker_view.dart';
import '/src/map/modal/edit_marker_view.dart';
import '/src/map/modal/map_options_view.dart';
import '/src/map/modal/new_marker_view.dart';
import '/src/map/utils/map_utils.dart';
import '/src/settings/settings_controller.dart';
import '/src/utils/app_const.dart';
import '/src/utils/size_config.dart';
// Hold the main widget map view, that contains
// all spots, shops and bars saved on server. Handle
// the user interaction with map to add/edit/remove markers.
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
  // All BeerCrackerz markers
  final List<Marker> _allSpotMarkerViews = [];
  final List<MarkerData> _allSpotMarkerData = [];
  final List<Marker> _allShopMarkerViews = [];
  final List<MarkerData> _allShopMarkerData = [];
  final List<Marker> _allBarMarkerViews = [];
  final List<MarkerData> _allBarMarkerData = [];
  // Displayed marker
  List<Marker> _displayedSpotMarkerViews = [];
  List<Marker> _displayedShopMarkerViews = [];
  List<Marker> _displayedBarMarkerViews = [];
  // Temporary marker when user wants to add a new mark
  final List<Marker> wipMarker = [];
  // FlutterMap controller
  late MapController _mapController;
  // Map user session settings (not saved upon restart)
  bool showWIP = false;
  bool doubleTap = false; // Enter double tap mode
  bool doubleTapPerformed = false; // Double tap actually happened
  final OpenRouteService ors = OpenRouteService(
    apiKey: AppConst.osrApiKey!,
  );
  // Position alignment stream controller
  late AlignOnUpdate _alignPositionOnUpdate;
  late final StreamController<double?> _alignPositionStreamController;
  // Navigation route points
  List<LatLng> navRoutePoints = [];
  // Widget internal utils
  Timer? _debounce; // Debounce the saving of initial lat/lng on map move
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
      MapService.getShops().then((shopMarkersData) {
        for (var markerData in shopMarkersData) {
          _allShopMarkerData.add(markerData);
          _allShopMarkerViews.add(
            MarkerView.buildMarkerView(
              context,
              _mapController,
              widget,
              markerData,
              this,
              computeRouteToMark,
              removeMarker,
              editMarker,
            ),
          );
        }
        _displayedShopMarkerViews = MapService.buildDisplayedMarks(
          _allShopMarkerViews,
          _allShopMarkerData,
          (widget.settingsController.showOnlySelf == true)
            ? [widget.settingsController.userId]
            : null
        );
        // Update saved mark stats
        widget.settingsController.updateMarkStats(
          _allSpotMarkerViews.length + _allShopMarkerViews.length + _allBarMarkerViews.length,
          MapService.getMarkCount(
            _allSpotMarkerData,
            widget.settingsController.userId
          ),
          MapService.getMarkCount(
            _allShopMarkerData,
            widget.settingsController.userId
          ),
          MapService.getMarkCount(
            _allBarMarkerData,
            widget.settingsController.userId
          ),
        );
        // Render UI modifications
        setState(() {});
      });

      MapService.getBars().then((barMarkersData) {
        for (var markerData in barMarkersData) {
          _allBarMarkerData.add(markerData);
          _allBarMarkerViews.add(
            MarkerView.buildMarkerView(
              context,
              _mapController,
              widget,
              markerData,
              this,
              computeRouteToMark,
              removeMarker,
              editMarker,
            ),
          );
        }

        _displayedBarMarkerViews = MapService.buildDisplayedMarks(
          _allBarMarkerViews,
          _allBarMarkerData,
          (widget.settingsController.showOnlySelf == true)
            ? [widget.settingsController.userId]
            : null
        );
        // Update saved mark stats
        widget.settingsController.updateMarkStats(
          _allSpotMarkerViews.length + _allShopMarkerViews.length + _allBarMarkerViews.length,
          MapService.getMarkCount(
            _allSpotMarkerData,
            widget.settingsController.userId
          ),
          MapService.getMarkCount(
            _allShopMarkerData,
            widget.settingsController.userId
          ),
          MapService.getMarkCount(
            _allBarMarkerData,
            widget.settingsController.userId
          ),
        );
        // Render UI modifications
        setState(() {});
      });

      MapService.getSpots().then((spotMarkersData) {
        for (var markerData in spotMarkersData) {
          _allSpotMarkerData.add(markerData);
          _allSpotMarkerViews.add(
            MarkerView.buildMarkerView(
              context,
              _mapController,
              widget,
              markerData,
              this,
              computeRouteToMark,
              removeMarker,
              editMarker,
            ),
          );
        }

        _displayedSpotMarkerViews = MapService.buildDisplayedMarks(
          _allSpotMarkerViews,
          _allSpotMarkerData,
          (widget.settingsController.showOnlySelf == true)
            ? [widget.settingsController.userId]
            : null
        );
        // Update saved mark stats
        widget.settingsController.updateMarkStats(
          _allSpotMarkerViews.length + _allShopMarkerViews.length + _allBarMarkerViews.length,
          MapService.getMarkCount(
            _allSpotMarkerData,
            widget.settingsController.userId
          ),
          MapService.getMarkCount(
            _allShopMarkerData,
            widget.settingsController.userId
          ),
          MapService.getMarkCount(
            _allBarMarkerData,
            widget.settingsController.userId
          ),
        );
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
      computeRouteToMark,
      removeMarker,
      editMarker,
    );
    // Push it to associated Marker List
    if (type == 'spot') {
      _allSpotMarkerViews.add(marker);
      _allSpotMarkerData.add(markerData);
      _displayedSpotMarkerViews = MapService.buildDisplayedMarks(
        _allSpotMarkerViews,
        _allSpotMarkerData,
        (widget.settingsController.showOnlySelf == true)
          ? [widget.settingsController.userId]
          : null
      );
    } else if (type == 'shop') {
      _allShopMarkerViews.add(marker);
      _allShopMarkerData.add(markerData);
      _displayedShopMarkerViews = MapService.buildDisplayedMarks(
        _allShopMarkerViews,
        _allShopMarkerData,
        (widget.settingsController.showOnlySelf == true)
          ? [widget.settingsController.userId]
          : null
      );
    } else if (type == 'bar') {
      _allBarMarkerViews.add(marker);
      _allBarMarkerData.add(markerData);
      _displayedBarMarkerViews = MapService.buildDisplayedMarks(
        _allBarMarkerViews,
        _allBarMarkerData,
        (widget.settingsController.showOnlySelf == true)
          ? [widget.settingsController.userId]
          : null
      );
    }
    // Update saved mark stats
    widget.settingsController.updateMarkStats(
      _allSpotMarkerViews.length + _allShopMarkerViews.length + _allBarMarkerViews.length,
      MapService.getMarkCount(
        _allSpotMarkerData,
        widget.settingsController.userId
      ),
      MapService.getMarkCount(
        _allShopMarkerData,
        widget.settingsController.userId
      ),
      MapService.getMarkCount(
        _allBarMarkerData,
        widget.settingsController.userId
      ),
    );
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
      for (var i = 0; i < _allSpotMarkerViews.length; ++i) {
        var mark = _allSpotMarkerViews[i];
        if (mark.point.latitude == markerData.lat && mark.point.longitude == markerData.lng) {
          _allSpotMarkerViews.remove(_allSpotMarkerViews[i]);
          _allSpotMarkerData.remove(_allSpotMarkerData[i]);
          _displayedSpotMarkerViews = MapService.buildDisplayedMarks(
            _allSpotMarkerViews,
            _allSpotMarkerData,
            (widget.settingsController.showOnlySelf == true)
              ? [widget.settingsController.userId]
              : null
          );
          break;
        }
      }
    } else if (markerData.type == 'shop') {
      for (var i = 0; i < _allShopMarkerViews.length; ++i) {
        var mark = _allShopMarkerViews[i];
        if (mark.point.latitude == markerData.lat && mark.point.longitude == markerData.lng) {
          _allShopMarkerViews.remove(_allShopMarkerViews[i]);
          _allShopMarkerData.remove(_allShopMarkerData[i]);
          _displayedSpotMarkerViews = MapService.buildDisplayedMarks(
            _allShopMarkerViews,
            _allShopMarkerData,
            (widget.settingsController.showOnlySelf == true)
              ? [widget.settingsController.userId]
              : null
          );
          break;
        }
      }
    } else if (markerData.type == 'bar') {
      for (var i = 0; i < _allBarMarkerViews.length; ++i) {
        var mark = _allBarMarkerViews[i];
        if (mark.point.latitude == markerData.lat && mark.point.longitude == markerData.lng) {
          _allBarMarkerViews.remove(_allBarMarkerViews[i]);
          _allBarMarkerData.remove(_allBarMarkerData[i]);
          _displayedSpotMarkerViews = MapService.buildDisplayedMarks(
            _allBarMarkerViews,
            _allBarMarkerData,
            (widget.settingsController.showOnlySelf == true)
              ? [widget.settingsController.userId]
              : null
          );
          break;
        }
      }
    }
    // Update saved mark stats
    widget.settingsController.updateMarkStats(
      _allSpotMarkerViews.length + _allShopMarkerViews.length + _allBarMarkerViews.length,
      MapService.getMarkCount(
        _allSpotMarkerData,
        widget.settingsController.userId
      ),
      MapService.getMarkCount(
        _allShopMarkerData,
        widget.settingsController.userId
      ),
      MapService.getMarkCount(
        _allBarMarkerData,
        widget.settingsController.userId
      ),
    );
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
          mapLayer: widget.settingsController.mapLayer,
          showSpots: widget.settingsController.showSpots,
          showShops: widget.settingsController.showShops,
          showBars: widget.settingsController.showBars,
          showOnlySelf: widget.settingsController.showOnlySelf,
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
      widget.settingsController.updateMapLayer(value);
    } else if (type == 'showSpots') {
      widget.settingsController.updateShowSpots(value);
    } else if (type == 'showShops') {
      widget.settingsController.updateShowShops(value);
    } else if (type == 'showBars') {
      widget.settingsController.updateShowBars(value);
    } else if (type == 'showOnlySelf') {
      widget.settingsController.updateShowOnlySelf(value);

      _displayedSpotMarkerViews = MapService.buildDisplayedMarks(
        _allSpotMarkerViews,
        _allSpotMarkerData,
        (widget.settingsController.showOnlySelf == true)
          ? [widget.settingsController.userId]
          : null
      );
      _displayedShopMarkerViews = MapService.buildDisplayedMarks(
        _allShopMarkerViews,
        _allShopMarkerData,
        (widget.settingsController.showOnlySelf == true)
          ? [widget.settingsController.userId]
          : null
      );

      _displayedBarMarkerViews = MapService.buildDisplayedMarks(
        _allBarMarkerViews,
        _allBarMarkerData,
        (widget.settingsController.showOnlySelf == true)
          ? [widget.settingsController.userId]
          : null
      );
    }
    setState(() {});
  }
  // Navigation routing
  void computeRouteToMark(
    MarkerData markerData,
  ) async {
    // Clear any previous route
    setState(() => navRoutePoints = []);
    // Get latest known position to start the path with
    Position? position = await Geolocator.getLastKnownPosition();
    // First ensure route is not over threshold
    double distance = FlutterMapMath().distanceBetween(
      position!.latitude,
      position.longitude,
      markerData.lat,
      markerData.lng,
      'meters',
    );
    if (distance > AppConst.maxDistanceForRoute) {
      if (mounted) {
        // Mark too far from user
        toastification.show(
          context: context,
          title: Text(
            AppLocalizations.of(context)!.mapRouteTooFarToastTitle,
          ),
          description: Text(
            AppLocalizations.of(context)!.mapRouteTooFarToastDescription,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          autoCloseDuration: const Duration(
            seconds: 5,
          ),
          showProgressBar: false,
        );
      }
      return;
    }
    // Now perform ORS route request
    if (mounted) {
      // Put loading overlay to notify user a computation is in progress
      context.loaderOverlay.show();
      // Request route from ORS
      try {
        final List<ORSCoordinate> routeCoordinates = await ors.directionsRouteCoordsGet(
          startCoordinate: ORSCoordinate(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
          endCoordinate: ORSCoordinate(
            latitude: markerData.lat,
            longitude: markerData.lng,
          ),
        );
        // Build final polyline points
        final List<LatLng> routePoints = routeCoordinates
          .map((coordinate) => LatLng(
            coordinate.latitude,
            coordinate.longitude,
          )).toList();
        // Center map between path bounds
        LatLngBounds bounds = LatLngBounds.fromPoints(routePoints);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: EdgeInsets.all(SizeConfig.paddingLarge)
          ),
        );
        // Set widget state with found route
        setState(() {
          navRoutePoints = routePoints;
          // Hide overlay loader
          context.loaderOverlay.hide();
          // Notify user the route was found and is displayed
          toastification.show(
            context: context,
            title: Text(
              AppLocalizations.of(context)!.mapRouteFoundToastTitle,
            ),
            description: Text(
              AppLocalizations.of(context)!.mapRouteFoundToastDescription,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(
              seconds: 5,
            ),
            showProgressBar: false,
          );
        });
      } catch (e) {
        if (mounted) {
          // Hide overlay loader anyway
          context.loaderOverlay.hide();
          // Unable to get route from ORS
          // Error ORS1
          toastification.show(
            context: context,
            title: Text(
              AppLocalizations.of(context)!.mapRouteNotFoundToastTitle,
            ),
            description: Text(
              AppLocalizations.of(context)!.mapRouteNotFoundToastDescription,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(
              seconds: 5,
            ),
            showProgressBar: false,
          );
        }
        return;
      }
    }
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
      floatingActionButtonLocation: (widget.settingsController.leftHanded == true)
        ? FloatingActionButtonLocation.startDocked
        : FloatingActionButtonLocation.endDocked,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                widget.settingsController.initLat,
                widget.settingsController.initLng,
              ),
              initialZoom: widget.settingsController.initZoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag
              ),
              minZoom: 2,
              maxZoom: 19,
              // Force camera to remain on LatLng ranges
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(-90, -180),
                  const LatLng(90, 180),
                ),
              ),
              // User position tracking on map
              onPositionChanged: (
                position,
                hasGesture,
              ) {
                if (hasGesture && _alignPositionOnUpdate != AlignOnUpdate.never) {
                  setState(() => _alignPositionOnUpdate = AlignOnUpdate.never);
                }
                // Update center map to initial lat/lng
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(
                  const Duration(
                    milliseconds: 500,
                  ),
                  () {
                    widget.settingsController.updateInitialPosition(
                      position.center.latitude,
                      position.center.longitude,
                      position.zoom,
                    );
                  },
                );
              },
              // Map clicked callback, add marker only if logged in
              onTap: (widget.settingsController.isLoggedIn == true)
                ? (
                    TapPosition position,
                    LatLng latLng,
                  ) {
                    // First user tap
                    if (doubleTap == false) {
                      doubleTap = true; // Double click candidate
                      Future.delayed(const Duration(milliseconds: 300), () {
                      // Restore flag 
                        doubleTap = false;
                        if (doubleTapPerformed == false) { // No double click occured
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
                            double zoomLevel = _mapController.camera.zoom + 2;
                            // Max zoom restriction with mapRange to avoid mark being offscreen under modal
                            if (_mapController.camera.zoom + 2 > 19) {
                              if (_mapController.camera.zoom + 1 > 19) {
                                zoomLevel = _mapController.camera.zoom;
                                mapLatRange = (SizeConfig.modalHeightRatio * (bounds.northWest.latitude - bounds.southEast.latitude).abs()) / 100;
                              } else {
                                zoomLevel = _mapController.camera.zoom + 1;
                                mapLatRange = (SizeConfig.modalHeightRatio * (bounds.northWest.latitude - bounds.southEast.latitude).abs()) / 200;
                              }
                            }
                            // Move map to the marker position, with modal opened offset
                            MapUtils.animatedMapMove(
                              LatLng(
                                latLng.latitude - (mapLatRange / 2),
                                latLng.longitude,
                              ),
                              zoomLevel,
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
                      });
                    } else {
                      doubleTapPerformed = true;
                      // Restore flag 
                      Future.delayed(const Duration(milliseconds: 300), () {
                        doubleTapPerformed = false;
                      });
                      // Only perform double tap zoom if not exceeding maxZoom for map
                      if (_mapController.camera.zoom + 1 <= 19) {
                        MapUtils.animatedMapMove(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                          _mapController,
                          this,
                        );
                      }
                    }
                  }
                : (
                    TapPosition position,
                    LatLng latLng,
                  ) {
                    // First user tap
                    if (doubleTap == false) {
                      doubleTap = true;
                      // Restore flag 
                      Future.delayed(const Duration(milliseconds: 300), () {
                        doubleTap = false;
                        if (doubleTapPerformed == false) {
                          // Inform user that login went OK
                          toastification.dismissAll(
                            delayForAnimation: false,
                          );
                          toastification.show(
                            context: context,
                            title: Text(
                              AppLocalizations.of(context)!.mapLoginInfoTitle,
                            ),
                            description: Text(
                              AppLocalizations.of(context)!.mapLoginInfoDescription,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            type: ToastificationType.info,
                            style: ToastificationStyle.flatColored,
                            autoCloseDuration: const Duration(
                              seconds: 5,
                            ),
                            showProgressBar: false,
                          );
                        }
                      });
                    } else {
                      doubleTapPerformed = true;
                        // Restore flag 
                        Future.delayed(const Duration(milliseconds: 300), () {
                          doubleTapPerformed = false;
                        });
                      // Only perform double tap zoom if not exceeding maxZoom for map
                      if (_mapController.camera.zoom + 1 <= 19) {
                        MapUtils.animatedMapMove(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                          _mapController,
                          this,
                        );
                      }
                    }
                  },
            ),
            children: [
              // Basemap layer
              TileLayer(
                urlTemplate: (widget.settingsController.mapLayer == 'osm')
                  ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                  : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.messebasseproduction.beercrackerz',
              ),
              // For satelite layer, adding lines and labels tile overlays
              (widget.settingsController.mapLayer == 'esri')
                ? TileLayer(//&api_key=${AppConst.stadiaMapsApiKey}
                    urlTemplate: 'https://tiles-eu.stadiamaps.com/tiles/stamen_terrain-lines/{z}/{x}/{y}{r}.png?api_key=${AppConst.stadiaMapsApiKey}',
                    userAgentPackageName: 'com.messebasseproduction.mondourdannais',
                    retinaMode: true,
                    additionalOptions: {
                      'api_key': AppConst.stadiaMapsApiKey!,
                    },
                  )
                : const SizedBox.shrink(),
              (widget.settingsController.mapLayer == 'esri')
                ? TileLayer(
                    urlTemplate: 'https://tiles-eu.stadiamaps.com/tiles/stamen_terrain-labels/{z}/{x}/{y}{r}.png?api_key=${AppConst.stadiaMapsApiKey}',
                    userAgentPackageName: 'com.messebasseproduction.mondourdannais',
                    retinaMode: true,
                    additionalOptions: {
                      'api_key': AppConst.stadiaMapsApiKey!,
                    },
                  )
                : const SizedBox.shrink(),
              // Navigation route layer, positionned to be bottom all other layers
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: navRoutePoints,
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 5,
                  ),
                ],
              ),
              // User position layer
              CurrentLocationLayer(
                alignPositionStream: _alignPositionStreamController.stream,
                alignPositionOnUpdate: _alignPositionOnUpdate,
                style: const LocationMarkerStyle(
                  showHeadingSector: true,
                  showAccuracyCircle: true,
                ),
              ),
              // Spot marks layer
              MarkerLayer(
                markers: (widget.settingsController.showSpots == true)
                  ? _displayedSpotMarkerViews
                  : [],
              ),
              // Shop marks layer
              MarkerLayer(
                markers: (widget.settingsController.showShops == true)
                  ? _displayedShopMarkerViews
                  : [],
              ),
              // Bar marks layer
              MarkerLayer(
                markers: (widget.settingsController.showBars == true)
                  ? _displayedBarMarkerViews
                  : [],
              ),
              // WIP mark layer
              MarkerLayer(
                markers: (showWIP == true)
                  ? wipMarker
                  : [],
              ),
              // Map attribution
              RichAttributionWidget(
                alignment: (widget.settingsController.leftHanded == true)
                  ? AttributionAlignment.bottomRight
                  : AttributionAlignment.bottomLeft,
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
                    (widget.settingsController.mapLayer == 'osm')
                      ? AppLocalizations.of(context)!.mapOSMContributors
                      : AppLocalizations.of(context)!.mapEsriContributors,
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontStyle: FontStyle.italic,
                    ),
                    onTap: () => launchUrl(
                      (widget.settingsController.mapLayer == 'osm')
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
          // App text title
          Row(
            mainAxisAlignment: (widget.settingsController.leftHanded == true)
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: (widget.settingsController.leftHanded == true)
                      ? 0
                      : SizeConfig.padding,
                  right: (widget.settingsController.leftHanded == true)
                      ? SizeConfig.padding
                      : 0,
                  top: SizeConfig.padding + MediaQuery.of(context).viewPadding.top + SizeConfig.paddingTiny,
                ),
                child: Stack(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.appTitle,
                      style: TextStyle(
                        fontSize: SizeConfig.fontTextTitleSize,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 5
                          ..color = Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.appTitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.background,
                        fontSize: SizeConfig.fontTextTitleSize,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // Map buttons for about, profile, centerOn user and map options
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: [
              SizedBox(
                height: SizeConfig.padding + MediaQuery.of(context).viewPadding.top,
              ),
              FloatingActionButton(
                heroTag: 'aboutButton',
                onPressed: () => Navigator.restorablePushNamed(
                  context,
                  AboutView.routeName,
                ),
                foregroundColor: null,
                backgroundColor: null,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: SizeConfig.iconSize,
                ),
              ),
            ],
          ),
          Column(
            children: [
              // Close navigation button (only displayed if navigation occured)
              (navRoutePoints.isNotEmpty == true) 
                ? Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'closeNavigationButton',
                      onPressed: () {
                        navRoutePoints = [];
                        setState(() {});
                      },
                      foregroundColor: null,
                      backgroundColor: null,
                      child: const Icon(
                        Icons.close,
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.paddingSmall,
                    ),
                  ],
                )
                : const SizedBox.shrink(),
              // Map filtering operations
              FloatingActionButton(
                heroTag: 'filterButton',
                onPressed: () => mapOptionsModal(),
                foregroundColor: null,
                backgroundColor: null,
                child: const Icon(
                  Icons.map,
                ),
              ),
              SizedBox(
                height: SizeConfig.paddingSmall,
              ),
              // Center on user (and lock position on it)
              FloatingActionButton(
                heroTag: 'centerOnButton',
                onPressed: () async {
                  if (_alignPositionOnUpdate == AlignOnUpdate.never) {
                    _alignPositionStreamController.add(_mapController.camera.zoom);
                    setState(() => _alignPositionOnUpdate = AlignOnUpdate.always);
                  } else {
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
              SizedBox(
                height: SizeConfig.paddingSmall,
              ),
              // Auth/Profile section
              FloatingActionButton(
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
              SizedBox(
                height: SizeConfig.padding,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
