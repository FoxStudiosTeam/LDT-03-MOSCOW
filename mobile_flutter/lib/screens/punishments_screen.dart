import 'package:flutter/material.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/punishment/punishment_provider.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/drawer_menu.dart';
import 'package:mobile_flutter/widgets/punishment_card.dart';
import 'package:mobile_flutter/utils/network_utils.dart';

import '../widgets/base_header.dart';
class PunishmentsScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String projectUuid;
  final String addr;
  final bool isNear;

  const PunishmentsScreen({
    super.key,
    required this.di,
    required this.projectUuid,
    required this.addr,
    required this.isNear,
  });

  @override
  State<PunishmentsScreen> createState() => _PunishmentsScreenState();
}

class _PunishmentsScreenState extends State<PunishmentsScreen> {
  String? _token;
  Role? _role;
  List<PunishmentCard> data = [];

  void leaveHandler() {
    Navigator.pop(context);
  }

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
              _handleCreatePunishment();
            },
          ),
        ],
      ),
    );
  }

  void _handleCreatePunishment() {
    // TODO: Реализовать создание предписания
    print("Создать новое предписание");
  }

  @override
  void initState() {
    super.initState();
    _loadAuth();
    _loadCards().then((cards) {
      setState(() {
        data = cards;
      });
    });
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

  Future<List<PunishmentCard>> _loadCards() async {
    final provider = widget.di.getDependency<IPunishmentProvider>(IPunishmentProviderDIToken);
    final statuses = await NetworkUtils.wrapRequest<Map<int, String>>(() => provider.get_statuses(),context,widget.di);

    final punishments = await NetworkUtils.wrapRequest<List<Punishment>>(() => provider.get_punishments(widget.projectUuid),context,widget.di);

    punishments.sort((a, b) => b.punishmentStatus.compareTo(a.punishmentStatus));

    return punishments.map((punishment) => PunishmentCard(
      data: punishment,
      statuses: statuses,
      di: widget.di,
      addr: widget.addr,
      is_new: false,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseHeader(
        title: "Предписания",
        subtitle: widget.addr,
        onBack: leaveHandler,
        onMore: (((_role == Role.INSPECTOR || _role == Role.CUSTOMER) && widget.isNear) || _role == Role.ADMIN) ? _openPunishmentMenu : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: data.isEmpty
            ? const Center(
          child: Text(
            "Предписаний не обнаружено",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        )
            : ListView.separated(
          itemCount: data.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => data[index],
        ),
      ),
      drawer: DrawerMenu(di: widget.di),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
