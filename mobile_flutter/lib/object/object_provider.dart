import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/object/object_storage_provider.dart';
import 'package:mobile_flutter/utils/network_utils.dart';

abstract class IObjectsProvider {
  Future<PaginationResponseWrapper<Project>> getObjects(String address, int offset);
  Future<List<InspectorInfo>> getObjectInspectors(String project_uuid);
}

const IObjectsProviderDIToken = "IObjectsProvider";

class ObjectsProvider implements IObjectsProvider {
  final Uri apiRoot;
  final IAuthStorageProvider authStorageProvider;
  String? _accessToken;

  ObjectsProvider({required this.apiRoot, required this.authStorageProvider});

  Future<void> init() async {
    _accessToken = await authStorageProvider.getAccessToken();
  }

  @override
  Future<PaginationResponseWrapper<Project>> getObjects(String address, int offset) async {
    _accessToken = await authStorageProvider.getAccessToken();

    final uri = apiRoot.resolve('/api/project/get-project');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_accessToken',
      },
      body: jsonEncode({
        'address': address,
        'pagination': Pagination(10, offset).toJson(),
      }),
    ).timeout(Duration(seconds: 20), onTimeout: () {
      throw TimeoutException('Request timed out after ${Duration(seconds: 20)} ms');
    });

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PaginationResponseWrapper<Project>.fromJson(
        json,
            (item) => Project.fromJson(item),
      );
    } else {
      if (response.statusCode == 401){
          throw HttpException('Unauthorized 401');
      }
      throw HttpException('Failed to load projects');
    }
  }

  @override
  Future<List<InspectorInfo>> getObjectInspectors(String projectUuid) async {
    final uri = apiRoot.resolve('/api/project/get-project_inspectors')
    .replace(queryParameters: {'project_uuid':projectUuid});
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
      final List<dynamic> jsonList = jsonDecode(response.body)['inspectors'];

      final inspectors = jsonList.map((e) => InspectorInfo.fromJson(e, projectUuid)).toList();

      return inspectors;
    } else {
      throw Exception(
          'Failed to fetch measurements: ${response.statusCode}');
    }
  }
}

class OfflineObjectsProvider implements IObjectsProvider {
  final IObjectStorageProvider objectStorageProvider;

  OfflineObjectsProvider({required this.objectStorageProvider});

  @override
  Future<PaginationResponseWrapper<Project>> getObjects(String address, int offset) async{
    var data = await objectStorageProvider.getObjects();
    return PaginationResponseWrapper(items: data, total: data.length);
  }

  @override
  Future<List<InspectorInfo>> getObjectInspectors(String projectUuid) async {
    var data = await objectStorageProvider.getObjectInspectors(projectUuid);
    return data;
  }
}

class SmartObjectsProvider implements IObjectsProvider {
  final ObjectsProvider remote;
  final OfflineObjectsProvider offline;
  final IObjectStorageProvider storage;

  SmartObjectsProvider({
    required this.remote,
    required this.offline,
    required this.storage,
  });

  @override
  Future<PaginationResponseWrapper<Project>> getObjects(String address, int offset) async {
    final hasConnection = await NetworkUtils.connectionExists();
    print("Connection? $hasConnection");

    if (hasConnection) {
      final result = await remote.getObjects(address, offset);

      if (offset == 0) {
        await storage.saveObjects(result.items);
      }

      return result;
    } else {
      return offline.getObjects(address, offset);
    }
  }

  @override
  Future<List<InspectorInfo>> getObjectInspectors(String projectUuid) async {
    final hasConnection = await NetworkUtils.connectionExists();
    print("Connection? $hasConnection");

    if (hasConnection) {
      final result = await remote.getObjectInspectors(projectUuid);

      return result;
    } else {
      return offline.getObjectInspectors(projectUuid);
    }
  }

  Future<Project?> activate_object(String project_uuid) async {
    final hasConnection = await NetworkUtils.connectionExists();
    print("Connection? $hasConnection");

    if (hasConnection) {
      final _accessToken = await remote.authStorageProvider.getAccessToken();

      final uri = remote.apiRoot.resolve('/api/project/activate-project');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({'project_uuid': project_uuid}),
      ).timeout(Duration(seconds: 20), onTimeout: () {
        throw TimeoutException(
            'Request timed out after ${Duration(seconds: 20)} ms');
      });

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Project.fromJson(json);
      } else {
        if (response.statusCode == 401) {
          throw HttpException('Unauthorized 401');
        }
        throw HttpException('Failed to activate object');
      }
    } else {
      // TODO оффлайн функции
    }
  }
}
