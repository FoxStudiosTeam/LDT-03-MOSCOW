import 'dart:async';
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/main.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'dart:convert';

import 'package:mobile_flutter/materials/materials_storage_provider.dart';
import 'package:mobile_flutter/screens/ocr/ttn.dart';

import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:uuid/uuid.dart';

abstract class IMaterialsProvider {
  Future<Map<int, String>> get_measurements();
  Future<List<MaterialsAndAttachments>> get_materials(String project);
}

const IMaterialsProviderDIToken = "I-Materials-Provider-DI-Token";

class MaterialsProvider implements IMaterialsProvider {
  final Uri apiRoot;
  final IAuthStorageProvider authStorageProvider;
  String? _accessToken;

  MaterialsProvider({
    required this.apiRoot,
    required this.authStorageProvider,
  });

  @override
  Future<Map<int, String>> get_measurements() async {
    final uri = apiRoot.resolve('/api/project/get-measurements');
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
      if (jsonList.isEmpty) throw Exception('Measurements is empty');
      final Map<int, String> measurements = {};

      for (var status in jsonList) {
        measurements[status['id']] = status['title'];
      };

      return measurements;
    } else {
      throw Exception(
          'Failed to fetch measurements: ${response.statusCode}');
    }
  }

  @override
  Future<List<MaterialsAndAttachments>> get_materials(String project) async {
    final uri = apiRoot.resolve('/api/materials/by_project/$project');
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
      log("Before decode: ${response.body}");
      final List<dynamic> jsonList = jsonDecode(response.body);
      log("After decode: $jsonList");
      if (jsonList.isEmpty) return [];
      log("Materials: $jsonList");
      final matAatt = jsonList.map((json) => MaterialsAndAttachments.fromJson(json)).toList();
      return matAatt;
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

class OfflineMaterialsProvider implements IMaterialsProvider {
  final IMaterialsStorageProvider storageProvider;

  OfflineMaterialsProvider({required this.storageProvider});

  @override
  Future<Map<int, String>> get_measurements() async{
    var data = await storageProvider.getMeasurements();
    return data;
  }

  @override
  Future<List<MaterialsAndAttachments>> get_materials(String project) async{
    var data = await storageProvider.getMaterials(project);
    return data;
  }
}

class SmartMaterialsProvider implements IMaterialsProvider {
  final MaterialsProvider remote;
  final OfflineMaterialsProvider offline;
  final IMaterialsStorageProvider storage;

  SmartMaterialsProvider({
    required this.remote,
    required this.offline,
    required this.storage,
  });

  @override
  Future<Map<int, String>> get_measurements() async {
    final hasConnection = await NetworkUtils.connectionExists();
    print("Connection? $hasConnection");

    if (hasConnection) {
      final result = await remote.get_measurements();

      await storage.saveMeasurements(result);

      return result;
    } else {
      return offline.get_measurements();
    }
  }

  @override
  Future<List<MaterialsAndAttachments>> get_materials(String project) async {
    final hasConnection = await NetworkUtils.connectionExists();
    print("Connection? $hasConnection");

    if (hasConnection) {
      final result = await remote.get_materials(project);

      await storage.saveMaterials(result);

      return result;
    } else {
      return offline.get_materials(project);
    }
  }
}


QueuedRequestModel queuedMaterial(TTNRecord record) {
  final now = DateTime.now();
  final deliveryDate = now.toIso8601String().split('T').first;

  final attachments = record.attachments.map((file) {
    return AttachmentModel(
      type: AttachmentVariant.materials,
      path: file.path!,
    );
  }).toList();

  return QueuedRequestModel(
    id: Uuid().v4(),
    timestamp: now.millisecondsSinceEpoch,
    title: record.name,
    url: Uri.parse(APIRootURI).resolve('/api/material').toString(),
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: {
      "delivery_date": deliveryDate,
      "measurement": record.unit,
      "project": record.projectId,
      "title": record.name,
      "volume": record.number,
    },
    attachments: attachments,
  );
}