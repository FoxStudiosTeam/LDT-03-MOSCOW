import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/drawer_menu.dart';
import 'package:mobile_flutter/widgets/fox_header.dart';
import 'package:mobile_flutter/widgets/attachment_card.dart';

class PunishmentItemScreen extends StatefulWidget {
  final IDependencyContainer di;
  final List<Attachment> atts;
  final String addr;

  const PunishmentItemScreen({
    super.key,
    required this.di,
    required this.atts,
    required this.addr
  });

  @override
  State<PunishmentItemScreen> createState() => _PunishmentItemScreenState();
}

class _PunishmentItemScreenState extends State<PunishmentItemScreen> {
  String? _token;
  List<PunishmentItemAttachmentCard> data = [];

  void leaveHandler() {
    Navigator.pop(context);
  }

  void _openAttachmentsMenu(BuildContext context) {
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
            title: const Text('Добавить вложение'),
            onTap: () {
              Navigator.pop(ctx);
              _handleAddAttachment();
            },
          ),
          const Divider(height: 1),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.filter_list),
            title: const Text('Фильтровать по типу'),
            onTap: () {
              Navigator.pop(ctx);
              _handleFilterAttachments();
            },
          ),
          const Divider(height: 1),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.download),
            title: const Text('Скачать все'),
            onTap: () {
              Navigator.pop(ctx);
              _handleDownloadAll();
            },
          ),
        ],
      ),
    );
  }

  void _handleAddAttachment() {
    // TODO: Реализовать добавление вложения
    print("Добавить новое вложение");
  }

  void _handleFilterAttachments() {
    // TODO: Реализовать фильтрацию по типу
    print("Фильтровать вложения по типу");
  }

  void _handleDownloadAll() {
    // TODO: Реализовать скачивание всех вложений
    print("Скачать все вложения");
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

  Future<List<PunishmentItemAttachmentCard>> _loadCards() async {
    return widget.atts.map((att) => PunishmentItemAttachmentCard(
      di: widget.di,
      data: att,
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
        title: "Вложения нарушения",
        subtitle: widget.addr,
        rightIcon: IconButton(
          onPressed: () => _openAttachmentsMenu(context),
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
            ? _buildEmptyState()
            : Column(
          children: [
            // Заголовок с количеством
            _buildHeader(),
            const SizedBox(height: 16),

            // Список вложений
            Expanded(
              child: ListView.separated(
                itemCount: data.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => data[index],
              ),
            ),
          ],
        ),
      ),
      // Кнопка добавления в FAB для быстрого доступа
      floatingActionButton: FloatingActionButton(
        onPressed: _handleAddAttachment,
        backgroundColor: FoxThemeButtonActiveBackground,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      drawer: DrawerMenu(di: widget.di),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Вложения (${data.length})",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Text(
            "${data.length} файлов",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.attach_file,
              size: 48,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Вложения отсутствуют",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Добавьте первое вложение",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleAddAttachment,
            style: ElevatedButton.styleFrom(
              backgroundColor: FoxThemeButtonActiveBackground,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Добавить вложение'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}