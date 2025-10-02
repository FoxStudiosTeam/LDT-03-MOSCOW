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
import 'package:mobile_flutter/screens/auth_screen.dart';
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
      log("YA 4MOOOO ${e.toString()}");
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


const INetworkProviderDIToken = "I-Network-Provider-Provider-DI-Token";


abstract class INetworkProvider {
  Future<bool> connectionExists();
  ValueNotifier<bool> get connectionNotifier;

  Future<T> lazySend<T>(Future<T> Function() request);

  void begin();
  void dispose();
}

// class NetworkProvider extends INetworkProvider {
//   var _updating = false;
//   @override
//   Future<bool> connectionExists() async => NetworkUtils.connectionExists();

//   @override

//   @override
//   ValueNotifier<bool> connectionNotifier = ValueNotifier<bool>(false);

//   @override
//   void begin() {
//     if (_updating) return;
//     _updating = true;
//     connectionNotifier.value = false;
//     connectionNotifier.addListener(() => connectionNotifier.value = false);
//     Connectivity().onConnectivityChanged.listen(
//       (event) => connectionNotifier.value = event != ConnectivityResult.none
//     );
//   }

//   @override
//   void dispose() => connectionNotifier.dispose();
// }


class NetworkProvider implements INetworkProvider {
  final Queue<_QueuedRequest> _requestQueue = Queue();
  bool _updating = false;
  StreamSubscription? _subscription;
  final ValueNotifier<bool> _connectionNotifier = ValueNotifier<bool>(false);

  @override
  ValueNotifier<bool> get connectionNotifier => _connectionNotifier;

  @override
  Future<bool> connectionExists() async {
    try {
      final result = await InternetAddress.lookup("example.com");
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  @override
  void begin() {
    if (_updating) return;
    _updating = true;

    _subscription = Connectivity().onConnectivityChanged.listen((event) async {
      final online = await NetworkUtils.connectionExists();
      connectionNotifier.value = online;
      if (online) {
        _flushQueue();
      }
    });

    connectionExists().then((exists) => connectionNotifier.value = exists);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    connectionNotifier.dispose();
  }

  @override
  Future<T> lazySend<T>(Future<T> Function() request) async {
    if (connectionNotifier.value) {
      return await request();
    } else {
      final completer = Completer<T>();
      _requestQueue.add(_QueuedRequest<T>(request, completer));
      return completer.future;
    }
  }

  void _flushQueue() async {
    while (_requestQueue.isNotEmpty && connectionNotifier.value) {
      final queued = _requestQueue.removeFirst();
      try {
        final result = await queued.request();
        queued.completer.complete(result);
      } catch (e, st) {
        queued.completer.completeError(e, st);
      }
    }
  }
}

class _QueuedRequest<T> {
  final Future<T> Function() request;
  final Completer<T> completer;

  _QueuedRequest(this.request, this.completer);
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

class AttachmentModel {
  final AttachmentVariant type;
  final String path;

  AttachmentModel({required this.type, required this.path});

    Map<String, dynamic> toJson() => {
        "type": type.toString(),
        "path": path,
      };

  static AttachmentModel fromJson(Map<String, dynamic> json) =>
      AttachmentModel(
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
    jsonDecode(response?.body ?? "{}"), 
    isOk
  );
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
  });
  

  void now() {
    timestamp = DateTime.now().millisecondsSinceEpoch;
  }

  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "url": url,
        "method": method,
        "id": id,
        "body": body,
        "headers": headers,
        "attachments": attachments.map((a) => a.toJson()).toList(),
        "attachmentOriginOverride": attachmentOriginOverride,
        "title": title
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
      request.headers["Authorization"] = "Bearer $accessToken";
      request.body = jsonEncode(body);
      var resp = await http.Response.fromStream(await request.send());
      return QueuedResponse(isDelayed: false, isOk: resp.statusCode == 200, response: resp);
    } else {
      var maybeOrigin = attachmentOriginOverride;
      if (attachmentOriginOverride == null) {
        final request = http.Request(method, Uri.parse(url));
        request.headers.addAll({
          "Content-Type": "application/json",
          ...headers,
        });
        request.headers["Authorization"] = "Bearer $accessToken";
        request.body = jsonEncode(body);
        var v = await http.Response.fromStream(await request.send());
        var decoded = jsonDecode(v.body);
        var original = decoded["uuid"] as String?;
        if (original == null) {
          log("[OFFLINE QUEUE] Error uploading attachment origin: [${v.statusCode}] ${v.body}");
          return QueuedResponse(isDelayed: false, isOk: false, response: v);
        }
        maybeOrigin = original;
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
