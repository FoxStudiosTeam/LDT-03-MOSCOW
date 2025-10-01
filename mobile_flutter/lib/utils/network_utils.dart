import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/auth/auth_provider.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/main.dart';
import 'package:mobile_flutter/screens/auth_screen.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  punishment_item
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

class QueuedRequestModel {
  final int timestamp;
  final String url;
  final String method;
  final Map<String, dynamic> body;
  final Map<String, String> headers;

  final List<AttachmentModel> attachments;

  QueuedRequestModel({
    required this.timestamp, // DateTime.now().millisecondsSinceEpoch
    required this.url,
    required this.method,
    required this.body,
    required this.headers,
    this.attachments = const [],
  });

  QueuedRequestModel createNew(
    String url,
    String method,
    Map<String, dynamic> body,
    Map<String, String> headers,
  ) {
    return QueuedRequestModel(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      url: url,
      method: method,
      body: body,
      headers: headers,
    );
  }


  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "url": url,
        "method": method,
        "body": body,
        "headers": headers,
        "attachments": attachments.map((a) => a.toJson()).toList(),
      };

  static QueuedRequestModel fromJson(Map<String, dynamic> json) =>
      QueuedRequestModel(
        timestamp: json["timestamp"],
        url: json["url"],
        method: json["method"],
        body: Map<String, dynamic>.from(json["body"]),
        headers: Map<String, String>.from(json["headers"]),
        attachments: (json["attachments"] as List)
            .map((a) => AttachmentModel.fromJson(Map<String, dynamic>.from(a)))
            .toList(),
      );

  Future<bool> execute(accessToken) async {
    if (attachments.isEmpty) {
      final request = http.Request(method, Uri.parse(url));
      request.headers.addAll({
        "Content-Type": "application/json",
        ...headers,
      });
      request.headers["Authorization"] = "Bearer $accessToken";
      request.body = jsonEncode(body);

      return (await http.Response.fromStream(await request.send())).statusCode == 200;
    } else {
      final request = http.Request(method, Uri.parse(url));
      request.headers.addAll({
        "Content-Type": "application/json",
        ...headers,
      });
      request.headers["Authorization"] = "Bearer $accessToken";
      request.body = jsonEncode(body);
      var v = await http.Response.fromStream(await request.send());
      var decoded = jsonDecode(v.body);
      var original = decoded["uuid"];
      if (original == null) {
        log("Error uploading attachment: [${v.statusCode}] ${v.body}");
        return false;
      }

      final base = Uri.parse(APIRootURI);
      
      for (final attachment in attachments) {
        final attachmentUri = base.resolve('/api/attach/${attachment.type.toString()}').replace(queryParameters: {"id": original});
        final attachmentRequest = http.MultipartRequest('POST', attachmentUri);
        attachmentRequest.headers['Authorization'] = 'Bearer $accessToken';
        attachmentRequest.files.add(
          await http.MultipartFile.fromPath('file', attachment.path),
        );
        var resp = await http.Response.fromStream(await attachmentRequest.send());
        if (resp.statusCode != 200) {
          log("Error uploading attachment: [${resp.statusCode}] ${resp.body}");
        } else {
          log("Attachment uploaded");
        }
      }
      return true;
    }
  }
}


abstract class IQueuedRequests {
  Future<bool> queuedSend(QueuedRequestModel request, String token);
  void init(IAuthStorageProvider provider);
}

const IQueuedRequestsDIToken = "IQueuedRequestsDIToken";

class QueuedRequests implements IQueuedRequests {
  final List<QueuedRequestModel> _queuedRequests = [];
  Timer? _flushTimer;

  static const _storageKey = "queued_requests";
  late final IAuthStorageProvider _provider;

  QueuedRequests();

  @override
  Future<void> init(provider) async {
    _provider = provider;
    _queuedRequests.clear();

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_storageKey) ?? [];
    _queuedRequests.addAll(
      stored.map((e) => QueuedRequestModel.fromJson(jsonDecode(e))),
    );

    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) async => await _tryFlush(),
    );
  }

  @override
  Future<bool> queuedSend(QueuedRequestModel request, String token) async {
    if (!await NetworkUtils.connectionExists()) {
      _queuedRequests.add(request);
      await _saveToDisk();
      return true;
    }
    return await _executeWithHandling(request, token);
  }

  Future<void> _tryFlush() async {
    if (_queuedRequests.isEmpty) return;
    if (!await NetworkUtils.connectionExists()) return;
    // wait 10s to ensure token was got
    await Future.delayed(const Duration(seconds: 10));
    if (!await NetworkUtils.connectionExists()) return;

    final token = await _provider.getAccessToken();

    final copy = List<QueuedRequestModel>.from(_queuedRequests);
    for (final req in copy) {
      final ok = await _executeWithHandling(req, "");
      if (ok) {
        _queuedRequests.remove(req);
        await _saveToDisk();
      } else {
        break;
      }
    }
  }

  Future<bool> _executeWithHandling(QueuedRequestModel request, String token) async {
      return await request.execute(token);
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _queuedRequests.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, list);
  }

  void dispose() {
    _flushTimer?.cancel();
  }
}
