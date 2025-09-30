import 'package:flutter/material.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/widgets/attachment_card.dart';
import 'package:mobile_flutter/widgets/drawer_menu.dart';
import 'package:mobile_flutter/widgets/base_header.dart';

import '../auth/auth_provider.dart';
class PunishmentItemScreen extends StatefulWidget {
  final IDependencyContainer di;
  final List<Attachment> atts;
  final String addr;

  const PunishmentItemScreen({super.key, required this.di, required this.atts, required this.addr});

  @override
  State<PunishmentItemScreen> createState() => _PunishmentItemScreenState();
}

class _PunishmentItemScreenState extends State< PunishmentItemScreen> {
  String? _token;
  List<PunishmentItemAttachmentCard> data = [];


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

  Future<List<PunishmentItemAttachmentCard>> _loadCards() async {
    return widget.atts.map((att) => PunishmentItemAttachmentCard(
      di: widget.di,
      data: att,
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
            ? Center(child: Text("Вложения отсутствуют"))
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
