import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/main.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'dart:convert';

import 'package:mobile_flutter/punishment/punishment_storage_provider.dart';

abstract class IPunishmentProvider {
  Future<Map<int, String>> get_statuses();
  Future<List<Punishment>> get_punishments(String project);
  Future<List<PunishmentItemAndAttachments>> get_punishment_items(String punishment);
}

const IPunishmentProviderDIToken = "I-Punishment-Provider-DI-Token";

class PunishmentProvider implements IPunishmentProvider {
  final Uri apiRoot;
  final IAuthStorageProvider authStorageProvider;
  final IPunishmentStorageProvider storageProvider;
  String? _accessToken;

  PunishmentProvider({
    required this.apiRoot,
    required this.authStorageProvider,
    required this.storageProvider
  });

  @override
  Future<Map<int, String>> get_statuses() async {
    final uri = apiRoot.resolve('/api/punishment/get_statuses');
    _accessToken ??= await authStorageProvider.getAccessToken();

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_accessToken',
      },
    ).timeout(Duration(seconds: 5),onTimeout: () {
      throw TimeoutException('Request timed out after ${Duration(seconds: 20)} ms');
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) throw Exception('Statuses is empty');
      final Map<int, String> statuses = {};

      for (var status in jsonList) {
        statuses[status['id']] = status['title'];
      };
      await storageProvider.saveStatuses(statuses);

      return statuses;
    } else {
      throw Exception(
          'Failed to fetch punishment statuses: ${response.statusCode}');
    }
  }

  @override
  Future<List<Punishment>> get_punishments(String project) async {
    final uri = apiRoot.resolve('/api/punishment/get_punishments').replace(
      queryParameters: {'project': project},
    );
    _accessToken ??= await authStorageProvider.getAccessToken();

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(Duration(seconds: 5),onTimeout: () {
      throw TimeoutException('Request timed out after ${Duration(seconds: 20)} ms');
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) throw Exception('No punishments in project');
      return jsonList.map((json) => Punishment.fromJson(json)).toList();
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

  @override
  Future<List<PunishmentItemAndAttachments>> get_punishment_items(String punishment) async {
    final uri = apiRoot.resolve('/api/punishment/get_punishment_items').replace(
      queryParameters: {'punishment_id': punishment},
    );
    _accessToken ??= await authStorageProvider.getAccessToken();

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(Duration(seconds: 5),onTimeout: () {
      throw TimeoutException('Request timed out after ${Duration(seconds: 20)} ms');
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) throw Exception('No punishments in project');
      return jsonList.map((json) => PunishmentItemAndAttachments.fromJson(json)).toList();
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