import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/main.dart';
import 'package:mobile_flutter/punishment/punishment_provider.dart';
import 'package:mobile_flutter/screens/pun/item_card.dart';
import 'package:mobile_flutter/screens/pun/item_editor.dart';
import 'package:mobile_flutter/utils/file_utils.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
import 'package:mobile_flutter/widgets/base_header.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/funny_things.dart';
import 'package:uuid/uuid.dart';


class PunishmentCreatorScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String addr;
  final String projectUuid;
  final Role role;
  final bool isNear;


  const PunishmentCreatorScreen({
    super.key,
    required this.di, 
    required this.addr, 
    required this.projectUuid,
    required this.role,
    required this.isNear
  });
  
  @override
  State<StatefulWidget> createState() => _PunishmentCreatorScreenState();
}

class _PunishmentCreatorScreenState extends State<PunishmentCreatorScreen> {
  List<DataPunishmentItem> _items = [];
  Map<int, String> _statuses = {};
  Map<String, String> _docs = {};
  
  final TextEditingController _customNumber = TextEditingController();
  
  bool isLoading = true;
  String? _errorMessage;

  // Выбранные значения

  @override
  void dispose() {
    super.dispose();
    _customNumber.dispose();
  }
  var attachments = [];
  @override
  void initState() {
    super.initState();
    _loadPunishments();
  }

  void _loadPunishments() async {
    try {
      final provider = widget.di.getDependency<IPunishmentProvider>(IPunishmentProviderDIToken);

      _docs = await provider.get_documents();
      _statuses = await provider.get_statuses();

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          _errorMessage = "Ошибка загрузки данных: $e";
        });
      }
    }
  }
  

  Widget _loading() => const Center(child: CircularProgressIndicator());

  Widget _errorWidget() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_errorMessage ?? "Произошла ошибка"),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loadPunishments,
          child: const Text("Повторить"),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseHeader(
        title: "Зафиксировать нарушения",
        subtitle: widget.addr,
        onBack: () => Navigator.pop(context),
        onMore: (((widget.role == Role.INSPECTOR || widget.role == Role.CUSTOMER) && widget.isNear) || widget.role == Role.ADMIN) ? () => _openAddAttachmentMenu() : null ,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) return _loading();
    if (_errorMessage != null) return _errorWidget();
    return _mainContent();
  }

  Widget _mainContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_items.isNotEmpty)
                  ..._items.map((item) => StylishPunishmentItemCard(
                  item: item,
                  statuses: _statuses,
                  // onTap: () => _onItemTap(item),
                  // onEdit: () => _onItemEdit(item),
                  // onDelete: () => _onItemDelete(item),
                  // isEditable: widget.role != Role.INSPECTOR,
                )).toList(),
              ],
            ),
          ),
        ),
      _buildActionButtons(),
    ],
  );
}

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final req = widget.di.getDependency<IQueuedRequests>(IQueuedRequestsDIToken);
                
                List<QueuedChildModel> items = [];
                for (var item in _items) {
                  items.add(
                    QueuedChildModel(
                      parent_key: "uuid",
                      body_key: "punishment", 
                      model: queuedPunishmentItem(item, widget.addr)
                    )
                  );
                }
                if (items.isEmpty) {
                  showErrSnackbar(context, "Нечего отправлять");
                  return;
                } 
                if (_customNumber.text.isEmpty) {
                  showErrSnackbar(context, "Введите номер");
                  return;
                }

                final token = await widget.di.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken).getAccessToken();

                var parent = QueuedRequestModel(
                  title: "Зафиксированные нарушения", 
                  timestamp: DateTime.now().millisecondsSinceEpoch, 
                  url: Uri.parse(APIRootURI).resolve('/api/punishment/create_punishment').toString(), 
                  method: 'POST', 
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                  body: {
                    'project': widget.projectUuid,
                    'items': [
                      {
                        'punishment_item_status': 1,
                        'punish_datetime': DateTime.now().toIso8601String().split('.').first,
                      }
                    ],
                    "custom_number": _customNumber,
                  }, 
                  id: Uuid().v4(),
                  children: items
                );

                final res = await req.queuedSend(parent, token);

                if (res.isDelayed) {
                  Navigator.pop(context);
                  showWarnSnackbar(context, "Материал будет отправлен после выхода в интернет");
                } else if (res.isOk) {
                  Navigator.pop(context);
                  showSuccessSnackbar(context, "Материал отправлен");
                } else {
                  showErrSnackbar(context, "Не удалось отправить материал");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FoxThemeButtonActiveBackground,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Сохранить предписание',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddAttachmentMenu() {
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
            title: const Text('Добавить нарушение'),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PunishmentEditorScreen(
                    addr: widget.addr,
                    documents: _docs,
                    statuses: _statuses,
                    onSubmit: (item) => {
                      setState(() {
                        log("Item added: ${item.title}");
                        _items.add(item);
                        log("Items ${_items.length}");
                      })
                    },
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


