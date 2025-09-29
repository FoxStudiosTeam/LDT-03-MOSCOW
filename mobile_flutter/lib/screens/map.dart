import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/screens/auth_screen.dart';

import '../di/dependency_container.dart';

class MapScreen extends StatefulWidget {
  final IDependencyContainer di;
  const MapScreen({super.key, required this.di});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _token; // Переменная для хранения токена
  late SimpleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = SimpleMapController(
      initPosition: GeoPoint(
        latitude: 47.4358055,
        longitude: 8.4737324,
      ),
      markerHome: MarkerIcon(
        assetMarker: AssetMarker(
          image: AssetImage('assets/marker.png'), // Укажите корректный путь к изображению
        ),
      ),
    );

    // Получаем токен асинхронно
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      var authStorageProvider = widget.di.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken);
      var token = await authStorageProvider.getRefreshToken();
      setState(() {
        _token = token;
      });
    } catch (e) {
      setState(() {
        _token = "NO TOKEN";
      });
    }
  }

  Future<void> _leave() async {
    await widget.di.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken).clear();
    Navigator.push(context, MaterialPageRoute(builder: (_) => AuthScreen(di:widget.di)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_token ?? 'Загрузка...'), // Пока токен не загружен показываем "Загрузка..."
        automaticallyImplyLeading: false
      ),
      body: OSMViewer(
        controller: _mapController,
        zoomOption: ZoomOption(initZoom: 16, minZoomLevel: 11),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            _leave();
          },
          child: Text('Выход'),
        ),
      ),
    );
  }
}
