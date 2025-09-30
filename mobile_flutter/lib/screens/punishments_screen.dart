import 'package:flutter/material.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/punishment/punishment_provider.dart';
import 'package:mobile_flutter/widgets/drawer_menu.dart';
import 'package:mobile_flutter/widgets/punishment_card.dart';

import '../auth/auth_provider.dart';
import '../widgets/base_header.dart';
class PunishmentsScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String projectUuid;
  final String addr;

  const PunishmentsScreen({super.key, required this.di, required this.projectUuid, required this.addr});

  @override
  State<PunishmentsScreen> createState() => _PunishmentsScreenState();
}

class _PunishmentsScreenState extends State<PunishmentsScreen> {
  String? _token;
  List<PunishmentCard> data = [];

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
    final punishments = await provider.get_punishments(widget.projectUuid);

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
        appBar: BaseHeader(
          title: 'Вложения нарушения',
          subtitle: '${widget.addr}',
          onBack: () => {
            Navigator.pop(context)
          },
        ),
        body: data.isEmpty
            ? Center(child: Text("Предписаний не обнаружено"))
            : ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) => data[index],
        ),
        drawer: DrawerMenu(di: widget.di)

    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
