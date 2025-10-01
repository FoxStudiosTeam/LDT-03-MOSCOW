import 'dart:convert';
import 'dart:ffi';

import 'package:mobile_flutter/domain/entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IMaterialsStorageProvider {
  Future<void> saveMeasurements(Map<int, String> statuses);
  Future<void> saveMaterials(List<MaterialsAndAttachments> materials);
  Future<List<MaterialsAndAttachments>> getMaterials(String project);
  Future<Map<int, String>> getMeasurements();
  Future<void> clear_measurements();
}

const IMaterialsStorageProviderDIToken = "I-Materials-Storage-Provider-DI-Token";

class MaterialsStorageProvider implements IMaterialsStorageProvider {
  static const MEASUREMENTS_KEY = "measurements-key";
  static const MATERIALS_KEY = "materials-key";

  SharedPreferences? prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> clear_measurements() async {
    if (prefs == null) {
      await init();
    }
    await prefs?.remove(MEASUREMENTS_KEY);
  }

  @override
  Future<void> saveMeasurements(Map<int, String> statuses) async {
    await init();

    final mapToStore = {
      for (var entry in statuses.entries) entry.key.toString(): entry.value
    };

    await prefs?.setString(MEASUREMENTS_KEY, jsonEncode(mapToStore));
  }

  @override
  Future<void> saveMaterials(List<MaterialsAndAttachments> materials) async {
    final existing = await getMaterials(materials.first.material.project);


    final combined = {
      for (var p in [...existing, ...materials]) p.material.uuid: p
    }.values.toList();

    final encoded = jsonEncode(combined.map((e) => e.toJson()).toList());
    await prefs?.setString(MATERIALS_KEY, encoded);
  }

  @override
  Future<List<MaterialsAndAttachments>> getMaterials(String project) async {
    if (prefs == null) {
      await init();
    }

    var rawData = prefs?.getString(MATERIALS_KEY);

    if (rawData != null) {
      final List<dynamic> jsonList = jsonDecode(rawData);

      final materials = jsonList
          .map((e) => MaterialsAndAttachments.fromJson(e as Map<String, dynamic>))
          .where((p) => p.material.project == project).toList();

      return materials;
    } else {
      return [];
    }
  }

  @override
  Future<Map<int, String>> getMeasurements() async {
    if (prefs == null) {
      await init();
    }
    final json = prefs?.getString(MEASUREMENTS_KEY);
    if (json == null || json.isEmpty) {
      return {};
    }

    final Map<String, dynamic> json_decoded = jsonDecode(json);
    final Map<int, String> measutements = {};

    json_decoded.forEach((key, value) {
      final id = int.tryParse(key);
      if (id != null && value is String) {
        measutements[id] = value;
      }
    });

    return measutements;
  }
}