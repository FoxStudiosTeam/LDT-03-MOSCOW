import 'package:flutter/material.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/auth/auth_provider.dart';
import 'package:mobile_flutter/di/dependency_builder.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/screens/auth_screen.dart';
import 'package:mobile_flutter/screens/objects_screen.dart';

import 'object/object_provider.dart';

const IAPIRootURI = "I-API-Root-URI";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var builder = DependencyBuilder();
  builder.registerDependency(IAuthStorageProviderDIToken, AuthStorageProvider());
  builder.registerDependency(IAPIRootURI, Uri.parse("https://test.foxstudios.ru:32460/api"));

  builder.registerDependency(IObjectsProviderDIToken, ObjectsProvider(apiRoot: builder.getDependency<Uri>(IAPIRootURI), authStorageProvider: builder.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken)));

  var storage = builder.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken);
  var au = AuthProvider(Uri.parse('https://sso.foxstudios.ru:32460'), storage);
  builder.registerDependency(IAuthProviderDIToken, au);
  var di = builder.build();

  runApp(MaterialApp(home: MainPage(di: di)));
}

class MainPage extends StatelessWidget {
  final IDependencyContainer di;

  const MainPage({super.key, required this.di});

  Future<Widget> prepareChild() async {
    var storageProvider = di.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken);
    if (await storageProvider.getRefreshToken() != "") {
      return ObjectsScreen(di: di);
    }
    return AuthScreen(di:di);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Widget>(
        future: prepareChild(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else {
            return snapshot.data ?? const SizedBox.shrink();
          }
        },
      ),
    );
  }
}