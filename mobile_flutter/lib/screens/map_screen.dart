import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/emojione_monotone.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/tabler.dart';
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

class MapScreen extends StatefulWidget {
  final IDependencyContainer di;

  const MapScreen({super.key, required this.di});

  @override
  State<MapScreen> createState() => _MapScreenState();
}
class _MapScreenState extends State<MapScreen> {
  String? _token;
  Role? _role;
  List<Project> projects = [];
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();

  Project? currentProject; // ✅ Сделали nullable

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
      _isLoading = true;
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
      _isLoading = false;
      if (projects.isNotEmpty) {
        currentProject = projects.first; // ✅ Установка первого проекта по умолчанию
      }
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

  double _currentZoom = 8.0;

  void zoomIn() {
    final newZoom = (_currentZoom + 1).clamp(1.0, 18.0);
    _currentZoom = newZoom;
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
    final points = projects
        .where((p) => p.polygon != null)
        .map((p) => p.polygon!.getCenter())
        .where((point) =>
    point.latitude.isFinite && point.longitude.isFinite)
        .toList();

    if (points.isEmpty) return const LatLng(55.753930, 37.620795); // fallback

    final sumLat = points.fold(0.0, (sum, p) => sum + p.latitude);
    final sumLng = points.fold(0.0, (sum, p) => sum + p.longitude);
    final avgLat = sumLat / points.length;
    final avgLng = sumLng / points.length;

    return LatLng(avgLat, avgLng);
  }

  void onClickMapPin(Project p) {
    setState(() {
      currentProject = p;
    });
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
      drawer: DrawerMenu(di: widget.di),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: calcCameraPosition(),
                    initialZoom: _currentZoom,
                    onPositionChanged:
                        (MapCamera camera, bool hasGesture) {
                      setState(() {
                        _currentZoom = camera.zoom ?? _currentZoom;
                      });
                    },
                    interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.all,
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
                          .where((p) =>
                      p.polygon != null &&
                          p.polygon!.points.isNotEmpty)
                          .map((p) => Polygon(
                        points: p.polygon!.points,
                        color: Colors.blue.withOpacity(0.3),
                        borderColor: Colors.blue,
                        borderStrokeWidth: 2,
                      ))
                          .toList(),
                    ),
                    MarkerLayer(
                      markers: projects
                          .where((p) => p.polygon != null)
                          .map(
                            (p) => Marker(
                          point: p.polygon!.getCenter(),
                          width: 42,
                          height: 42,
                          child: IconButton(
                            onPressed: () => onClickMapPin(p),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(p.status.getStatusColor()),
                              shadowColor: WidgetStateProperty.all(Colors.black),
                            ),
                            // constraints: BoxConstraints(
                            //   minHeight: 30,
                            //   maxHeight: 30,
                            //   minWidth: 30,
                            //   maxWidth: 30,
                            // ),
                            icon: 
                              Stack(children: [
                                ImageFiltered(
                                  imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Iconify(Mdi.worker, color: Colors.black.withOpacity(1.0), size: 42),
                                ),
                                Iconify(Mdi.worker, color: Colors.white, size: 42),
                              ],)
                            // icon: Iconify(
                            //   icon: Iconify(),
                            //   color: p.status.getStatusColor(),  
                            //   shadows: [
                            //     Shadow(
                            //       color: Colors.black,
                            //       offset: const Offset(1, 1),
                            //       blurRadius: 2,
                            //     ),
                            //   ],
                            //   size: 30,
                            // ),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ],
                ),

                /// ✅ Кнопки зума поверх карты
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoomInBtn',
                        mini: true,
                        onPressed: zoomIn,
                        child: const Icon(Icons.zoom_in),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: 'zoomOutBtn',
                        mini: true,
                        onPressed: zoomOut,
                        child: const Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          /// ✅ Показываем карточку только если выбран проект
          if (currentProject != null)
            ObjectCard(
              projectUuid: currentProject!.uuid,
              title: currentProject!.address,
              status: currentProject!.status,
              address: currentProject!.address,
              di: widget.di,
              polygon: currentProject!.polygon!,
              customer: currentProject!.created_by,
              foreman: currentProject!.foreman,
              inspector: currentProject!.ssk,
              isStatic: true,
            ),
        ],
      ),
    );
  }
}
