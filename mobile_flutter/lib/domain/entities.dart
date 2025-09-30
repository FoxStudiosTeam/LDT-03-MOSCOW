import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
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

  PaginationResponseWrapper({required this.items, required this.total});

  factory PaginationResponseWrapper.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawItems = json['result'];
    final List<dynamic> listItems = (rawItems is List) ? rawItems : [];

    return PaginationResponseWrapper<T>(
      items: listItems
          .map((elem) => fromJsonT(elem as Map<String, dynamic>))
          .toList(),
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

extension ProjectStatusExtension on ProjectStatus {
  String toReadableString() {
    switch (this) {
      case ProjectStatus.NEW:
        // green
        return "Новый";
      case ProjectStatus.PRE_ACTIVE:
        // yellow
        return "Ожидает активации";
      case ProjectStatus.NORMAL:
        // green
        return "В норме";
      case ProjectStatus.SOME_WARNINGS:
        // yellow_warning_low
        return "Есть замечания";
      case ProjectStatus.LOW_PUNISHMENT:
        // yellow_warning_medium
        return "Есть незначительные разрушения";
        // red_error_low
      case ProjectStatus.NORMAL_PUNISHMENT:
        return "Есть нарушения";
        // red_error_normal
      case ProjectStatus.HIGH_PUNISHMENT:
        return "Есть грубые нарушения";
        // red_error_high
      case ProjectStatus.SUSPEND:
        // gray_disabled_color
        return "Приостановлен";
    }
  }

  Color getStatusColor() {
    switch (this) {
      case ProjectStatus.NEW:
      case ProjectStatus.NORMAL:
        return Colors.green;
      case ProjectStatus.PRE_ACTIVE:
      case ProjectStatus.SOME_WARNINGS:
        return Colors.orange;
      case ProjectStatus.LOW_PUNISHMENT:
        return Colors.amber;
      case ProjectStatus.NORMAL_PUNISHMENT:
        return Colors.redAccent;
      case ProjectStatus.HIGH_PUNISHMENT:
        return Colors.red;
      case ProjectStatus.SUSPEND:
        return Colors.grey;
    }
  }

  Text toRenderingString() {
    return Text(
      toReadableString(),
      style: TextStyle(
        color: getStatusColor(),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

ProjectStatus projectStatusFromInt(int value) {
  return ProjectStatus.values[value.clamp(0, ProjectStatus.values.length - 1)];
}

class FoxPolygon {
  final String type;
  final List<List<List<double>>> coordinates;
  final List<LatLng> points;

  FoxPolygon({required this.type, required this.coordinates})
    : points = _extractPoints(coordinates);

  /// Фабричный метод из JSON
  factory FoxPolygon.fromJson(Map<String, dynamic> json) {
    final rawCoordinates = json['coordinates'] as List<dynamic>? ?? [];

    final coordinates = rawCoordinates
        .map<List<List<double>>>(
          (ring) => (ring as List<dynamic>)
              .map<List<double>>(
                (point) => (point as List<dynamic>)
                    .map<double>((value) => (value as num).toDouble())
                    .toList(),
              )
              .toList(),
        )
        .toList();

    return FoxPolygon(
      type: json['type'] as String? ?? '',
      coordinates: coordinates,
    );
  }

  /// Вычисление центра полигона
  LatLng getCenter() {
    if (points.isEmpty) return const LatLng(0, 0);

    final sum = points.reduce(
      (a, b) => LatLng(a.latitude + b.latitude, a.longitude + b.longitude),
    );
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
          result.add(
            LatLng(point[1], point[0]),
          ); // [lon, lat] → LatLng(lat, lon)
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

class Punishment {
  final String uuid;
  final String project;
  final DateTime punishDatetime;
  final int punishmentStatus;
  final String? customNumber;

  Punishment({
    required this.uuid,
    required this.project,
    required this.punishDatetime,
    required this.punishmentStatus,
    this.customNumber,
  });

  factory Punishment.fromJson(Map<String, dynamic> json) {
    return Punishment(
      uuid: json['uuid'],
      project: json['project'],
      punishDatetime: DateTime.parse(json['punish_datetime']),
      punishmentStatus: json['punishment_status'],
      customNumber: json['custom_number'],
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'project': project,
    'punish_datetime': punishDatetime.toIso8601String(),
    'punishment_status': punishmentStatus,
    'custom_number': customNumber,
  };
}

class ErrorMessage {
  final String message;

  ErrorMessage({required this.message});

  factory ErrorMessage.fromJson(Map<String, dynamic> json) {
    return ErrorMessage(
      message: json['message'] ?? 'Unknown error',
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
  };

  @override
  String toString() => message;
}

class PunishmentItem {
  final String uuid;
  final String title;
  final String punishment;
  final Bool is_suspend;
  final String place;
  final String? comment;
  final String? correction_date_info;
  final String? regulation_doc;
  final DateTime correction_date_plan;
  final DateTime punish_datetime;
  final DateTime? correction_date_fact;
  final String punish_item_status;

  PunishmentItem({
    required this.correction_date_plan,
    required this.is_suspend,
    required this.place,
    required this.punish_datetime,
    required this.punishment,
    required this.punish_item_status,
    required this.title,
    required this.uuid,
    this.comment,
    this.correction_date_fact,
    this.correction_date_info,
    this.regulation_doc
  });
}
