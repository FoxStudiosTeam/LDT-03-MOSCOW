import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/materials/materials_provider.dart';
import 'package:mobile_flutter/screens/ocr/ttn.dart';
import 'package:mobile_flutter/utils/geo_utils.dart';
import 'package:mobile_flutter/widgets/base_header.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';

import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/widgets/material_card.dart';

import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:latlong2/latlong.dart';


class MaterialsScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String projectTitle;
  final String projectUuid;
  final FoxPolygon polygon;

  const MaterialsScreen({
    super.key,
    required this.di,
    required this.projectTitle,
    required this.projectUuid,
    required this.polygon,
  });

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  String? _token;
  Role? _role;
  Map<int, String>? _measurements;
  List<MaterialCard> materials = [];
  void leaveHandler() {
    Navigator.pop(context);
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

  Future<List<MaterialCard>> _loadCards() async {
    final provider = widget.di.getDependency<IMaterialsProvider>(IMaterialsProviderDIToken);
    final measurements = await provider.get_measurements();

    setState(() {
      _measurements = measurements;
    });

    final materials = await NetworkUtils.wrapRequest(() => provider.get_materials(widget.projectUuid), context, widget.di);


    return materials.map((mat) => MaterialCard(
      di: widget.di,
      data: mat,
      role: _role,
      measurements: measurements,
    )).toList();
  }
  
  @override
  void dispose() {
    _locationProvider.reactiveLocation.removeListener(_locationListener);
    super.dispose();
  }

  late final _locationProvider;
  late final _locationListener;
  LatLng? _location = null;

  @override
  void initState() {
    super.initState();
    _loadAuth();
    _locationProvider = widget.di.getDependency(ILocationProviderDIToken) as ILocationProvider;

    _locationListener = () => setState(() {
      _location = _locationProvider.reactiveLocation.value;
    });
    _locationProvider.reactiveLocation.addListener(_locationListener);
    _loadCards().then((cards) {
      setState(() {
        materials = cards;
      });
    });
  }

  void _openMaterialMenu() {
    showBlurBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.download),
            title: const Text('Зарегистрировать новый материал'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TTNScanScreen(measurements: _measurements ?? {},)),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var isNear = _location == null ? false :
      isNearOrInsidePolygon(widget.polygon, 100.0, _location!);

    return Scaffold(
      appBar: BaseHeader(
        title: "Материалы",
        subtitle: widget.projectTitle,
        onBack: leaveHandler,
        onMore: ((_role == Role.FOREMAN || _role == Role.ADMIN) && isNear) ? _openMaterialMenu : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: materials.isEmpty
          ? const Center(
            child: Text(
              "Материалов не обнаружено",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          )
          : ListView.separated(
          itemCount: materials.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => materials[index],
        ),
      ),
    );
  }
}