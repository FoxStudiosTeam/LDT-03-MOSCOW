import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/main.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

abstract class IAttachmentsProvider {
  Future<Attachment> attach_to_project(String uuid, File file);
  Future<Attachment> attach_to_punishment_item(String uuid, File file);
  Future<Attachment> attach_to_reports(String uuid, File file);
  Future<Attachment> attach_to_materials(String uuid, File file);
  Future<File> downloadFile(String id, String? filename);
}

const IAttachmentsProviderDIToken = "I-Attachments-Provider-DI-Token";

class AttachmentsProvider implements IAttachmentsProvider {
  final Uri apiRoot;
  final IAuthStorageProvider authStorageProvider;
  String? _accessToken;

  AttachmentsProvider({
    required this.apiRoot,
    required this.authStorageProvider,
  });

  @override
  Future<File> downloadFile(String id, String? filename) async {
    final uri = apiRoot.resolve('/api/attachmentproxy/file')
        .replace(queryParameters: {"id": id});
    _accessToken = await authStorageProvider.getAccessToken();

    final response = await http.get(
      uri,
      headers: {
        'Authorization' : 'Bearer $_accessToken',
      }
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;

      if (filename == null) {
        final contentDisposition = response.headers['Content-Disposition'];
        if (contentDisposition != null) {
          final regex = RegExp(r'filename="?(.+)"?');
          final match = regex.firstMatch(contentDisposition);
          if (match != null) {
            filename = match.group(1);
          }
        }
        filename ??= 'file';
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');

      await file.writeAsBytes(bytes);
      return file;
    } else {
      throw Exception('Failed to download file: ${response.statusCode}');
    }
  }

  @override
  Future<Attachment> attach_to_project(String uuid, File file) async {
    final uri = apiRoot.resolve('/api/attach/project')
        .replace(queryParameters: {"id": uuid});
    _accessToken = await authStorageProvider.getAccessToken();

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $_accessToken';
    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );
    final streamedResponse = await request.send().timeout(
        Duration(seconds: 20), onTimeout: () {
      throw TimeoutException(
          'Request timed out after ${Duration(seconds: 20)} ms');
    });
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final result = Attachment.fromJson(json);

      return result;
    } else {
      throw Exception(
          'Failed to fetch measurements: ${response.statusCode}');
    }
  }

  @override
  Future<Attachment> attach_to_materials(String uuid, File file) async {
    final uri = apiRoot.resolve('/api/attach/materials')
        .replace(queryParameters: {"id": uuid});
    _accessToken = await authStorageProvider.getAccessToken();

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $_accessToken';
    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );
    final streamedResponse = await request.send().timeout(
        Duration(seconds: 20), onTimeout: () {
      throw TimeoutException(
          'Request timed out after ${Duration(seconds: 20)} ms');
    });
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final result = Attachment.fromJson(json);

      return result;
    } else {
      throw Exception(
          'Failed to fetch measurements: ${response.statusCode}');
    }
  }

  @override
  Future<Attachment> attach_to_punishment_item(String uuid, File file) async {
    final uri = apiRoot.resolve('/api/attach/punishment_item')
        .replace(queryParameters: {"id": uuid});
    _accessToken = await authStorageProvider.getAccessToken();

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $_accessToken';
    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );
    final streamedResponse = await request.send().timeout(
        Duration(seconds: 20), onTimeout: () {
      throw TimeoutException(
          'Request timed out after ${Duration(seconds: 20)} ms');
    });
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final result = Attachment.fromJson(json);

      return result;
    } else {
      throw Exception(
          'Failed to fetch measurements: ${response.statusCode}');
    }
  }

  @override
  Future<Attachment> attach_to_reports(String uuid, File file) async {
    final uri = apiRoot.resolve('/api/attach/report')
        .replace(queryParameters: {"id": uuid});
    _accessToken = await authStorageProvider.getAccessToken();

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $_accessToken';
    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );
    final streamedResponse = await request.send().timeout(
        Duration(seconds: 20), onTimeout: () {
      throw TimeoutException(
          'Request timed out after ${Duration(seconds: 20)} ms');
    });
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final result = Attachment.fromJson(json);

      return result;
    } else {
      throw Exception(
          'Failed to fetch measurements: ${response.statusCode}');
    }
  }
}