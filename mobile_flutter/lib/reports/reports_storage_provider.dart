import 'dart:convert';
import 'dart:ffi';

import 'package:mobile_flutter/domain/entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IReportsStorageProvider {
  Future<void> saveStatuses(Map<int, String> statuses);
  Future<void> saveReports(List<ReportAndAttachments> reports);
  Future<List<ReportAndAttachments>> getReports(String project);
  Future<Map<int, String>> getStatuses();
  Future<void> clear_statuses();
}

const IReportsStorageProviderDIToken = "I-Reports-Storage-Provider-DI-Token";

class ReportsStorageProvider implements IReportsStorageProvider {
  static const STATUSES_KEY = "statuses-key";
  static const REPORTS_KEY = "reports-key";

  SharedPreferences? prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> clear_statuses() async {
    if (prefs == null) {
      await init();
    }
    await prefs?.remove(STATUSES_KEY);
  }

  @override
  Future<void> saveStatuses(Map<int, String> statuses) async {
    await init();

    final mapToStore = {
      for (var entry in statuses.entries) entry.key.toString(): entry.value
    };

    await prefs?.setString(STATUSES_KEY, jsonEncode(mapToStore));
  }

  @override
  Future<void> saveReports(List<ReportAndAttachments> reports) async {
    final existing = await getReports(reports.first.report.project);


    final combined = {
      for (var p in [...existing, ...reports]) p.report.uuid: p
    }.values.toList();

    final encoded = jsonEncode(combined.map((e) => e.toJson()).toList());
    await prefs?.setString(REPORTS_KEY, encoded);
  }

  @override
  Future<List<ReportAndAttachments>> getReports(String project) async {
    if (prefs == null) {
      await init();
    }

    var rawData = prefs?.getString(REPORTS_KEY);

    if (rawData != null) {
      final List<dynamic> jsonList = jsonDecode(rawData);

      final reports = jsonList
          .map((e) => ReportAndAttachments.fromJson(e as Map<String, dynamic>, project))
          .where((p) => p.report.project == project).toList();

      return reports;
    } else {
      return [];
    }
  }

  @override
  Future<Map<int, String>> getStatuses() async {
    if (prefs == null) {
      await init();
    }
    final json = prefs?.getString(STATUSES_KEY);
    if (json == null || json.isEmpty) {
      return {};
    }

    final Map<String, dynamic> json_decoded = jsonDecode(json);
    final Map<int, String> statuses = {};

    json_decoded.forEach((key, value) {
      final id = int.tryParse(key);
      if (id != null && value is String) {
        statuses[id] = value;
      }
    });

    return statuses;
  }
}