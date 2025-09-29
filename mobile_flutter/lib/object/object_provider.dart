import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/main.dart';

abstract class IObjectsProvider {
  Future<PaginationResponseWrapper<Project>> getObjects(String address, int offset);
}

class ObjectsProvider implements IObjectsProvider {
  final IDependencyContainer di;

  ObjectsProvider({required this.di});

  @override
  Future<PaginationResponseWrapper<Project>> getObjects(String address, int offset) async {
    final uri = di.getDependency<Uri>(IAPIRootURI).resolve('/api/get-project');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
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
      throw Exception('Failed to load projects. Status code: ${response.statusCode}');
    }
  }
}
