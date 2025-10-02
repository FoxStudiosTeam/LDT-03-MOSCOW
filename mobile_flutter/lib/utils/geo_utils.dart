import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'dart:developer' as dev;
Future<LatLng?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Геолокация отключена
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Разрешение не дано
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Разрешение навсегда запрещено
    return null;
  }

  final position = await Geolocator.getCurrentPosition();
  return LatLng(position.latitude, position.longitude);
}


abstract class ILocationProvider {
  Future<bool> begin();
  ValueNotifier<LatLng?> get reactiveLocation;
}

const ILocationProviderDIToken = "I-Location-Provider-Provider-DI-Token";

class LocationProvider implements ILocationProvider {
  Timer? _timer;

  final ValueNotifier<LatLng?> _reactiveLocation = ValueNotifier(null);
  
  @override
  ValueNotifier<LatLng?> get reactiveLocation => _reactiveLocation;

  @override
  Future<bool> begin() async {
    final _currentLocation = await getCurrentLocation();
    if (_currentLocation == null) return false;
    if (_timer != null) {
      _reactiveLocation.value = null;
      _timer?.cancel();
    }
    _reactiveLocation.value = _currentLocation;
    // todo!: lazy 3-5 seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final newLocation = await getCurrentLocation();
      _reactiveLocation.value = newLocation;
    });

    return true;
  }

  void dispose() {
    _timer?.cancel();
    _reactiveLocation.dispose();
  }
}


bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
  int intersectCount = 0;
  for (int j = 0; j < polygon.length; j++) {
    LatLng a = polygon[j];
    LatLng b = polygon[(j + 1) % polygon.length];

    // Check if point is within y-bounds of edge
    if (((a.latitude > point.latitude) != (b.latitude > point.latitude)) &&
        (point.longitude <
            (b.longitude - a.longitude) *
                    (point.latitude - a.latitude) /
                    (b.latitude - a.latitude) +
                a.longitude)) {
      intersectCount++;
    }
  }
  return (intersectCount % 2) == 1;
}

double distancePointToSegment(LatLng p, LatLng a, LatLng b) {
  final dx = b.longitude - a.longitude;
  final dy = b.latitude - a.latitude;

  if (dx == 0 && dy == 0) {
    return Distance().as(LengthUnit.Meter, p, a);
  }

  final t = ((p.longitude - a.longitude) * dx + (p.latitude - a.latitude) * dy) /
      (dx * dx + dy * dy);

  if (t < 0) return Distance().as(LengthUnit.Meter, p, a);
  if (t > 1) return Distance().as(LengthUnit.Meter, p, b);

  final projection = LatLng(a.latitude + t * dy, a.longitude + t * dx);
  return Distance().as(LengthUnit.Meter, p, projection);
}

bool isNearOrInsidePolygon(FoxPolygon polygon, double threshold, LatLng point) {
  final points = polygon.points;

  if (isPointInPolygon(point, points)) return true;

  double minDistance = double.infinity;
  for (int i = 0; i < points.length; i++) {
    final a = points[i];
    final b = points[(i + 1) % points.length];
    final dist = distancePointToSegment(point, a, b);
    if (dist < minDistance) minDistance = dist;
  }

  return minDistance <= threshold;
}
