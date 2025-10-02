import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/materials/materials_provider.dart';
import 'package:mobile_flutter/object/object_provider.dart';
import 'package:mobile_flutter/punishment/punishment_provider.dart';
import 'package:mobile_flutter/reports/reports_provider.dart';
import 'package:mobile_flutter/utils/geo_utils.dart';
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
  List<ProjectAndInspectors> projects = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  bool _isRefreshing = false;

  void _asyncInit() async {
    final provider = widget.di.getDependency<IPunishmentProvider>(IPunishmentProviderDIToken);
    final _ = await NetworkUtils.wrapRequest<Map<int, String>>(() => provider.get_statuses(),context,widget.di);
    final _ = await NetworkUtils.wrapRequest<Map<String, String>>(() => provider.get_documents(),context,widget.di);
    final mat_provider = widget.di.getDependency<IMaterialsProvider>(IMaterialsProviderDIToken);
    final _ = await NetworkUtils.wrapRequest<Map<int, String>>(() => mat_provider.get_measurements(),context,widget.di);
    final rep_provider = widget.di.getDependency<IReportsProvider>(IReportsProviderDIToken);
    final _ = await NetworkUtils.wrapRequest<Map<int, String>>(() => rep_provider.get_statuses(),context,widget.di);
  }

  @override
  void initState() {
    super.initState();
    _loadAuth();
    _loadProjects();
    var v = widget.di.getDependency(ILocationProviderDIToken) as ILocationProvider;
    v.begin();
    _asyncInit();
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

      // Загружаем дополнительные данные
      await NetworkUtils.wrapRequest(() =>
          widget.di.getDependency<IPunishmentProvider>(IPunishmentProviderDIToken).get_statuses(),
          context, widget.di);

      await NetworkUtils.wrapRequest(() =>
          widget.di.getDependency<IPunishmentProvider>(IPunishmentProviderDIToken).get_documents(),
          context, widget.di);

      await NetworkUtils.wrapRequest(() =>
          widget.di.getDependency<IMaterialsProvider>(IMaterialsProviderDIToken).get_measurements(),
          context, widget.di);

      print("Start Request");

      var response = await NetworkUtils.wrapRequest(() => objectsProvider.getObjects("", 0), context, widget.di);
      final List<ProjectAndInspectors> result = [];
      for (var project in response.items) {
        final inspectors = await NetworkUtils.wrapRequest(() => objectsProvider.getObjectInspectors(project.uuid),context,widget.di);
        result.add(ProjectAndInspectors(
            project: project,
            inspectors: inspectors
        ));
      }

      print("END Request");
      for (var elem in response.items) {
        print("${elem.address} ${elem.polygon}");
      }

      setState(() {
        projects = result;
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
      projects.sort((a, b) => b.project.status.index.compareTo(a.project.status.index));
    });
  }

  void sortInAction() {
    setState(() {
      projects.sort((a, b) => a.project.status.index.compareTo(b.project.status.index));
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
              color: Colors.red,
              backgroundColor: Colors.white,
              displacement: 40.0,
              strokeWidth: 3.0,
              child: _buildContent(),
            ),
          ),
        ],
      ),
      drawer: DrawerMenu(di: widget.di),
    );
  }

  Widget _buildContent() {
    if (projects.isEmpty) {
      return _buildLoadingState();
    } else {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ObjectCard(
              projectUuid: project.project.uuid,
              title: project.project.address,
              status: project.project.status,
              address: project.project.address,
              di: widget.di,
              polygon: project.project.polygon!,
              customer: project.project.created_by,
              foreman: project.project.foreman,
              inspector: project.inspectors,
              isStatic: false,
            ),
          );
        },
      );
    }
  }

  Widget _buildLoadingState() {
    if (_isLoading || _isRefreshing) {
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
}