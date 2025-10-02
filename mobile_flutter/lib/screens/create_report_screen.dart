import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/reports/reports_provider.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
import 'package:mobile_flutter/utils/file_utils.dart';
import 'package:mobile_flutter/widgets/attachments.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/base_header.dart';

import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:mobile_flutter/widgets/funny_things.dart';

class ReportCreationScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String address;
  final List<ProjectScheduleItem> works;

  const ReportCreationScreen({super.key, required this.di, required this.address, required this.works});

  @override
  State<ReportCreationScreen> createState() => _ReportCreationScreenState();
}

class ReportRecord {
  final String title;
  final String projectScheduleItem;
  final int status;
  final List<PlatformFile> attachments;
  const ReportRecord({
    required this.title,
    required this.projectScheduleItem,
    required this.attachments,
    required this.status
  });
}

class _ReportCreationScreenState extends State<ReportCreationScreen> {
  final TextEditingController _workNameController = TextEditingController();
  List<PlatformFile> attachments = [];
  String? _selectedWorkUuid;
  String? _selectedWorkTitle;
  List<ProjectScheduleItem> _workTypes = [];

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
      body: _mainContent()
    
    );
  }

  Widget _mainContent(){
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(children: [
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
                value: _selectedWorkUuid,
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
                items: _workTypes.map((ProjectScheduleItem workType) {
                  return DropdownMenuItem<String>(
                    value: workType.uuid,
                    child: Text(workType.title),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedWorkUuid = widget.works.where((e) => e.uuid == newValue).first.uuid;
                    _selectedWorkTitle = widget.works.where((e) => e.uuid == newValue).first.title;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Выберите тип работы';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AttachmentsSection(context, attachments, (v) => setState(() => attachments.removeAt(v)))
            ]),
          )
        ),
        _buildActionButtons()
      ],
    );
  }
/*
SingleChildScrollView(
        child: Column(children: [
            // Селектор типа работы
            Padding(
              child: Column(
                
              ),
            ),

            // Секция вложений с ограниченной высотой и скроллингом
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AttachmentsSection(context, attachments, (v) => attachments.removeAt(v)),
                  ),
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
      )
  */

  // Метод сохранения отчета
  void _saveReport() async {
    if (_selectedWorkUuid == null || _selectedWorkTitle == null) {
      _showErrorSnackbar('Выберите тип работы');
      return;
    }

    print("$_selectedWorkUuid\n$_selectedWorkTitle");

    final record = ReportRecord(
      title: _selectedWorkTitle!,
      status: 2,
      projectScheduleItem: _selectedWorkUuid!,
      attachments: attachments
    );

    final req = widget.di.getDependency<IQueuedRequests>(IQueuedRequestsDIToken);
    var toSend = queuedReport(record, widget.address);

    final token = await widget.di.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken).getAccessToken();
    var res = await req.queuedSend(toSend, token);
    if (res.isDelayed) {
      Navigator.pop(context);
      showWarnSnackbar(context, "Отчет будет отправлен после выхода в интернет");
    } else if (res.isOk) {
      Navigator.pop(context);
      showSuccessSnackbar(context, "Отчет отправлен");
    } else {
      showErrSnackbar(context, "Не удалось отправить отчет");
    }
  }

    Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => {
                _saveReport(),
                Navigator.pop(context)
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
                'Сохранить нарушение',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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