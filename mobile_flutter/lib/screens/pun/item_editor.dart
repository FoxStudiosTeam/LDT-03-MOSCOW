import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/punishment/punishment_provider.dart';
import 'package:mobile_flutter/utils/file_utils.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
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

  // Исправленный метод для выбора даты
  Future<void> _selectDate(BuildContext context, TextEditingController controller, Function(DateTime?) onDateSelected) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        locale: const Locale('ru', 'RU'),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: FoxThemeButtonActiveBackground,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: FoxThemeButtonActiveBackground,
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && mounted) {
        setState(() {
          final formattedDate = "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
          controller.text = formattedDate;
          onDateSelected(picked);
        });
      }
    } catch (e) {
      print("Error selecting date: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка выбора даты: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  // Методы для работы с вложениями (как в TTNScanScreen)
  Future<void> _pickFiles() async {
    final files = await FileUtils.pickFiles(context: context);
    if (files != null && files.isNotEmpty) {
      setState(() {
        _attachments.addAll(files);
      });
      FileUtils.showSuccessSnackbar('Файлы добавлены', context);
    }
  }

  Future<void> _pickImages() async {
    final images = await FileUtils.pickImages(context: context);
    if (images != null && images.isNotEmpty) {
      setState(() {
        _attachments.addAll(images);
      });
      FileUtils.showSuccessSnackbar('Фото добавлены', context);
    }
  }

  void _openAddAttachmentMenu(BuildContext context) {
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
            leading: const Icon(Icons.attach_file),
            title: const Text('Добавить файл'),
            onTap: () {
              Navigator.pop(ctx);
              _pickFiles();
            },
          ),
          const Divider(height: 1),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.photo),
            title: const Text('Добавить фото'),
            onTap: () {
              Navigator.pop(ctx);
              _pickImages();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseHeader(
        title: "Зафиксировать нарушения",
        subtitle: widget.addr,
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.grey[50],
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return _mainContent();
  }

  Widget _mainContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Карточка с формой
                _buildFormCard(),

                const SizedBox(height: 20),

                // Секция вложений (как в TTNScanScreen)
                _buildAttachmentsSection(),
              ],
            ),
          ),
        ),

        // Кнопки действий (как в TTNScanScreen)
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Регламентный документ", required: true),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedDocKey,
            items: widget.documents.entries
                .map((e) => DropdownMenuItem<String>(
              value: e.key,
              child: Text(
                e.value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ))
                .toList(),
            onChanged: (String? val) {
              setState(() {
                _selectedDocKey = val;
                _regulationDocController.text = val ?? "";
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: FoxThemeButtonActiveBackground, width: 2),
              ),
              hintText: "Выберите документ",
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // Плановая дата
          _buildSectionTitle("Плановая дата", required: true),
          const SizedBox(height: 6),
          _buildDateField(
            _correctionDatePlanController,
            "ДД.ММ.ГГГГ",
                (date) => _selectedPlanDate = date,
          ),
          const SizedBox(height: 16),

          // Фактическая дата (перемещена под плановую)
          _buildSectionTitle("Фактическая дата", required: true),
          const SizedBox(height: 6),
          _buildDateField(
            _correctionDateFactController,
            "ДД.ММ.ГГГГ",
                (date) => _selectedFactDate = date,
          ),
          const SizedBox(height: 16),

          _buildSectionTitle("Дата информации", required: true),
          const SizedBox(height: 6),
          _buildDateField(
            _correctionDateInfoController,
            "ДД.ММ.ГГГГ",
                (date) => _selectedInfoDate = date,
          ),
          const SizedBox(height: 16),

          _buildSectionTitle("Комментарий", required: true),
          const SizedBox(height: 6),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: FoxThemeButtonActiveBackground, width: 2),
              ),
              hintText: "Введите комментарий...",
              contentPadding: const EdgeInsets.all(16),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 16),

          _buildSectionTitle("Статус", required: true),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            value: _selectedStatusKey,
            items: widget.statuses.entries
                .map((e) => DropdownMenuItem<int>(
              value: e.key,
              child: Text(
                e.value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            ))
                .toList(),
            onChanged: (int? val) {
              setState(() {
                _selectedStatusKey = val;
                _statusController.text = val?.toString() ?? "";
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: FoxThemeButtonActiveBackground, width: 2),
              ),
              hintText: "Выберите статус",
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String hintText, Function(DateTime?) onDateSelected) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: FoxThemeButtonActiveBackground, width: 2),
        ),
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: Colors.grey[50],
        suffixIcon: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: FoxThemeButtonActiveBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () => _selectDate(context, controller, onDateSelected),
            icon: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_file, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                "Вложения",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              if (_attachments.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: FoxThemeButtonActiveBackground.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_attachments.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: FoxThemeButtonActiveBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          if (_attachments.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.attach_file, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    "Нет прикрепленных файлов",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
          // Используем AttachmentsSection как в TTNScanScreen
            AttachmentsSection(
              context,
              _attachments,
                  (index) => setState(() => _attachments.removeAt(index)),
            ),
        ],
      ),
    );
  }

  // Кнопки действий как в TTNScanScreen
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Кнопка сохранения
          Expanded(
            child: ElevatedButton(
              onPressed: _allFieldsFilled() ? _onSubmit : null,
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
                'Сохранить нарушение',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Кнопка добавления вложений (как в TTNScanScreen)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: FoxThemeButtonActiveBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => _openAddAttachmentMenu(context),
              icon: const Icon(Icons.add, color: Colors.white, size: 24),
              tooltip: 'Добавить вложения',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool required = false}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ],
      ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заполните все обязательные поля'),
          backgroundColor: Colors.red,
        ),
      );
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