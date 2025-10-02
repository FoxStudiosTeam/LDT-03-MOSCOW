import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/punishment/punishment_provider.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:mobile_flutter/widgets/attachments.dart';
import 'package:mobile_flutter/widgets/base_header.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';

class PunishmentEditorScreen extends StatefulWidget {
  final String addr;
  final Map<int, String> statuses;
  final Map<String, String> documents;
  final Function(PunishmentItem item) onSubmit;

  const PunishmentEditorScreen({
    super.key,
    required this.addr, 
    required this.onSubmit, 
    required this.statuses, 
    required this.documents,
  });
  
  @override
  State<StatefulWidget> createState() => _PunishmentEditorScreenState();
}

class _PunishmentEditorScreenState extends State<PunishmentEditorScreen> {
  List<PunishmentItemAndAttachments> _items = [];

  bool isLoading = true;
  String? _errorMessage;
  
  // Контроллеры
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _regulationDocController = TextEditingController();
  final TextEditingController _correctionDatePlanController = TextEditingController();
  final TextEditingController _correctionDateFactController = TextEditingController();
  final TextEditingController _correctionDateInfoController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  List<PlatformFile> _attachments = [];

  // Выбранные значения
  String? _selectedDocKey;
  int? _selectedStatusKey;
  DateTime? _selectedPlanDate;
  DateTime? _selectedFactDate;
  DateTime? _selectedInfoDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _regulationDocController.dispose();
    _correctionDatePlanController.dispose();
    _correctionDateFactController.dispose();
    _correctionDateInfoController.dispose();
    _commentController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Widget _loading() => const Center(child: CircularProgressIndicator());

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
    return _mainContent();
  }

  Widget _mainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Регламентный документ"),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedDocKey,
            items: widget.documents.entries
                .map((e) => DropdownMenuItem<String>(
                      value: e.key,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 80,
                        ),
                        child: Text(
                          e.value,
                          style: const TextStyle(
                            color: Colors.black,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (String? val) {
              setState(() {
                _selectedDocKey = val;
                _regulationDocController.text = val ?? "";
              });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Выберите документ",
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            isExpanded: true,
          ),
          const SizedBox(height: 16),

          _buildSectionTitle("Дата плановая"),
          const SizedBox(height: 8),
          TextFormField(
            controller: _correctionDatePlanController,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "ДД.ММ.ГГГГ",
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => _selectDate(
              context, 
              _correctionDatePlanController,
              (date) => _selectedPlanDate = date,
            ),
          ),
          const SizedBox(height: 16),

          _buildSectionTitle("Дата фактическая"),
          const SizedBox(height: 8),
          TextFormField(
            controller: _correctionDateFactController,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "ДД.ММ.ГГГГ",
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => _selectDate(
              context, 
              _correctionDateFactController,
              (date) => _selectedFactDate = date,
            ),
          ),
          const SizedBox(height: 16),

          _buildSectionTitle("Дата информации"),
          const SizedBox(height: 8),
          TextFormField(
            controller: _correctionDateInfoController,
            readOnly: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "ДД.ММ.ГГГГ",
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => _selectDate(
              context, 
              _correctionDateInfoController,
              (date) => _selectedInfoDate = date,
            ),
          ),
          const SizedBox(height: 16),

          _buildSectionTitle("Комментарий"),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Введите комментарий",
            ),
          ),
          const SizedBox(height: 16),

          _buildSectionTitle("Статус"),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _selectedStatusKey,
            items: widget.statuses.entries
                .map((e) => DropdownMenuItem<int>(
                      value: e.key,
                      child: Text(e.value.toString()),
                    ))
                .toList(),
            onChanged: (int? val) {
              setState(() {
                _selectedStatusKey = val;
                _statusController.text = val?.toString() ?? "";
              });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Выберите статус",
            ),
          ),
          const SizedBox(height: 32),

          AttachmentsSection(
            context, 
            _attachments,
            (index) => setState(() => _attachments.removeAt(index)),
          ),

          // todo! attachments button
          ElevatedButton(
            onPressed: _allFieldsFilled() ? _onSubmit : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("Сохранить"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  bool _allFieldsFilled() {
    return _selectedDocKey != null &&
        _correctionDatePlanController.text.isNotEmpty &&
        _correctionDateFactController.text.isNotEmpty &&
        _correctionDateInfoController.text.isNotEmpty &&
        _commentController.text.isNotEmpty &&
        _selectedStatusKey != null;
  }

  void _onSubmit() {
    if (!_allFieldsFilled()) {
      // todo: notify user
      return;
    }
    var item = PunishmentItem(
      title: _titleController.text,
      regulationDoc: _regulationDocController.text,
      correctionDatePlan: _correctionDatePlanController.text,
      correctionDateFact: _correctionDateFactController.text,
      correctionDateInfo: _correctionDateInfoController.text,
      comment: _commentController.text,
      status: _selectedStatusKey!,
      attachments: _attachments,
    );
    
    widget.onSubmit(item);
  }
}

class PunishmentItem {
  final String title;
  final String regulationDoc;
  final String correctionDatePlan;
  final String correctionDateFact;
  final String correctionDateInfo;
  final String comment;
  final int status;
  final List<PlatformFile> attachments;

  PunishmentItem({
    required this.title,
    required this.regulationDoc,
    required this.correctionDatePlan,
    required this.correctionDateFact,
    required this.correctionDateInfo,
    required this.comment,
    required this.status,
    required this.attachments,
  });
}