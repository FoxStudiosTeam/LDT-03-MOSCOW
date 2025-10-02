import 'package:flutter/material.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/widgets/drawer_menu.dart';
import 'package:mobile_flutter/widgets/attachment_card.dart';

import 'package:mobile_flutter/widgets/base_header.dart';

import '../../utils/style_utils.dart';

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
  Role? _role;
  List<PunishmentItemAttachmentCard> data = [];

  void leaveHandler() {
    Navigator.pop(context);
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
        title: "Вложения нарушения",
        subtitle: widget.addr,
        onBack: leaveHandler,
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}