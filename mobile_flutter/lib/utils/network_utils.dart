import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter/auth/auth_provider.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/screens/auth_screen.dart';
class NetworkUtils {
  static Future<T> wrapRequest<T>(
      Future<T> Function() func,
      BuildContext context,
      IDependencyContainer di
      ) async {
    try {
      return await func();
    } on HttpException catch (e) {
      if (e.message == '401') {
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
