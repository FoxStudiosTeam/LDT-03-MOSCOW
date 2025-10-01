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
  ValueNotifier<bool> connectionNotifier = ValueNotifier<bool>(false);

  /// Add request to queue, if no internet → waits until net is restored
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