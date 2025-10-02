import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/main.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'dart:convert';

import 'package:mobile_flutter/reports/reports_storage_provider.dart';
import 'package:mobile_flutter/screens/create_report_screen.dart';

import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:uuid/uuid.dart';

import 'package:mobile_flutter/screens/ocr/ttn.dart';

abstract class IReportsProvider {
  Future<Map<int, String>> get_statuses();
  Future<List<ReportAndAttachments>> get_reports(String project);
}

const IReportsProviderDIToken = "I-Reports-Provider-DI-Token";

class ReportsProvider implements IReportsProvider {
  final Uri apiRoot;
  final IAuthStorageProvider authStorageProvider;
  String? _accessToken;

  ReportsProvider({
    required this.apiRoot,
    required this.authStorageProvider,
  });

  @override
  Future<Map<int, String>> get_statuses() async {
    final uri = apiRoot.resolve('/api/report/get_statuses');
    _accessToken = await authStorageProvider.getAccessToken();

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_accessToken',
      },
    ).timeout(Duration(seconds: 20),onTimeout: () {
      throw TimeoutException('Request timed out after ${Duration(seconds: 20)} ms');
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) throw Exception('Statuses is empty');
      final Map<int, String> statuses = {};

      for (var status in jsonList) {
        statuses[status['id']] = status['title'];
      };

      return statuses;
    } else {
      throw Exception(
          'Failed to fetch measurements: ${response.statusCode}');
    }
  }

  @override
  Future<List<ReportAndAttachments>> get_reports(String project) async {
    final uri = apiRoot.resolve('/api/report/get_reports_by_uuid')
    .replace(queryParameters: {"project_uuid":project});
    _accessToken = await authStorageProvider.getAccessToken();

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_accessToken',
      },
    ).timeout(Duration(seconds: 20),onTimeout: () {
      throw TimeoutException('Request timed out after ${Duration(seconds: 20)} ms');
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) return [];

      final repAatt = jsonList.map((json) => ReportAndAttachments.fromJson(json, project)).toList();
      return repAatt;
    } else {
      try {
        final Map<String, dynamic> errorJson = jsonDecode(response.body);
        final error = ErrorMessage.fromJson(errorJson);
        throw Exception("Error ${response.statusCode}: ${error.message}");
      } catch (e) {
        throw Exception("Error ${response.statusCode}: ${response.body}");
      }
    }
  }
}

class OfflineReportsProvider implements IReportsProvider {
  final IReportsStorageProvider storageProvider;

  OfflineReportsProvider({required this.storageProvider});

  @override
  Future<Map<int, String>> get_statuses() async{
    var data = await storageProvider.getStatuses();
    return data;
  }

  @override
  Future<List<ReportAndAttachments>> get_reports(String project) async{
    var data = await storageProvider.getReports(project);
    return data;
  }
}

class SmartReportsProvider implements IReportsProvider {
  final ReportsProvider remote;
  final OfflineReportsProvider offline;
  final IReportsStorageProvider storage;

  SmartReportsProvider({
    required this.remote,
    required this.offline,
    required this.storage,
  });

  @override
  Future<Map<int, String>> get_statuses() async {
    final hasConnection = await NetworkUtils.connectionExists();
    print("Connection? $hasConnection");

    if (hasConnection) {
      final result = await remote.get_statuses();

      await storage.saveStatuses(result);

      return result;
    } else {
      return offline.get_statuses();
    }
  }

  @override
  Future<List<ReportAndAttachments>> get_reports(String project) async {
    final hasConnection = await NetworkUtils.connectionExists();
    print("Connection? $hasConnection");

    if (hasConnection) {
      final result = await remote.get_reports(project);

      await storage.saveReports(result);

      return result;
    } else {
      return offline.get_reports(project);
    }
  }
}

QueuedRequestModel queuedReport(ReportRecord record, String address) {
  final now = DateTime.now();

  final attachments = record.attachments.map((file) {
    return AttachmentModel(
      type: AttachmentVariant.reports,
      path: file.path!,
    );
  }).toList();

  return QueuedRequestModel(
    id: Uuid().v4(),
    timestamp: now.millisecondsSinceEpoch,
    title: "Отчет по ${record.title} для $address",
    url: Uri.parse(APIRootURI).resolve('/api/report/create_report').toString(),
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: {
      "project_schedule_item": record.projectScheduleItem,
      "report_date": now.toIso8601String().split("T").first,
      "status": record.status,
      "check_date": null,
    },
    attachments: attachments,
  );
}


QueuedRequestModel queuedReportChangeStatus(String id, String title, int status) {
  final now = DateTime.now();
  return QueuedRequestModel(
    id: Uuid().v4(),
    timestamp: now.millisecondsSinceEpoch,
    title: title,
    url: Uri.parse(APIRootURI).resolve('/api/report/upd_report').toString(),
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: {
      "uuid" : id,
      "status": status
    },
  );
}