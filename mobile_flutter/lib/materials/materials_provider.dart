import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/main.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'dart:convert';

abstract class IMaterialsProvider {
  Future<Map<int, String>> get_measurments();
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
  Future<Map<int, String>> get_measurments() async {
    final uri = apiRoot.resolve('/api/project/get-measurements');
    _accessToken ??= await authStorageProvider.getAccessToken();

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
    _accessToken ??= await authStorageProvider.getAccessToken();

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

      if (jsonList.isEmpty) return [];

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