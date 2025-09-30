import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/object/object_storage_provider.dart';
import 'package:mobile_flutter/utils/network_utils.dart';

abstract class IObjectsProvider {
  Future<PaginationResponseWrapper<Project>> getObjects(String address, int offset);
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
    _accessToken ??= await authStorageProvider.getAccessToken();

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
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return PaginationResponseWrapper<Project>.fromJson(
        json,
            (item) => Project.fromJson(item),
      );
    } else {
      if (response.statusCode == 401){
          throw Exception('Unauthorized');
      }
      throw Exception('Failed to load projects');
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
}
