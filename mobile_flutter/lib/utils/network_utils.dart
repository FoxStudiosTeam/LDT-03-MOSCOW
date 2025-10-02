import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mobile_flutter/auth/auth_provider.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/main.dart';
import 'package:mobile_flutter/materials/materials_provider.dart';
import 'package:mobile_flutter/screens/auth_screen.dart';
import 'package:mobile_flutter/screens/ocr/ttn.dart';
import 'package:mobile_flutter/utils/file_utils.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/src/media_type.dart';
import 'package:uuid/uuid.dart';

class NetworkUtils {
  static Future<T> wrapRequest<T>(
      Future<T> Function() func,
      BuildContext context,
      IDependencyContainer di
      ) async {
    try {
      return await func();
    } on HttpException catch (e) {
      if (e.message.contains('401')) {
        var authStorageProvider = di.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken);
        final refreshed = await di.getDependency<IAuthProvider>(IAuthProviderDIToken).refreshToken(await authStorageProvider.getRefreshToken(), Duration(seconds: 2));
        if (refreshed.accessTokenValue != "") {
          return await func();
        } else {
          await authStorageProvider.clear();
          Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => AuthScreen(di: di)),
                (_) => false,
          );
          throw Exception('Unauthorized and refresh failed');
        }
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> connectionExists() async {
    try {
      final result = await InternetAddress.lookup('ya.ru');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

enum AttachmentVariant {
  project,
  materials,
  reports,
  punishment_item;
  
  String asPathPart() {
    switch (this) {
      case AttachmentVariant.project:
        return "project";
      case AttachmentVariant.materials:
        return "materials";
      case AttachmentVariant.reports:
        return "reports";
      case AttachmentVariant.punishment_item:
        return "punishment_item";
    }
  }
}
class QueuedChildModel {
  String body_key;
  String parent_key;
  QueuedRequestModel model;

  QueuedChildModel({
    required this.body_key,
    this.parent_key = "uuid",
    required this.model,
  });

  Map<String, dynamic> toJson() => {
        "body_key": body_key,
        "parent_key": parent_key,
        "model": model.toJson(),
      };

  static QueuedChildModel fromJson(Map<String, dynamic> json) => QueuedChildModel(
        body_key: json["body_key"],
        parent_key: json["parent_key"],
        model: QueuedRequestModel.fromJson(
          Map<String, dynamic>.from(json["model"]),
        ),
      );
}



class AttachmentModel {
  final AttachmentVariant type;
  String path;

  AttachmentModel({required this.type, required this.path});

  Map<String, dynamic> toJson() => {
        "type": type.toString(),
        "path": path,
      };

  static AttachmentModel fromJson(Map<String, dynamic> json) => AttachmentModel(
        type: AttachmentVariant.values.firstWhere(
          (e) => e.toString() == json["type"],
        ),
        path: json["path"],
      );
}


class QueuedResponse {
  bool isDelayed;
  bool isOk;
  Response? response;
  QueuedResponse({ required this.isDelayed, required this.isOk, this.response});

  SyncedQueuedStatus toSyncedStatus() => SyncedQueuedStatus(
    DateTime.now().millisecondsSinceEpoch, 
    response?.statusCode, 
    tryDecode(response?.body ?? "{}") ?? {}, 
    isOk
  );
}


dynamic tryDecode(String source) {
  try {
    return jsonDecode(source);
  } catch (e) {
    return null; // или {} / [] если хочешь дефолт
  }
}


class QueuedRequestModel {
  String id;
  int timestamp;
  final String title;
  final String url;
  final String method;
  final Map<String, dynamic> body;
  final Map<String, String> headers;
  final String? attachmentOriginOverride;

  final List<AttachmentModel> attachments;
  final List<QueuedChildModel> children;

  QueuedRequestModel({
    required this.title,
    required this.timestamp,
    required this.url,
    required this.method,
    required this.body,
    required this.headers,
    required this.id,
    this.attachmentOriginOverride,
    this.attachments = const [],
    this.children = const [],
  });

  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "url": url,
        "method": method,
        "id": id,
        "body": body,
        "headers": headers,
        "attachments": attachments.map((a) => a.toJson()).toList(),
        "attachmentOriginOverride": attachmentOriginOverride,
        "title": title,
        "children": children.map((c) => c.toJson()).toList(),
      };

  static QueuedRequestModel fromJson(Map<String, dynamic> json) =>
      QueuedRequestModel(
        timestamp: json["timestamp"],
        title: json["title"],
        attachmentOriginOverride: json["attachmentOriginOverride"],
        url: json["url"],
        id: json["id"],
        method: json["method"],
        body: Map<String, dynamic>.from(json["body"]),
        headers: Map<String, String>.from(json["headers"]),
        children: (json["children"] as List)
            .map((c) =>
                QueuedChildModel.fromJson(Map<String, dynamic>.from(c)))
            .toList(),
        attachments: (json["attachments"] as List)
            .map((a) => AttachmentModel.fromJson(Map<String, dynamic>.from(a)))
            .toList(),
      );

  Future<QueuedResponse> execute(accessToken) async {
    if (attachments.isEmpty) {
      final request = http.Request(method, Uri.parse(url));
      request.headers.addAll({
        "Content-Type": "application/json",
        ...headers,
      });
      log("[OFFLINE QUEUE] Headers ser!");
      request.headers["Authorization"] = "Bearer $accessToken";
      request.body = jsonEncode(body);
      log("[OFFLINE QUEUE] Encoded!");
      var resp = await http.Response.fromStream(await request.send());
      log("[OFFLINE QUEUE] Body: ${resp.body}!");
      log("[OFFLINE QUEUE] Resp: ${resp.statusCode}!");
      return QueuedResponse(isDelayed: false, isOk: resp.statusCode == 200, response: resp);
    } else {
      var maybeOrigin = attachmentOriginOverride;
      var parent_body = null;
      if (attachmentOriginOverride == null && children.isEmpty) {
        final request = http.Request(method, Uri.parse(url));
        request.headers.addAll({
          "Content-Type": "application/json",
          ...headers,
        });
        request.headers["Authorization"] = "Bearer $accessToken";
        request.body = jsonEncode(body);
        var v = await http.Response.fromStream(await request.send());
        var decoded = tryDecode(v.body);
        if (decoded == null) {
          log("[OFFLINE QUEUE] Error uploading attachment origin: [${v.statusCode}] ${v.body}");
          return QueuedResponse(isDelayed: false, isOk: false, response: v);
        }
        var original = decoded["uuid"] as String?;
        if (original == null) {
          log("[OFFLINE QUEUE] Error uploading attachment origin: [${v.statusCode}] ${v.body}");
          return QueuedResponse(isDelayed: false, isOk: false, response: v);
        }
        if (attachmentOriginOverride == null) maybeOrigin = original;
        parent_body = v;
      }
      var origin = maybeOrigin!;
      

      final base = Uri.parse(APIRootURI);
      var ok = true;
      for (final attachment in attachments) {
        final attachmentBase = origin;
        final attachmentUri = base.resolve('/api/attach/${attachment.type.asPathPart()}').replace(queryParameters: {"id": attachmentBase });
        final mimeType = lookupMimeType(attachment.path) ?? 'application/octet-stream';
        final parts = mimeType.split('/');
        log("[OFFLINE QUEUE] Uploading attachment ${attachment.path} to ${attachmentUri}");
        final attachmentRequest = http.MultipartRequest('POST', attachmentUri);
        attachmentRequest.headers['Authorization'] = 'Bearer $accessToken';
        attachmentRequest.headers['Content-Type'] = 'multipart/form-data';
        attachmentRequest.files.add(
          await http.MultipartFile.fromPath('file', attachment.path, contentType: MediaType(parts[0], parts[1])),
        );
        var resp = await http.Response.fromStream(await attachmentRequest.send());
        if (resp.statusCode != 200) {
          log("[OFFLINE QUEUE] Error uploading attachment: [${resp.statusCode}] ${resp.body}");
          ok = false;
        } else {
          log("[OFFLINE QUEUE] Attachment ${attachment.path} uploaded");
        }
      }

      for (final child in children) {
        if (!parent_body) {
          log("[OFFLINE QUEUE] Error uploading attachment origin: [${parent_body?.statusCode}] ${parent_body?.body}");
          continue;
        }
        var ex = child.model;
        ex.body[child.body_key] = parent_body[child.parent_key];
        final resp = await ex.execute(accessToken);
        if (!resp.isOk) {
          ok = false;
        }
      }
      return QueuedResponse(isDelayed: false, isOk: ok);
    }
  }
  
  QueuedStatus toHistory() {
    return QueuedStatus(timestamp, title, id, null);
  }
}

class SyncedQueuedStatus {
  final int syncAt;
  final int? statusCode;
  final Map<String, dynamic>? body; 
  final bool isOk;

  SyncedQueuedStatus(this.syncAt, this.statusCode, this.body, this.isOk);

  Map<String, dynamic> toJson() => {
        'syncAt': syncAt,
        'isOk': isOk,
        'statusCode': statusCode,
        'body': body,
      };

  factory SyncedQueuedStatus.fromJson(Map<String, dynamic> json) {
    return SyncedQueuedStatus(
      json['syncAt'],
      json['statusCode'],
      json['body'],
      json['isOk'] ?? false,
    );
  }
}

class QueuedStatus {
  final int sentAt;
  final String title;
  final String uuid;
  SyncedQueuedStatus? syncedStatus;

  QueuedStatus(this.sentAt, this.title, this.uuid, this.syncedStatus);

  Map<String, dynamic> toJson() => {
        'sentAt': sentAt,
        'title': title,
        'uuid': uuid,
        'syncedStatus': syncedStatus?.toJson(),
      };

  factory QueuedStatus.fromJson(Map<String, dynamic> json) {
    return QueuedStatus(
      json['sentAt'],
      json['title'],
      json['uuid'],
      json['syncedStatus'] != null
          ? SyncedQueuedStatus.fromJson(json['syncedStatus'])
          : null,
    );
  }
}


abstract class IQueuedRequests {
  Future<QueuedResponse> queuedSend(QueuedRequestModel request, String token);
  void init(IAuthStorageProvider provider);
  List<QueuedStatus> getHistory();
  String dbg();
}

const IQueuedRequestsDIToken = "IQueuedRequestsDIToken";

class QueuedRequests implements IQueuedRequests {
  final Map<String, QueuedRequestModel> _queuedRequests = {};
  final Map<String, QueuedStatus> _history= {};
  Timer? _flushTimer;

  static const _storageKey = "queued_requests";
  static const _historyKey = "queued_requests_history";
  late final IAuthStorageProvider _provider;
  String _a = "";
  String _b = "";

  @override
  String dbg() => "\n$_a\n$_b";

  QueuedRequests();

  @override
  Future<void> init(provider) async {
    _provider = provider;
    _queuedRequests.clear();
    _history.clear();
  

    final prefs = await SharedPreferences.getInstance();
    final storedRequestsJson = prefs.getString(_storageKey);
    log("[OFFLINE QUEUE] Stored requests: $storedRequestsJson");
    if (storedRequestsJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(storedRequestsJson);
      _queuedRequests.clear();
      decoded.forEach((key, value) {
        _queuedRequests[key] = QueuedRequestModel.fromJson(jsonDecode(value));
      });
    }
    log("[OFFLINE QUEUE] Got ${_queuedRequests.length} queued requests");
    final storedHistoryJson = prefs.getString(_historyKey);
    log("[OFFLINE QUEUE] Stored history: $storedHistoryJson");
    if (storedHistoryJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(storedHistoryJson);
      _history.clear();
      decoded.forEach((key, value) {
        _history[key] = QueuedStatus.fromJson(jsonDecode(value));
      });
    }
    log("[OFFLINE QUEUE] GOT ${_history.length} queued history requests");
    _a = storedHistoryJson ?? "";
    _b = storedRequestsJson ?? "";

    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(
      //todo!: 10 SECS
      const Duration(seconds: 1),
      (_) async => await _tryFlush(),
    );
  }

  @override
  Future<QueuedResponse> queuedSend(QueuedRequestModel request, String token) async {
    log("[OFFLINE QUEUE] Trying to send queued request");
    if (!await NetworkUtils.connectionExists()) {
      for (var f in request.attachments) {
        var newPath = await savePathToCache(f.path);
        f.path = newPath;
      }


      log("[OFFLINE QUEUE] No connection");
      _history[request.id] = request.toHistory();
      _queuedRequests[request.id] = request;
      await _saveToDisk();
      return QueuedResponse(isDelayed: true, isOk: true, response: null);
    }
    log("[OFFLINE QUEUE] Sending");
    return await _executeWithHandling(request, token);
  }

  Future<void> _tryFlush() async {
    if (_queuedRequests.isEmpty) return;
    if (!await NetworkUtils.connectionExists()) return;
    // wait 10s to ensure token was got
    //todo!: 10 SECS
    await Future.delayed(const Duration(seconds: 1));
    if (!await NetworkUtils.connectionExists()) return;

    final token = await _provider.getAccessToken();

    log("[OFFLINE QUEUE] Starting flush");
    final copy = Map<String, QueuedRequestModel>.from(_queuedRequests);
    for (final req in copy.values) {
      log("[OFFLINE QUEUE] [FLUSH] Processing ${req.method} ${req.url}");
      final r = await _executeWithHandling(req, token);

      var record = _history[req.id] ?? req.toHistory();

      record.syncedStatus = r.toSyncedStatus();
      _history[req.id] = record;

      if (r.isOk) {
        log("[OFFLINE QUEUE] [FLUSH] Success");
        _queuedRequests.remove(req.id);
      } else if (r.isDelayed) {
        log("[OFFLINE QUEUE] [FLUSH] Delayed");
      } else if (r.response != null) {
        log("[OFFLINE QUEUE] [FLUSH] [${r.response!.statusCode}] ${r.response!.body}");
        final code = r.response!.statusCode;
        if (code >= 400 && code < 500) {
          log("[OFFLINE QUEUE] [FLUSH] Dropping request due to client error $code");
          _queuedRequests.remove(req.id);
        } else if (code >= 500) {
          log("[OFFLINE QUEUE] [FLUSH] Server error $code, will retry later");
        }
      } else {
        log("[OFFLINE QUEUE] [FLUSH] Failed");
        break;
      }
      await _saveToDisk();
      await _saveHistoryToDisk();
    }
  }

  Future<QueuedResponse> _executeWithHandling(QueuedRequestModel request, String token) async {
      return await request.execute(token);
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final mapToSave = _queuedRequests.map(
      (key, value) => MapEntry(key, jsonEncode(value.toJson())),
    );
    await prefs.setString(_storageKey, jsonEncode(mapToSave));
  }

  Future<void> _saveHistoryToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final mapToSave = _history.map(
      (key, value) => MapEntry(key, jsonEncode(value.toJson())),
    );
    await prefs.setString(_historyKey, jsonEncode(mapToSave));
  }

  void dispose() {
    _flushTimer?.cancel();
  }

  @override
  List<QueuedStatus> getHistory() {
    return _history.values.toList();
  }
}
