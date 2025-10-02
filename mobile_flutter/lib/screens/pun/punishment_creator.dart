import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/punishment/punishment_provider.dart';
import 'package:mobile_flutter/screens/pun/item_editor.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:mobile_flutter/widgets/attachments.dart';
import 'package:mobile_flutter/widgets/base_header.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';

class PunishmentCreatorScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String addr;
  final String projectUuid;

  const PunishmentCreatorScreen({
    super.key,
    required this.di, 
    required this.addr, 
    required this.projectUuid,
  });
  
  @override
  State<StatefulWidget> createState() => _PunishmentCreatorScreenState();
}

class _PunishmentCreatorScreenState extends State<PunishmentCreatorScreen> {
  List<PunishmentItemAndAttachments> _items = [];
  Map<int, String> _statuses = {};
  Map<String, String> _docs = {};
  
  bool isLoading = true;
  String? _errorMessage;

  // Выбранные значения
  String? _selectedDocKey;
  int? _selectedStatusKey;
  DateTime? _selectedPlanDate;
  DateTime? _selectedFactDate;
  DateTime? _selectedInfoDate;

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

  // Метод для выбора даты
  Future<void> _selectDate(BuildContext context, TextEditingController controller, Function(DateTime?) onDateSelected) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        locale: const Locale('ru', 'RU'),
      );
      
      if (picked != null && mounted) {
        final formattedDate = "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
        controller.text = formattedDate;
        onDateSelected(picked);
        
        setState(() {});
      }
    } catch (e) {
      print("Error selecting date: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseHeader(
        title: "Зафиксировать нарушения",
        subtitle: widget.addr,
        onBack: () => Navigator.pop(context),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PunishmentEditorScreen(
                      addr: widget.addr,
                      documents: _docs,
                      statuses: _statuses,
                      onSubmit: (item) => {},
                    ),
                  ),
                )
              },
              child: Text("Добавить")
          ),
          TextButton(
            onPressed: () => {},
            child: Text("Подтвердить")
          ),
        ],
      ),
    );
  }
}
