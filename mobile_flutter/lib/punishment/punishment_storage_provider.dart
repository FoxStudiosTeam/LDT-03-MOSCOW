import 'dart:convert';
import 'dart:ffi';

import 'package:mobile_flutter/domain/entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IPunishmentStorageProvider {
  Future<void> saveStatuses(Map<int, String> statuses);
  Future<void> saveDocuments(Map<String, String> documents);
  Future<Map<int, String>> getStatuses();
  Future<Map<String, String>> getRegulationDocs();
  Future<void> clear();
}

const IPunishmentStorageProviderDIToken = "I-Punishment-Storage-Provider-DI-Token";

class PunishmentStorageProvider implements IPunishmentStorageProvider {
  static const STATUSES_KEY = "punishment-statuses-key";
  static const DOCUMENTS_KEY = "punishment-documents-key";

  SharedPreferences? prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> clear() async {
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
  Future<void> saveDocuments(Map<String, String> documents) async {
    await init();

    await prefs?.setString(STATUSES_KEY, jsonEncode(documents));
  }

  @override
  Future<Map<String, String>> getRegulationDocs() async {
    if (prefs == null) {
      await init();
    }
    final json = prefs?.getString(DOCUMENTS_KEY);
    if (json == null || json.isEmpty) {
      return {};
    }

    final Map<String, String> documents = jsonDecode(json);

    return documents;
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