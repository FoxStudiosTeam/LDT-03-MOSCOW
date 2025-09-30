import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/object/object_provider.dart';
import 'package:mobile_flutter/screens/auth_screen.dart';
import 'package:mobile_flutter/screens/ocr/camera.dart';
import 'package:mobile_flutter/widgets/base_header.dart';
import 'package:mobile_flutter/widgets/drawer_menu.dart';
import 'package:mobile_flutter/widgets/fox_button.dart';
import 'package:mobile_flutter/widgets/fox_header.dart';
import 'package:mobile_flutter/widgets/object_card.dart';

import '../utils/network_utils.dart';

class ObjectsScreen extends StatefulWidget {
  final IDependencyContainer di;

  const ObjectsScreen({super.key, required this.di});

  @override
  State<ObjectsScreen> createState() => _ObjectsScreenState();
}

class _ObjectsScreenState extends State<ObjectsScreen> {
  String? _token;
  List<Project> projects = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadToken();
    _loadProjects();
  }

  Future<void> _loadToken() async {
    try {
      var authStorageProvider = widget.di.getDependency<IAuthStorageProvider>(
        IAuthStorageProviderDIToken,
      );
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

  Future<void> _loadProjects() async {
    var objectsProvider = widget.di.getDependency<IObjectsProvider>(
      IObjectsProviderDIToken,
    );

    print("Start Request");

    var response = await NetworkUtils.wrapRequest(() => objectsProvider.getObjects("", 0), context, widget.di);

    print("END Request");
    for (var elem in response.items) {
      print("${elem.address} ${elem.polygon}");
    }

    setState(() {
      projects = response.items;
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
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 30.0, left: 8.0),
                    child: FoxButton(
                      onPressed: sortInAction,
                      text: "В процессе",
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 8.0),
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
                MaterialPageRoute(builder: (_) => const OcrCameraScreen()),//КАМЕРА
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