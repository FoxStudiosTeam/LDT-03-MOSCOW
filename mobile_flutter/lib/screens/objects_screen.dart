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
    var response = await objectsProvider.getObjects("", 0);
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

  void openDrawer(){
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: FoxHeader(
          leftIcon: SvgPicture.asset(
            'assets/icons/logo.svg',
            width: 24,
            height: 24,
            color: Colors.black, // если нужно перекрасить
          ),
          title: "ЭСЖ",
          rightIcon: IconButton(onPressed: openDrawer, icon: SvgPicture.asset(
            'assets/icons/menu.svg',
            width: 24,
            height: 24,
            color: Colors.black, // если нужно перекрасить
          )),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FoxButton(onPressed: sortInAction, text: "В процессе"),
                FoxButton(onPressed: sortExited, text: "Завершенные"),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OcrCameraScreen()),
              );
            },
            child: const Text("OCR"),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: projects.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ObjectCard(
                  title: project.address,
                  status: project.status,
                  di: widget.di,
                  polygon: project.polygon!,
                );
              },
            ),
          ),
        ],
      ),
      drawer: DrawerMenu(di: widget.di),
    );
  }
}
