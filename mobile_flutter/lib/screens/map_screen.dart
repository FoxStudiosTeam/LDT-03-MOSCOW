import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/object/object_provider.dart';
import 'package:mobile_flutter/screens/ocr/camera.dart';
import 'package:mobile_flutter/widgets/drawer_menu.dart';
import 'package:mobile_flutter/widgets/fox_button.dart';
import 'package:mobile_flutter/widgets/fox_header.dart';
import 'package:mobile_flutter/widgets/object_card.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:latlong2/latlong.dart';

class ObjectsScreen extends StatefulWidget {
  final IDependencyContainer di;

  const ObjectsScreen({super.key, required this.di});

  @override
  State<ObjectsScreen> createState() => _ObjectsScreenState();
}

class _ObjectsScreenState extends State<ObjectsScreen> {
  String? _token;
  Role? _role;
  List<Project> projects = [];
  bool _isLoading = true; // флаг загрузки
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<FoxPolygon> polygons = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadAuth();
    _loadProjects();
  }

  Future<void> _loadAuth() async {
    try {
      var authStorageProvider = widget.di.getDependency<IAuthStorageProvider>(
        IAuthStorageProviderDIToken,
      );
      var role = await authStorageProvider.getRole();
      var token = await authStorageProvider.getAccessToken();
      setState(() {
        _token = token;
        _role = roleFromString(role);
      });
    } catch (e) {
      setState(() {
        _token = "NO TOKEN";
        _role = Role.UNKNOWN;
      });
    }
  }
  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true; // начинаем загрузку
    });

    var objectsProvider = widget.di.getDependency<IObjectsProvider>(
      IObjectsProviderDIToken,
    );

    var response = await NetworkUtils.wrapRequest(
          () => objectsProvider.getObjects("", 0),
      context,
      widget.di,
    );

    setState(() {
      projects = response.items;
      _isLoading = false; // загрузка завершена
    });
  }

  void sortExited() {
    setState(() {
      projects.sort((a, b) => b.status.index.compareTo(a.status.index));
    });
  }

  void sortInAction() {
    setState(() {
      projects.sort((a, b) => a.status.index.compareTo(b.status.index));
    });
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  double _currentZoom = 15.0;

  void zoomIn() {
    final newZoom = (_currentZoom + 1).clamp(1.0, 18.0);
    _currentZoom = newZoom;
    // Используем current center карты
    final center = _mapController.camera.center ?? calcCameraPosition();
    _mapController.move(center, newZoom);
    setState(() {});
  }

  void zoomOut() {
    final newZoom = (_currentZoom - 1).clamp(1.0, 18.0);
    _currentZoom = newZoom;
    final center = _mapController.camera.center ?? calcCameraPosition();
    _mapController.move(center, newZoom);
    setState(() {});
  }


  LatLng calcCameraPosition() {
    List<LatLng> points = [];

    for (var project in projects) {
      if (project.polygon != null) {
        final center = project.polygon!.getCenter();
        points.add(center);
      }
    }

    if (points.isEmpty)
      return const LatLng(55.7558, 37.6173); // Москва как fallback

    double sumLat = 0;
    double sumLng = 0;
    int i = 0;

    for (var point in points) {
      if (point.longitude.isFinite && point.latitude.isFinite) {
        sumLat += point.latitude;
        sumLng += point.longitude;
        i++;
      }
    }

    final avgLat = sumLat / i;
    final avgLng = sumLng / i;

    if (avgLat.isNaN || avgLng.isNaN || !avgLat.isFinite || !avgLng.isFinite) {
      return const LatLng(55.7558, 37.6173); // fallback
    }

    return LatLng(avgLat, avgLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: FoxHeader(
        backgroundColor: Colors.white,
        leftIcon: SvgPicture.asset(
          'assets/icons/logo.svg',
          width: 40,
          height: 40,
          color: Colors.black,
        ),
        title: "ЭСЖ",
        rightIcon: IconButton(
          onPressed: openDrawer,
          icon: SvgPicture.asset(
            'assets/icons/menu.svg',
            width: 40,
            height: 40,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      ) // Крутилка пока грузим
          : Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoomInBtn',
                        mini: true,
                        onPressed: zoomIn,
                        child: Icon(Icons.zoom_in),
                      ),
                      SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: 'zoomOutBtn',
                        mini: true,
                        onPressed: zoomOut,
                        child: Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: calcCameraPosition(),
                    initialZoom: _currentZoom,
                    onPositionChanged: (MapCamera camera, bool hasGesture) {
                      setState(() {
                        _currentZoom = camera.zoom ?? _currentZoom;
                      });
                    },
                    interactionOptions: InteractionOptions(
                        flags: InteractiveFlag.all
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.yourapp',
                    ),
                    PolygonLayer(
                      polygons: projects
                          .where(
                            (p) =>
                        p.polygon != null &&
                            p.polygon!.points.isNotEmpty,
                      )
                          .map(
                            (p) => Polygon(
                          points: p.polygon!.points,
                          color: Colors.blue.withOpacity(0.3),
                          borderColor: Colors.blue,
                          borderStrokeWidth: 2,
                        ),
                      )
                          .toList(),
                    ),
                    MarkerLayer(
                      markers: projects
                          .where((p) => p.polygon != null)
                          .map(
                            (p) => Marker(
                          point: p.polygon!.getCenter(),
                          width: 30,
                          height: 30,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 30.0,
                      left: 8.0,
                    ),
                    child: FoxButton(
                      onPressed: sortInAction,
                      text: "В процессе",
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 30.0,
                      right: 8.0,
                    ),
                    child: FoxButton(
                      onPressed: sortExited,
                      text: "Завершенные",
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OcrCameraScreen(),
                ),
              );
            },
            child: const Text("OCR"),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: projects.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ObjectCard(
                      projectUuid: project.uuid,
                      title: project.address,
                      status: project.status,
                      address: project.address,
                      di: widget.di,
                      polygon: project.polygon!,
                      customer: project.created_by,
                      foreman: project.foreman,
                      inspector: project.ssk,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      drawer: DrawerMenu(di: widget.di),
    );
  }
}
