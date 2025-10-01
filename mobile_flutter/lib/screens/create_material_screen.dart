import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
import 'package:mobile_flutter/utils/file_utils.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/base_header.dart';

class MaterialCreationScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String address;
  const MaterialCreationScreen({super.key, required this.di, required this.address});

  @override
  State<MaterialCreationScreen> createState() => _MaterialCreationScreenState();
}

class _MaterialCreationScreenState extends State<MaterialCreationScreen> {
  final TextEditingController _materialNameController = TextEditingController();
  final TextEditingController _materialVolumeController = TextEditingController();
  final TextEditingController _materialDateController = TextEditingController();

  List<PlatformFile> attachments = [];
  String? _selectedUnit;

  // Список единиц измерения
  final List<String> _units = [
    'шт',
    'кг',
    'т',
    'м',
    'м²',
    'м³',
    'л',
    'упак.',
    'рулон',
    'плита',
    'Другое'
  ];

  void leaveHandler() {
    Navigator.pop(context);
  }

  // Методы для работы с файлами (аналогичные ReportCreationScreen)
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

  // Метод для показа ошибок
  void _showErrorSnackbar(String message) {
    FileUtils.showErrorSnackbar(message, context);
  }

  // Метод для выбора даты
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
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

    if (picked != null) {
      setState(() {
        _materialDateController.text = "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseHeader(
        title: "Добавление материала",
        subtitle: widget.address,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Форма ввода данных о материале
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Наименование материала
                  _buildTextFieldWithTitle(
                    title: "Наименование материала",
                    controller: _materialNameController,
                    hintText: "Введите наименование материала",
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  // Объем материала и единицы измерения в одной строке
                  Row(
                    children: [
                      // Объем материала
                      Expanded(
                        flex: 2,
                        child: _buildTextFieldWithTitle(
                          title: "Объем материала",
                          controller: _materialVolumeController,
                          hintText: "0.00",
                          keyboardType: TextInputType.number,
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Единицы измерения
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Единицы измерения",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedUnit,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                hintText: "Выберите",
                              ),
                              items: _units.map((String unit) {
                                return DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedUnit = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Выберите единицу';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Дата приема
                  _buildTextFieldWithTitle(
                    title: "Дата приема",
                    controller: _materialDateController,
                    hintText: "Выберите дату",
                    readOnly: true,
                    onTap: _selectDate,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  // Раздел вложений
                  _buildAttachmentsSection(),
                ],
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
                      _saveMaterial();
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

  // Вспомогательный метод для создания поля ввода с заголовком
  Widget _buildTextFieldWithTitle({
    required String title,
    required TextEditingController controller,
    String? hintText,
    bool isRequired = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            if (isRequired) ...[
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
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: readOnly ? const Icon(Icons.calendar_today) : null,
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Поле обязательно для заполнения';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Метод сохранения материала
  void _saveMaterial() {
    // Валидация полей
    if (_materialNameController.text.isEmpty) {
      _showErrorSnackbar('Введите наименование материала');
      return;
    }

    if (_materialVolumeController.text.isEmpty) {
      _showErrorSnackbar('Введите объем материала');
      return;
    }

    if (_selectedUnit == null) {
      _showErrorSnackbar('Выберите единицы измерения');
      return;
    }

    if (_materialDateController.text.isEmpty) {
      _showErrorSnackbar('Выберите дату приема');
      return;
    }

    // TODO: Реализовать логику сохранения материала с вложениями
    print('Наименование материала: ${_materialNameController.text}');
    print('Объем материала: ${_materialVolumeController.text}');
    print('Единицы измерения: $_selectedUnit');
    print('Дата приема: ${_materialDateController.text}');
    print('Количество вложений: ${attachments.length}');

    for (var file in attachments) {
      print('Файл: ${file.name}, Размер: ${file.size}');
    }

    // Показываем успешное сообщение
    FileUtils.showSuccessSnackbar('Материал успешно добавлен', context);

    // Закрываем экран через короткую задержку
    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.pop(context);
    });
  }

  // Список с вложениями
  Widget _buildAttachmentsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
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
          if (attachments.isEmpty)
            Text(
              "Документы, фото и другие файлы",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          else
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3,
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

  @override
  void dispose() {
    _materialNameController.dispose();
    _materialVolumeController.dispose();
    _materialDateController.dispose();
    super.dispose();
  }
}