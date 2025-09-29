import 'dart:convert';

import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

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


class Polygon {
  final String type;
  final List<List<List<double>>> coordinates;

  Polygon({required this.type, required this.coordinates});

  factory Polygon.fromJson(Map<String, dynamic> json) {
    return Polygon(
      type: json['type'] ?? '',
      coordinates: (json['coordinates'] as List<dynamic>? ?? [])
          .map<List<List<double>>>(
            (l1) => (l1 as List<dynamic>)
            .map<List<double>>(
              (l2) => (l2 as List<dynamic>).map<double>((n) => (n as num).toDouble()).toList(),
        )
            .toList(),
      )
          .toList(),
    );
  }

  GeoPoint getCenter() {
    double x = 0;
    double y = 0;
    int count = 0;

    for (var col in coordinates) {
      for (var point in col) {
        x += point[0];
        y += point[1];
        count++;
      }
    }

    x = x / count;
    y = y / count;
    return GeoPoint(latitude: y, longitude: x);
  }
}


class Project {
  final String address;
  final String created_by;
  final DateTime? end_date;
  final String foreman;
  final Polygon? polygon;
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
          ? Polygon.fromJson(jsonDecode(projectJson['polygon']))
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

