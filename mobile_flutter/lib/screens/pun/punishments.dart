import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/punishment/punishment_provider.dart';
import 'package:mobile_flutter/screens/pun/punishment_creator.dart';
import 'package:mobile_flutter/screens/pun/punishment_viewer.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:mobile_flutter/widgets/base_header.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/screens/pun/punishment_card.dart';

class ProjectPunishmentsScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String projectUuid;
  final String addr;
  final bool isNear;
  final Role role;

  const ProjectPunishmentsScreen({
    super.key,
    required this.di, 
    required this.projectUuid, 
    required this.addr, 
    required this.isNear,
    required this.role
  });
  
  @override
  State<StatefulWidget> createState() => _ProjectPunishmentsScreenState();
  
}

class _ProjectPunishmentsScreenState extends State<ProjectPunishmentsScreen>  {
  late List<Punishment> _puns;
  late var _statuses;
  void _loadPunishments() async {
    final provider = widget.di.getDependency<IPunishmentProvider>(IPunishmentProviderDIToken);
    final punishments = await NetworkUtils.wrapRequest<List<Punishment>>(() => provider.get_punishments(widget.projectUuid),context,widget.di);
    _statuses = await NetworkUtils.wrapRequest<Map<int, String>>(() => provider.get_statuses(),context,widget.di);
    setState(() {
      isLoading = false;
      _puns = punishments;
    });
  }

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadPunishments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseHeader(
        title: "Предписания",
        subtitle: widget.addr,
        onBack: () => Navigator.pop(context),
        onMore: (((widget.role == Role.INSPECTOR || widget.role == Role.CUSTOMER) && widget.isNear) || widget.role == Role.ADMIN) ? _openPunishmentMenu : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading ? _loading() : _punishments(),
      )
    );
  }

  Widget _punishments() => ListView.builder(
    itemCount: _puns.length,
    itemBuilder: (context, index) => PunishmentCard(
      data: _puns[index],
      statuses: _statuses,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PunishmentViewerScreen(
              di: widget.di,
              addr: widget.addr,
              role: widget.role,
              data: _puns[index],
            ),
          ),
        );
      },
    ),
  );

  Widget _loading() => const Center(child: CircularProgressIndicator());

  void _openPunishmentMenu() {
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
            leading: const Icon(Icons.add),
            title: const Text('Создать предписание'),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PunishmentCreatorScreen(
                    di: widget.di,
                    addr: widget.addr,
                    projectUuid: widget.projectUuid,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}