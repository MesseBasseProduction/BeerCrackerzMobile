import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapUtils {
  // Perform an animation to destination Lat/Lng
  // to smoothen user navigation on map.
  static void animatedMapMove(
    LatLng destLocation,
    double destZoom,
    MapController mapController,
    TickerProvider tickerProvider,
  ) {
    final camera = mapController.camera;
    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: camera.zoom,
      end: destZoom,
    );
    final controller = AnimationController(
      duration: const Duration(
        milliseconds: 500,
      ),
      vsync: tickerProvider,
    );
    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );
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

      hasTriggeredMove |= mapController.move(
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
}
