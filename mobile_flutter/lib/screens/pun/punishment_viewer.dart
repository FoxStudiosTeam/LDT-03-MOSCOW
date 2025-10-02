import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/punishment/punishment_provider.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:mobile_flutter/widgets/base_header.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';

class PunishmentViewerScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String addr;
  final Punishment data;
  final Role role;

  const PunishmentViewerScreen({
    super.key,
    required this.di, 
    required this.addr, 
    required this.data, 
    required this.role,
  });
  
  @override
  State<StatefulWidget> createState() => _PunishmentViewerScreenState();
  
}

class _PunishmentViewerScreenState extends State<PunishmentViewerScreen>  {
  late List<PunishmentItemAndAttachments> _items;

  void _loadPunishments() async {
    final provider = widget.di.getDependency<IPunishmentProvider>(IPunishmentProviderDIToken);
    final items = await NetworkUtils.wrapRequest<List<PunishmentItemAndAttachments>>(() => provider.get_punishment_items(widget.data.uuid),context,widget.di);

    setState(() {
      isLoading = false;
      _items = items;
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
        title: "Нарушения",
        subtitle: widget.addr,
        onBack: () => Navigator.pop(context),
        // onMore: (((widget.role == Role.INSPECTOR || widget.role == Role.CUSTOMER) && widget.isNear) || widget.role == Role.ADMIN) ? _openPunishmentMenu : null,
      ),
      body: isLoading ? _loading() : Container(),
    );
  }

  Widget _loading() => const Center(child: CircularProgressIndicator());

  // Widget _punishments() => ListView.builder(
  //   itemCount: _items.length,
  //   itemBuilder: (context, index) => _items[index],
  // );

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
                
              },
            ),
          ],
        ),
      );
  }

  
}