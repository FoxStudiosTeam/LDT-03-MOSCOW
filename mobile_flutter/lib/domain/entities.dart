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
      "Статус: ${toReadableString()}",
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
  final dynamic coordinates; // оставляем dynamic, потому что структура разная
  final List<LatLng> points;

  FoxPolygon({
    required this.type,
    required this.coordinates,
  }) : points = _extractPoints(type, coordinates);

  factory FoxPolygon.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';

    final coordinates = json['coordinates'];

    if (type == 'Polygon' || type == 'MultiPolygon') {
      return FoxPolygon(type: type, coordinates: coordinates);
    } else {
      throw FormatException("Unsupported geometry type: $type");
    }
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'coordinates': coordinates};
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  LatLng getCenter() {
    if (points.isEmpty) return const LatLng(0, 0);

    final sum = points.reduce(
          (a, b) => LatLng(a.latitude + b.latitude, a.longitude + b.longitude),
    );

    return LatLng(sum.latitude / points.length, sum.longitude / points.length);
  }

  static List<LatLng> _extractPoints(String type, dynamic coords) {
    final List<LatLng> result = [];

    bool isValidPoint(dynamic point) =>
        point is List && point.length >= 2 && point[0] is num && point[1] is num;

    if (type == 'Polygon') {
      for (final ring in coords as List) {
        if (ring is List) {
          for (final point in ring) {
            if (isValidPoint(point)) {
              result.add(LatLng(point[1].toDouble(), point[0].toDouble()));
            }
          }
        }
      }
    } else if (type == 'MultiPolygon') {
      for (final polygon in coords as List) {
        if (polygon is List) {
          for (final ring in polygon) {
            if (ring is List) {
              for (final point in ring) {
                if (isValidPoint(point)) {
                  result.add(LatLng(point[1].toDouble(), point[0].toDouble()));
                }
              }
            }
          }
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

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'created_by': created_by,
      'end_date': end_date?.toIso8601String(),
      'foreman': foreman,
      'polygon': polygon != null ? polygon!.toJsonString() : null,
      'ssk': ssk,
      'start_date': start_date?.toIso8601String(),
      'status': status.index,
      'uuid': uuid,
    };
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
      punishmentStatus: json['punishment_status'] as int,
      customNumber: json['custom_number'] as String?,
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
    return ErrorMessage(message: json['message'] ?? 'Unknown error');
  }

  Map<String, dynamic> toJson() => {'message': message};

  @override
  String toString() => message;
}

class PunishmentItem {
  final String uuid;
  final String title;
  final String punishment;
  final bool is_suspend;
  final String place;
  final String? comment;
  final String? correction_date_info;
  final String? regulation_doc;
  final DateTime correction_date_plan;
  final DateTime punish_datetime;
  final DateTime? correction_date_fact;
  final int punish_item_status;

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
    this.regulation_doc,
  });

  factory PunishmentItem.fromJson(Map<String, dynamic> json) {
    return PunishmentItem(
      uuid: json['uuid'],
      title: json['title'],
      punishment: json['punishment'],
      is_suspend: json['is_suspend'] as bool,
      place: json['place'],
      comment: json['comment'] as String?,
      correction_date_info: json['correction_date_info'] as String?,
      regulation_doc: json['regulation_doc'] as String?,
      correction_date_plan: DateTime.parse(json['correction_date_plan']),
      correction_date_fact: json['correction_date_fact'] != null
          ? DateTime.parse(json['correction_date_fact'])
          : null,
      punish_datetime: DateTime.parse(json['punish_datetime']),
      punish_item_status: json['punishment_item_status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'title': title,
    'punishment': punishment,
    'punishment_item_status': punish_item_status,
    'correction_date_plan': correction_date_plan
        .toIso8601String()
        .split("T")
        .first,
    'is_suspend': is_suspend,
    'place': place,
    'punish_datetime': punish_datetime.toIso8601String(),
    'comment': comment,
    'correction_date_fact': correction_date_fact
        ?.toIso8601String()
        .split("T")
        .first,
    'correction_date_info': correction_date_info,
    'regulation_doc': regulation_doc,
  };
}

class Attachment {
  final String uuid;
  final String baseEntityUuid;
  final String originalFilename;
  final String? contentType;

  Attachment({
    required this.uuid,
    required this.baseEntityUuid,
    required this.originalFilename,
    this.contentType,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      uuid: json['uuid'] as String,
      baseEntityUuid: json['base_entity_uuid'] as String,
      originalFilename: json['original_filename'] as String,
      contentType: json['content_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'base_entity_uuid': baseEntityUuid,
      'original_filename': originalFilename,
      'content_type': contentType,
    };
  }
}

class PunishmentItemAndAttachments {
  final PunishmentItem punishment_item;
  final List<Attachment> attachments;

  PunishmentItemAndAttachments({
    required this.punishment_item,
    required this.attachments,
  });

  factory PunishmentItemAndAttachments.fromJson(Map<String, dynamic> json) {
    return PunishmentItemAndAttachments(
      punishment_item: PunishmentItem.fromJson(
        json['punishment_item'] as Map<String, dynamic>,
      ),
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((a) => Attachment.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "punishment_item": punishment_item.toJson(),
      "attachments" : attachments.map((e) => e.toJson()).toList()
    };
  }
}

enum Role {
  INSPECTOR,
  FOREMAN,
  CUSTOMER,
  ADMIN,
  UNKNOWN
}

Role roleFromString(String? role) {
  switch (role) {
    case 'inspector':
      return Role.INSPECTOR;
    case 'customer':
      return Role.CUSTOMER;
    case 'foreman':
      return Role.FOREMAN;
    case 'nOBEJlNTEJlb MNPA':
      return Role.ADMIN;
    default: return Role.UNKNOWN;
  }
}

class Materials {
  final DateTime createdAt;
  final int measurement;
  final bool onResearch;
  final String project;
  final String title;
  final String uuid;
  final double volume;
  final DateTime deliveryDate;

  Materials({
    required this.title,
    required this.volume,
    required this.deliveryDate,
    required this.createdAt,
    required this.project,
    required this.uuid,
    required this.measurement,
    required this.onResearch
  });

  factory Materials.fromJson(Map<String, dynamic> json) {
    return Materials(
        title: json['title'],
        volume: json['volume'] as double,
        deliveryDate: DateTime.parse(json['delivery_date']),
        createdAt: DateTime.parse(json['created_at']),
        project: json['project'],
        uuid: json['uuid'],
        measurement: json['measurement'] as int,
        onResearch: json['on_research'] as bool
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'volume': volume,
      'delivery_date': deliveryDate.toIso8601String()
      .split('T').first,
      'created_at' : createdAt.toIso8601String(),
      'project': project,
      'uuid': uuid,
      'measurement': measurement,
      'on_research': onResearch
    };
  }
}

class MaterialsAndAttachments {
  final Materials material;
  final List<Attachment> attachments;

  MaterialsAndAttachments({
    required this.material,
    required this.attachments
  });

  factory MaterialsAndAttachments.fromJson(Map<String, dynamic> json) {
    return MaterialsAndAttachments(
      material: Materials.fromJson(
        json['material'] as Map<String, dynamic>,
      ),
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((a) => Attachment.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "material": material.toJson(),
      "attachments" : attachments.map((e) => e.toJson()).toList()
    };
  }
}

class Report {
  final DateTime? checkDate;
  final int status;
  final String projectScheduleItem;
  final String title;
  final String uuid;
  final DateTime reportDate;
  final String project;

  Report({
    required this.title,
    required this.reportDate,
    required this.checkDate,
    required this.projectScheduleItem,
    required this.status,
    required this.uuid,
    required this.project,
  });

  factory Report.fromJson(Map<String, dynamic> json, String project) {
    return Report(
      checkDate: json['check_date'] != null
          ? DateTime.parse(json['check_date'])
          : null,
      status: json['status'] as int,
      projectScheduleItem: json['project_schedule_item'],
      title: json['title'],
      uuid: json['uuid'],
      reportDate: DateTime.parse(json['report_date']),
      project: project
    );
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'check_date': checkDate,
      'status': status,
      'check_date': checkDate?.toIso8601String()
          .split('T').first,
      'report_date' : reportDate.toIso8601String()
          .split('T').first,
      'project_schedule_item': projectScheduleItem,
      'uuid': uuid,
      'title': title,
      'project': project,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'check_date': checkDate,
      'status': status,
      'check_date': checkDate?.toIso8601String()
        .split('T').first,
      'report_date' : reportDate.toIso8601String()
        .split('T').first,
      'project_schedule_item': projectScheduleItem,
      'uuid': uuid,
      'title': title
    };
  }
}

class ReportAndAttachments {
  final Report report;
  final List<Attachment> attachments;

  ReportAndAttachments({
    required this.report,
    required this.attachments
  });

  factory ReportAndAttachments.fromJson(Map<String, dynamic> json, String project) {
    return ReportAndAttachments(
      report: Report.fromJson(
        json['report'] as Map<String, dynamic>, project
      ),
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((a) => Attachment.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "report": report.toJson(),
      "attachments" : attachments.map((e) => e.toJson()).toList()
    };
  }

  Map<String, dynamic> toStorageJson() {
    return {
      "report": report.toStorageJson(),
      "attachments" : attachments.map((e) => e.toJson()).toList()
    };
  }
}