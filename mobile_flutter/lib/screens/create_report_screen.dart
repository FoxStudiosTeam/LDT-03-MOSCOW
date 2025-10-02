import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
import 'package:mobile_flutter/utils/file_utils.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/base_header.dart';

class ReportCreationScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String address;
  final List<String> works;

  const ReportCreationScreen({super.key, required this.di, required this.address, required this.works});

  @override
  State<ReportCreationScreen> createState() => _ReportCreationScreenState();
}

class _ReportCreationScreenState extends State<ReportCreationScreen> {
  final TextEditingController _workNameController = TextEditingController();
  List<PlatformFile> attachments = [];
  String? _selectedWorkType;
  List<String> _workTypes = [];

  @override
  void initState() {
    super.initState();
    _workTypes=widget.works;
  }

  void leaveHandler() {
    Navigator.pop(context);
  }

  Future<void> _pickFiles() async {
    final files = await FileUtils.pickFiles(context: context);
    if (files != null && files.isNotEmpty) {
      setState(() {
        attachments.addAll(files);
      });
      FileUtils.showSuccessSnackbar('Файлы добавлены', context);
    }
  }

  Future<void> _pickImages() async {
    final images = await FileUtils.pickImages(context: context);
    if (images != null && images.isNotEmpty) {
      setState(() {
        attachments.addAll(images);
      });
      FileUtils.showSuccessSnackbar('Фото добавлены', context);
    }
  }

  //показ ошибок
  void _showErrorSnackbar(String message) {
    FileUtils.showErrorSnackbar(message, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseHeader(
        title: "Создание отчета",
        subtitle: widget.address,
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Селектор типа работы
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Название поля
                Text(
                  "Наименование работы",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                // Селектор вместо поля ввода
                DropdownButtonFormField<String>(
                  value: _selectedWorkType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintText: "Выберите работу",
                  ),
                  items: _workTypes.map((String workType) {
                    return DropdownMenuItem<String>(
                      value: workType,
                      child: Text(workType),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedWorkType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Выберите тип работы';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          // Секция вложений с ограниченной высотой и скроллингом
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildAttachmentsSection(),
            ),
          ),

          // Сохранить и добавить вложения
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                // Кнопка сохранения
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _saveReport();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FoxThemeButtonActiveBackground,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
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
                // Кнопка добавления вложений
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(left: 10),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Метод сохранения отчета
  void _saveReport() {
    if (_selectedWorkType == null) {
      _showErrorSnackbar('Выберите тип работы');
      return;
    }

    // TODO: Реализовать логику сохранения отчета с вложениями

    for (var file in attachments) {
      // TODO: сохранение вложений
    }

    Navigator.pop(context);
  }

  // Список с вложениями
  Widget _buildAttachmentsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Вложения",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              if (attachments.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '(${attachments.length})',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: attachments.map((file) {
                  return Chip(
                    avatar: FileUtils.getFileIcon(file.extension ?? ''),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          file.name,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          FileUtils.formatFileSize(file.size),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    onDeleted: () {
                      setState(() {
                        attachments.remove(file);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
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
}