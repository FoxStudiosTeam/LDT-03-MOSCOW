import 'dart:convert';
import 'dart:ffi';

import 'package:mobile_flutter/domain/entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IPunishmentStorageProvider {
  Future<void> saveStatuses(Map<int, String> statuses);
  Future<void> saveDocuments(Map<String, String> documents);
  Future<void> savePunishments(List<Punishment> punishments);
  Future<void> savePunishmentItems(List<PunishmentItemAndAttachments> punishmentItems);
  Future<List<Punishment>> getPunishments(String project);
  Future<List<PunishmentItemAndAttachments>> getPunishmentItems(String punishment);
  Future<Map<int, String>> getStatuses();
  Future<Map<String, String>> getRegulationDocs();
  Future<void> clear_statuses();
  Future<void> clear_docs();
}

const IPunishmentStorageProviderDIToken = "I-Punishment-Storage-Provider-DI-Token";

class PunishmentStorageProvider implements IPunishmentStorageProvider {
  static const STATUSES_KEY = "punishment-statuses-key";
  static const DOCUMENTS_KEY = "punishment-documents-key";
  static const PUNISHMENTS_KEY = "punishments-key";
  static const PUNISHMENT_ITEMS_KEY = "punishment-items-key";

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
  Future<void> clear_docs() async {
    if (prefs == null) {
      await init();
    }
    await prefs?.remove(DOCUMENTS_KEY);
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

    await prefs?.setString(DOCUMENTS_KEY, jsonEncode(documents));
  }

  @override
  Future<void> savePunishments(List<Punishment> punishments) async {
    if (punishments.isEmpty) {
      await prefs?.setString(PUNISHMENTS_KEY, jsonEncode([]));
      return;
    }
    final existing = await getPunishments(punishments.first.project);


    final combined = {
      for (var p in [...existing, ...punishments]) p.uuid: p
    }.values.toList();

    final encoded = jsonEncode(combined.map((e) => e.toJson()).toList());
    await prefs?.setString(PUNISHMENTS_KEY, encoded);
  }

  @override
  Future<void> savePunishmentItems(List<PunishmentItemAndAttachments> punishmentItems) async {
    if (punishmentItems.isEmpty) {
      await prefs?.setString(PUNISHMENT_ITEMS_KEY, jsonEncode([]));
      return;
    }
    final existing = await getPunishmentItems(punishmentItems.first.punishment_item.punishment);

    final combined = {
      for (var p in [...existing, ...punishmentItems]) p.punishment_item.uuid: p
    }.values.toList();

    final encoded = jsonEncode(combined.map((e) => e.toJson()).toList());
    await prefs?.setString(PUNISHMENT_ITEMS_KEY, encoded);
  }

  @override
  Future<List<Punishment>> getPunishments(String project) async {
    if (prefs == null) {
      await init();
    }

    var rawData = prefs?.getString(PUNISHMENTS_KEY);

    if (rawData != null) {
      final List<dynamic> jsonList = jsonDecode(rawData);

      final punishments = jsonList
          .map((e) => Punishment.fromJson(e as Map<String, dynamic>))
          .where((p) => p.project == project).toList();

      return punishments;
    } else {
      return [];
    }
  }

  @override
  Future<List<PunishmentItemAndAttachments>> getPunishmentItems(String punishment) async {
    if (prefs == null) {
      await init();
    }

    var rawData = prefs?.getString(PUNISHMENT_ITEMS_KEY);

    if (rawData != null) {
      final List<dynamic> jsonList = jsonDecode(rawData);

      final punishmentItems = jsonList
          .map((e) => PunishmentItemAndAttachments.fromJson(e as Map<String, dynamic>))
          .where((p) => p.punishment_item.punishment == punishment).toList();

      return punishmentItems;
    } else {
      return [];
    }
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
    final Map<String, dynamic> jsonDynamic = jsonDecode(json);

    final Map<String, String> documents = jsonDynamic.map((key, value) => MapEntry(key, value.toString()));

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