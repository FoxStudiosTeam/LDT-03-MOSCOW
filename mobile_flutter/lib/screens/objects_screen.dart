import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/object/object_provider.dart';
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
  Role? _role;
  List<Project> projects = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  bool _isRefreshing = false;

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
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
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
    } catch (e) {
      // Обработка ошибок
      print("Error loading projects: $e");
    } finally {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  // Метод для обновления при свайпе
  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadProjects();
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: Colors.red, // Цвет индикатора
              backgroundColor: Colors.white, // Фон индикатора
              displacement: 40.0, // Отступ от верха
              strokeWidth: 3.0, // Толщина линии индикатора
              child: projects.isEmpty
                  ? _buildLoadingState()
                  : _buildProjectsList(),
            ),
          ),
        ],
      ),
      drawer: DrawerMenu(di: widget.di),
    );
  }

  Widget _buildLoadingState() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: const Center(
              child: Text(
                "Нет объектов для отображения",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildProjectsList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(), // Важно для RefreshIndicator
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
            isStatic: false,
          ),
        );
      },
    );
  }
}