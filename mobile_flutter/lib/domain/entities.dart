class Pagination {
  final int limit;
  final int offset;

  Pagination(this.limit, this.offset);

  Map<String, dynamic> toJson() => {
    'limit': limit,
    'offset': offset,
  };
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
    return PaginationResponseWrapper<T>(
      items: (json['items'] as List).map((elem) => fromJsonT(elem)).toList(),
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

ProjectStatus projectStatusFromString(String status) {
  return ProjectStatus.values.firstWhere(
        (e) => e.name == status,
    orElse: () => ProjectStatus.NEW,
  );
}

class Polygon {
  final String type;
  final List<List<List<double>>> coordinates;

  Polygon({
    required this.type,
    required this.coordinates,
  });

  factory Polygon.fromJson(Map<String, dynamic> json) {
    return Polygon(
      type: json['type'],
      coordinates: (json['coordinates'] as List)
          .map((l1) => (l1 as List)
          .map((l2) => (l2 as List).map((n) => (n as num).toDouble()).toList())
          .toList())
          .toList(),
    );
  }
}

class Project {
  final String address;
  final String created_by;
  final DateTime end_date;
  final String foreman;
  final Polygon polygon;
  final String ssk;
  final DateTime start_date;
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
    return Project(
      address: json['address'],
      created_by: json['created_by'],
      end_date: DateTime.parse(json['end_date']),
      foreman: json['foreman'],
      polygon: Polygon.fromJson(json['polygon']),
      ssk: json['ssk'],
      start_date: DateTime.parse(json['start_date']),
      status: projectStatusFromString(json['status']),
      uuid: json['uuid'],
    );
  }
}
