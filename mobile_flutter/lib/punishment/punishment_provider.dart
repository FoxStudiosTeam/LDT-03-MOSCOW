import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/main.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'dart:convert';

import 'package:mobile_flutter/punishment/punishment_storage_provider.dart';

import 'package:mobile_flutter/utils/network_utils.dart';

abstract class IPunishmentProvider {
  Future<Map<int, String>> get_statuses();
  Future<Map<String, String>> get_documents();
  Future<List<Punishment>> get_punishments(String project);
  Future<List<PunishmentItemAndAttachments>> get_punishment_items(String punishment);
}

const IPunishmentProviderDIToken = "I-Punishment-Provider-DI-Token";

class PunishmentProvider implements IPunishmentProvider {
  final Uri apiRoot;
  final IAuthStorageProvider authStorageProvider;
  String? _accessToken;

  PunishmentProvider({
    required this.apiRoot,
    required this.authStorageProvider
  });

  @override
  Future<Map<int, String>> get_statuses() async {
    final uri = apiRoot.resolve('/api/punishment/get_statuses');
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
          'Failed to fetch punishment statuses: ${response.statusCode}');
    }
  }

  @override
  Future<Map<String, String>> get_documents() async {
    final uri = apiRoot.resolve('/api/punishment/get_regulation_docs')
    .replace(queryParameters: null);
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
      if (jsonList.isEmpty) throw Exception('Regulation documents is empty');
      final Map<String, String> documents = {};

      for (var doc in jsonList) {
        documents[doc['uuid']] = doc['title'];
      };

      return documents;
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
    _accessToken = await authStorageProvider.getAccessToken();

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(Duration(seconds: 20),onTimeout: () {
      throw TimeoutException('Request timed out after ${Duration(seconds: 20)} ms');
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) return [];
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
    _accessToken = await authStorageProvider.getAccessToken();

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(Duration(seconds: 20),onTimeout: () {
      throw TimeoutException('Request timed out after ${Duration(seconds: 20)} ms');
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isEmpty) return [];
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

class OfflinePunishmentProvider implements IPunishmentProvider {
  final IPunishmentStorageProvider storageProvider;

  OfflinePunishmentProvider({required this.storageProvider});

  @override
  Future<Map<int, String>> get_statuses() async{
    var data = await storageProvider.getStatuses();
    return data;
  }

  @override
  Future<Map<String, String>> get_documents() async{
    var data = await storageProvider.getRegulationDocs();
    return data;
  }

  @override
  Future<List<Punishment>> get_punishments(String project) async{
    var data = await storageProvider.getPunishments(project);
    return data;
  }

  @override
  Future<List<PunishmentItemAndAttachments>> get_punishment_items(String punishment) async{
    var data = await storageProvider.getPunishmentItems(punishment);
    return data;
  }
}

class SmartPunishmentProvider implements IPunishmentProvider {
  final PunishmentProvider remote;
  final OfflinePunishmentProvider offline;
  final IPunishmentStorageProvider storage;

  SmartPunishmentProvider({
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
  Future<Map<String, String>> get_documents() async {
    final hasConnection = await NetworkUtils.connectionExists();
    print("Connection? $hasConnection");

    if (hasConnection) {
      final result = await remote.get_documents();

      await storage.saveDocuments(result);

      return result;
    } else {
      return offline.get_documents();
    }
  }

  @override
  Future<List<Punishment>> get_punishments(String project) async {
    final hasConnection = await NetworkUtils.connectionExists();
    print("Connection? $hasConnection");

    if (hasConnection) {
      final result = await remote.get_punishments(project);

      await storage.savePunishments(result);

      return result;
    } else {
      return offline.get_punishments(project);
    }
  }

  @override
  Future<List<PunishmentItemAndAttachments>> get_punishment_items(String punishment) async {
    final hasConnection = await NetworkUtils.connectionExists();
    print("Connection? $hasConnection");

    if (hasConnection) {
      final result = await remote.get_punishment_items(punishment);

      await storage.savePunishmentItems(result);

      return result;
    } else {
      return offline.get_punishment_items(punishment);
    }
  }

  Future<UuidResponse?> create_punishment(PunishmentCreateRequest punishment) async {
    final hasConnection = await NetworkUtils.connectionExists();
    print("Connection? $hasConnection");

    if (hasConnection) {
      final uri = remote.apiRoot.resolve('/api/punishment/create_punishment');
      final _accessToken = await remote.authStorageProvider.getAccessToken();

      final response = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(punishment.toJson())
      ).timeout(Duration(seconds: 20), onTimeout: () {
        throw TimeoutException(
            'Request timed out after ${Duration(seconds: 20)} ms');
      });

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return UuidResponse.fromJson(json);
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
    else {
      //TODO оффлайн функции
    }
  }

  Future<UuidResponse?> create_punishment_item(PunishmentItemCreateRequest punishment_item) async {
    final hasConnection = await NetworkUtils.connectionExists();
    print("Connection? $hasConnection");

    if (hasConnection) {
      final uri = remote.apiRoot.resolve(
          '/api/punishment/create_punishment_item');
      final _accessToken = await remote.authStorageProvider.getAccessToken();

      final response = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(punishment_item.toJson())
      ).timeout(Duration(seconds: 20), onTimeout: () {
        throw TimeoutException(
            'Request timed out after ${Duration(seconds: 20)} ms');
      });

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return UuidResponse.fromJson(json);
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
    else {
      //TODO оффлайн функции
    }
  }

  Future<UuidResponse?> update_punishment(PunishmentUpdRequest punishment) async {
    final hasConnection = await NetworkUtils.connectionExists();
    print("Connection? $hasConnection");

    if (hasConnection) {
      final uri = remote.apiRoot.resolve('/api/punishment/update_punishment');
      final _accessToken = await remote.authStorageProvider.getAccessToken();

      final response = await http.put(
          uri,
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(punishment.toJson())
      ).timeout(Duration(seconds: 20), onTimeout: () {
        throw TimeoutException(
            'Request timed out after ${Duration(seconds: 20)} ms');
      });

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return UuidResponse.fromJson(json);
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
    else {
      //TODO оффлайн функции
    }
  }

  Future<UuidResponse?> update_punishment_item(PunishmentItemUpdRequest punishment_item) async {
    final hasConnection = await NetworkUtils.connectionExists();
    print("Connection? $hasConnection");

    if (hasConnection) {
      final uri = remote.apiRoot.resolve(
          '/api/punishment/update_punishment_item');
      final _accessToken = await remote.authStorageProvider.getAccessToken();

      final response = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(punishment_item.toJson())
      ).timeout(Duration(seconds: 20), onTimeout: () {
        throw TimeoutException(
            'Request timed out after ${Duration(seconds: 20)} ms');
      });

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return UuidResponse.fromJson(json);
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
    else {
      //TODO оффлайн функции
    }
  }
}