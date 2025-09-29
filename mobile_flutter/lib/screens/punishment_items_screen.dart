import 'package:flutter/material.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/punishment/punishment_provider.dart';
import 'package:mobile_flutter/widgets/drawer_menu.dart';
import 'package:mobile_flutter/widgets/punishment_card.dart';
import 'package:mobile_flutter/widgets/punishment_item_card.dart';

import '../auth/auth_provider.dart';
class PunishmentItemsScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String punishment;

  const PunishmentItemsScreen({super.key, required this.di, required this.punishment});

  @override
  State<PunishmentItemsScreen> createState() => _PunishmentItemsScreenState();
}

class _PunishmentItemsScreenState extends State<PunishmentItemsScreen> {
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
    final punishment_items = await provider.get_punishments(widget.punishment);

    return punishment_items.map((punishment) => PunishmentItemCard(
        di: widget.di,
        punish_datetime: punishment.punishDatetime,
        punishment_status: statuses[punishment.punishmentStatus] ?? "Неизвестный статус",
        custom_number: punishment.customNumber
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          title: Text('ЭСЖ'),
          automaticallyImplyLeading: false,
        ),
        body: data.isEmpty
            ? Center(child: CircularProgressIndicator())
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
