import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/main.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'dart:convert';

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

      final repAatt = jsonList.map((json) => ReportAndAttachments.fromJson(json)).toList();
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