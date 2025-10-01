import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/auth/auth_provider.dart';
import 'package:mobile_flutter/di/dependency_builder.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/materials/materials_provider.dart';
import 'package:mobile_flutter/materials/materials_storage_provider.dart';
import 'package:mobile_flutter/object/object_storage_provider.dart';
import 'package:mobile_flutter/punishment/punishment_provider.dart';
import 'package:mobile_flutter/punishment/punishment_storage_provider.dart';
import 'package:mobile_flutter/reports/reports_provider.dart';
import 'package:mobile_flutter/reports/reports_storage_provider.dart';
import 'package:mobile_flutter/screens/auth_screen.dart';
import 'package:mobile_flutter/screens/objects_screen.dart';
import 'package:mobile_flutter/screens/punishments_screen.dart';
import 'package:mobile_flutter/utils/geo_utils.dart';

import 'object/object_provider.dart';

const IAPIRootURI = "I-API-Root-URI";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  var builder = DependencyBuilder();
  builder.registerDependency(IAuthStorageProviderDIToken, AuthStorageProvider());
  builder.registerDependency(IAPIRootURI, Uri.parse("https://test.foxstudios.ru:32460"));

  builder.registerDependency(ILocationProviderDIToken, LocationProvider());

  // Object provider

  var onlineObjectProvider = ObjectsProvider(
      apiRoot: builder.getDependency<Uri>(IAPIRootURI),
      authStorageProvider: builder.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken)
  );

  var objectStorageProvider = ObjectStorageProvider();

  var offlineObjectProvider = OfflineObjectsProvider(objectStorageProvider: objectStorageProvider);

  builder.registerDependency(IObjectsProviderDIToken, SmartObjectsProvider(remote: onlineObjectProvider, offline: offlineObjectProvider, storage: objectStorageProvider));

  // Punishment provider

  var onlinePunishmentProvider = PunishmentProvider(
      apiRoot: builder.getDependency<Uri>(IAPIRootURI),
      authStorageProvider: builder.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken)
  );

  var punishmentStorageProvider = PunishmentStorageProvider();

  var offlinePunishmentProvider = OfflinePunishmentProvider(storageProvider: punishmentStorageProvider);

  builder.registerDependency(IPunishmentProviderDIToken, SmartPunishmentProvider(
      remote: onlinePunishmentProvider,
      offline: offlinePunishmentProvider,
      storage: punishmentStorageProvider)
  );

  // Material provider

  var onlineMaterialsProvider = MaterialsProvider(
      apiRoot: builder.getDependency<Uri>(IAPIRootURI),
      authStorageProvider: builder.getDependency<AuthStorageProvider>(IAuthStorageProviderDIToken)
  );

  var materialsStorageProvider = MaterialsStorageProvider();

  var offlineMaterialsProvider = OfflineMaterialsProvider(storageProvider: materialsStorageProvider);

  builder.registerDependency(IMaterialsProviderDIToken, SmartMaterialsProvider(
    offline: offlineMaterialsProvider,
    remote: onlineMaterialsProvider,
    storage: materialsStorageProvider
  ));

  // Report provider

  var onlineReportsProvider = ReportsProvider(
      apiRoot: builder.getDependency<Uri>(IAPIRootURI),
      authStorageProvider: builder.getDependency<AuthStorageProvider>(IAuthStorageProviderDIToken)
  );

  var reportsStorageProvider = ReportsStorageProvider();

  var offlineReportsProvider = OfflineReportsProvider(storageProvider: reportsStorageProvider);

  builder.registerDependency(IReportsProviderDIToken, SmartReportsProvider(
      offline: offlineReportsProvider,
      remote: onlineReportsProvider,
      storage: reportsStorageProvider
  ));

  // Attachment provider

  var storage = builder.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken);
  var au = AuthProvider(Uri.parse('https://sso.foxstudios.ru:32460'), storage);
  builder.registerDependency(IAuthProviderDIToken, au);

  var di = builder.build();

  runApp(MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    ),
    home: MainPage(di: di))
  );
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