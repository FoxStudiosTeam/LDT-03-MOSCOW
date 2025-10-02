import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/punishment/punishment_provider.dart';
import 'package:mobile_flutter/screens/create_punishment_item.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/drawer_menu.dart';

import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/widgets/base_header.dart';
import 'package:mobile_flutter/widgets/punishment_item_card.dart';

import '../utils/style_utils.dart';
class PunishmentItemsScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String? punishmentUuid;
  final String addr;
  final bool is_new;
  final Map<int, String> statuses;
  final Map<String, String> documents;
  final bool isNear;

  const PunishmentItemsScreen({
    super.key,
    required this.di,
    this.punishmentUuid,
    required this.addr,
    required this.is_new,
    required this.statuses,
    required this.documents,
    required this.isNear
  });

  @override
  State<PunishmentItemsScreen> createState() => _PunishmentItemsScreenState();
}

class _PunishmentItemsScreenState extends State<PunishmentItemsScreen> {
  String? _token;
  Role? _role;
  List<PunishmentItemCard> data = [];

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
            title: const Text('Создать нарушение'),
            onTap: () async {
              Navigator.pop(ctx);
              await _handleCreatePunishment();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreatePunishment() async {
     final PunishmentItem pi = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreatePunishmentScreen(
            di: widget.di,
            objectTitle: widget.addr,
            statues: widget.statuses,
            documents: widget.documents,
            isNear: widget.isNear,
          ),
        ),
     );
     final card = PunishmentItemCard(
         di: widget.di,
         data: pi,
         statuses: widget.statuses,
         docs: widget.documents,
         isNear: widget.isNear);
     setState(() {
       data.add(card);
     });
  }

  @override
  void initState() {
    super.initState();
    _loadAuth();
    if (!widget.is_new){
      _loadCards().then((cards) {
        setState(() {
          data = cards;
        });
      });
    }
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

  Future<List<PunishmentItemCard>> _loadCards() async {
    final provider = widget.di.getDependency<IPunishmentProvider>(IPunishmentProviderDIToken);
    final punishment_items = await NetworkUtils.wrapRequest<List<PunishmentItemAndAttachments>>(() =>
        provider.get_punishment_items(widget.punishmentUuid!), context, widget.di);

    punishment_items.sort((a, b) => b.punishment_item.punish_item_status.compareTo(a.punishment_item.punish_item_status));

    return punishment_items.map((punishment_item_plus) => PunishmentItemCard(
      di: widget.di,
      atts: punishment_item_plus.attachments,
      data: punishment_item_plus.punishment_item,
      statuses: widget.statuses,
      docs: widget.documents,
      role: _role,
      isNear: widget.isNear,
    )).toList();
  }

  void _savePunishment() {
      // Navigator.pop(context, PunishmentItemCard(
      //     di: widget.di,
      //     atts: atts,
      //     data: data,
      //     statuses: widget.statuses,
      //     docs: widget.documents,
      //   isNear: widget.isNear,
      //    TODO
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseHeader(
          title: "Нарушения",
          subtitle: widget.addr,
          onBack: leaveHandler,
          onMore: ((_role == Role.INSPECTOR || _role == Role.CUSTOMER || _role == Role.ADMIN) && widget.is_new)
              ? _openPunishmentMenu : null,
        ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: data.isEmpty
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : ListView.separated(
              itemCount: data.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => data[index],
            ),
          ),
        ]
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 48, // фиксированная высота
          child: ElevatedButton(
            onPressed: _savePunishment,
            style: ElevatedButton.styleFrom(
              backgroundColor: FoxThemeButtonActiveBackground,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Сохранить',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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