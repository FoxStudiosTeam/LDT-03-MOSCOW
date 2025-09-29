import 'dart:convert';

import 'package:latlong2/latlong.dart';

class Pagination {
  final int limit;
  final int offset;

  Pagination(this.limit, this.offset);

  Map<String, dynamic> toJson() => {'limit': limit, 'offset': offset};
}

class PaginationResponseWrapper<T> {
  final List<T> items;
  final int total;

  PaginationResponseWrapper({
    required this.items,
    required this.total,
  });

  factory PaginationResponseWrapper.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    final rawItems = json['result'];
    final List<dynamic> listItems = (rawItems is List) ? rawItems : [];

    return PaginationResponseWrapper<T>(
      items: listItems.map((elem) => fromJsonT(elem as Map<String, dynamic>)).toList(),
      total: json['total'] ?? 0,
    );
  }
}


enum ProjectStatus {
  NEW,
  PRE_ACTIVE,
  NORMAL,
  SOME_WARNINGS,
  LOW_PUNISHMENT,
  NORMAL_PUNISHMENT,
  HIGH_PUNISHMENT,
  SUSPEND,
}

ProjectStatus projectStatusFromInt(int status) {
  if (status < 0 || status >= ProjectStatus.values.length) {
    return ProjectStatus.NEW;
  }
  return ProjectStatus.values[status];
}

class FoxPolygon {
  final String type;
  final List<List<List<double>>> coordinates;
  final List<LatLng> points;

  FoxPolygon({
    required this.type,
    required this.coordinates,
  }) : points = _extractPoints(coordinates);

  /// Фабричный метод из JSON
  factory FoxPolygon.fromJson(Map<String, dynamic> json) {
    final rawCoordinates = json['coordinates'] as List<dynamic>? ?? [];

    final coordinates = rawCoordinates
        .map<List<List<double>>>((ring) =>
        (ring as List<dynamic>)
            .map<List<double>>((point) =>
            (point as List<dynamic>)
                .map<double>((value) => (value as num).toDouble())
                .toList())
            .toList())
        .toList();

    return FoxPolygon(
      type: json['type'] as String? ?? '',
      coordinates: coordinates,
    );
  }

  /// Вычисление центра полигона
  LatLng getCenter() {
    if (points.isEmpty) return const LatLng(0, 0);

    final sum = points.reduce((a, b) =>
        LatLng(a.latitude + b.latitude, a.longitude + b.longitude));
    final avgLat = sum.latitude / points.length;
    final avgLng = sum.longitude / points.length;

    return LatLng(avgLat, avgLng);
  }

  /// Преобразование координат в LatLng
  static List<LatLng> _extractPoints(List<List<List<double>>> coords) {
    final List<LatLng> result = [];

    for (final ring in coords) {
      for (final point in ring) {
        if (point.length >= 2) {
          result.add(LatLng(point[1], point[0])); // [lon, lat] → LatLng(lat, lon)
        }
      }
    }

    return result;
  }
}



class Project {
  final String address;
  final String created_by;
  final DateTime? end_date;
  final String foreman;
  final FoxPolygon? polygon;
  final String ssk;
  final DateTime? start_date;
  final ProjectStatus status;
  final String uuid;

  Project({
    required this.address,
    required this.created_by,
    required this.end_date,
    required this.foreman,
    required this.polygon,
    required this.ssk,
    required this.start_date,
    required this.status,
    required this.uuid,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    final projectJson = json['project'] ?? {};

    return Project(
      address: projectJson['address'] ?? '',
      created_by: projectJson['created_by'] ?? '',
      end_date: projectJson['end_date'] != null
          ? DateTime.tryParse(projectJson['end_date'])
          : null,
      foreman: projectJson['foreman'] ?? '',
      polygon: projectJson['polygon'] != null
          ? FoxPolygon.fromJson(jsonDecode(projectJson['polygon']))
          : null,
      ssk: projectJson['ssk'] ?? '',
      start_date: projectJson['start_date'] != null
          ? DateTime.tryParse(projectJson['start_date'])
          : null,
      status: projectStatusFromInt(projectJson['status'] ?? 0),
      uuid: projectJson['uuid'] ?? '',
    );
  }
}

