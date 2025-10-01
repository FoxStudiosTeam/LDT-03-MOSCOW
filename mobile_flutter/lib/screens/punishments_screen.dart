import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/punishment/punishment_provider.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/drawer_menu.dart';
import 'package:mobile_flutter/widgets/fox_header.dart';
import 'package:mobile_flutter/widgets/punishment_card.dart';
import 'package:mobile_flutter/utils/network_utils.dart';

import '../auth/auth_provider.dart';
import '../widgets/base_header.dart';
class PunishmentsScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String projectUuid;
  final String addr;

  const PunishmentsScreen({
    super.key,
    required this.di,
    required this.projectUuid,
    required this.addr
  });

  @override
  State<PunishmentsScreen> createState() => _PunishmentsScreenState();
}

class _PunishmentsScreenState extends State<PunishmentsScreen> {
  String? _token;
  List<PunishmentCard> data = [];

  void leaveHandler() {
    Navigator.pop(context);
  }

  void _openPunishmentMenu(BuildContext context) {
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
    _loadToken();
    _loadCards().then((cards) {
      setState(() {
        data = cards;
      });
    });
  }

  Future<void> _loadToken() async {
    try {
      var authStorageProvider = widget.di.getDependency<IAuthStorageProvider>(
        IAuthStorageProviderDIToken,
      );
      var token = await authStorageProvider.getAccessToken();
      setState(() {
        _token = token;
      });
    } catch (e) {
      setState(() {
        _token = "NO TOKEN";
      });
    }
  }

  Future<List<PunishmentCard>> _loadCards() async {
    final provider = widget.di.getDependency<IPunishmentProvider>(IPunishmentProviderDIToken);
    final statuses = await provider.get_statuses();

    final punishments = await NetworkUtils.wrapRequest<List<Punishment>>(() => provider.get_punishments(widget.projectUuid),context,widget.di);

    return punishments.map((punishment) => PunishmentCard(
      data: punishment,
      statuses: statuses,
      di: widget.di,
      addr: widget.addr,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FoxHeader(
        leftIcon: IconButton(
          onPressed: leaveHandler,
          icon: SvgPicture.asset(
            'assets/icons/arrow-left.svg',
            width: 32,
            height: 32,
          ),
        ),
        title: "Предписания",
        subtitle: widget.addr,
        rightIcon: IconButton(
          onPressed: () => _openPunishmentMenu(context),
          icon: SvgPicture.asset(
            'assets/icons/menu-kebab.svg',
            width: 32,
            height: 32,
          ),
        ),
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
