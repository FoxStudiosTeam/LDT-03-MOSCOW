import 'dart:io';

import 'package:mobile_flutter/auth/auth_errors.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';

import 'auth_entities.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// IAuthProvider - authorization provider
abstract class IAuthProvider {
  Future<AccessTokenData> login(String login, String password, Duration timeOut);
  Future<AccessTokenData> refreshToken(String refreshToken, Duration timeOut);
}

const IAuthProviderDIToken = "I-Auth-Provider-DI-Token";

// AuthProvider - default implementation of IAuthProvider
class AuthProvider implements IAuthProvider {
  late final Uri apiRoot;
  late final IAuthStorageProvider authStorageProvider;

  AuthProvider(this.apiRoot, this.authStorageProvider);

  @override
  Future<AccessTokenData> login(String login, String password, Duration timeOut) async{
    var data = AccessTokenData("", 0);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final response = await http.post(
      this.apiRoot.resolve('/api/auth/session'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'login': login,
        'password': password
      }),
    ).timeout(timeOut, onTimeout: () {
      throw TimeOutError('Request timed out after $timeOut ms');
    });

    if (response.statusCode == 200) {
      final rawData = jsonDecode(response.body);
      data.accessTokenValue = rawData['access_token'] ?? "";
      data.ext = rawData['exp'] ?? 0;

      final parts = data.accessTokenValue.split('.');
      if (parts.length != 3) {
        throw Exception('invalid token');
      }

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final role = jsonDecode(payload)['role'];

      await authStorageProvider.saveRole(role);

      var refresh = parseHeaders(response.headers);
      if (refresh != null) {
        await authStorageProvider.saveRefreshToken(refresh.refreshTokenValue, refresh.ext, now);
      }

      await authStorageProvider.saveAccessToken(data.accessTokenValue, data.ext);
    } else {
      throw AuthError("Some Error while logging ${response.statusCode}");
    }

    return data;
  }

  RefreshTokenData? parseHeaders(Map<String, String> headers) {
    if (headers.isEmpty) return null;

    String? cookieHeader = headers[HttpHeaders.setCookieHeader];
    if (cookieHeader == null) return null;

    final parts = cookieHeader.split(';');
    String? refreshToken;
    int? maxAge;

    for (var part in parts) {
      final trimmedPart = part.trim();

      if (trimmedPart.startsWith('REFRESH_TOKEN=')) {
        refreshToken = trimmedPart.replaceFirst('REFRESH_TOKEN=', '');
      } else if (trimmedPart.startsWith('Max-Age=')) {
        final value = trimmedPart.replaceFirst('Max-Age=', '');
        maxAge = int.tryParse(value);
      }
    }

    if (refreshToken != null && maxAge != null) {
      return RefreshTokenData(refreshToken, maxAge, 0);
    }

    return null;
  }

  @override
  Future<AccessTokenData> refreshToken(String refreshToken, Duration timeOut) async {
    var data = AccessTokenData("", 0);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final response = await http.get(
      this.apiRoot.resolve('/api/auth/refresh'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.setCookieHeader: 'refresh=$refreshToken'
      },
    ).timeout(timeOut, onTimeout: () {
      throw TimeOutError('Request timed out after $timeOut ms');
    });

    if (response.statusCode == 200) {
      final rawData = jsonDecode(response.body);
      data.accessTokenValue = rawData['access_token'] ?? "";
      data.ext = rawData['exp'] ?? 0;

      final parts = data.accessTokenValue.split('.');
      if (parts.length != 3) {
        throw Exception('invalid token');
      }

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final role = jsonDecode(payload)['role'];

      await authStorageProvider.saveRole(role);

      var refresh = parseHeaders(response.headers);
      if (refresh != null) {
        await authStorageProvider.saveRefreshToken(refresh.refreshTokenValue, refresh.ext, now);
      }

      await authStorageProvider.saveAccessToken(data.accessTokenValue, data.ext);
    } else {
      throw AuthError("Some Error while logging ${response.statusCode}");
    }

    return data;
  }

}