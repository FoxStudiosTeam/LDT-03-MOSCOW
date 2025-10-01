import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/screens/punishments_screen.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/fox_header.dart';

class UpdatePunishmentScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String objectTitle;
  final Map<String, dynamic>? initialData; // Данные для редактирования
  final String projectUuid;
  final String addr;

  const UpdatePunishmentScreen({
    super.key,
    required this.di,
    required this.objectTitle,
    this.initialData,
    required this.projectUuid,
    required this.addr,
  });

  @override
  State<UpdatePunishmentScreen> createState() => _UpdatePunishmentScreenState();
}

class _UpdatePunishmentScreenState extends State<UpdatePunishmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Контроллеры для полей ввода
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _regulationDocController = TextEditingController();
  final TextEditingController _correctionDatePlanController = TextEditingController();
  final TextEditingController _correctionDateFactController = TextEditingController();
  final TextEditingController _correctionDateInfoController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  // Переменные для селектора и чекбокса
  String? _selectedStatus;
  bool _isWorkStopped = false;

  // Список статусов для селектора
  final List<String> _statuses = [
    'Замечание',
    'Критическая',
    'Значительная',
    'Не значительная',
    'Исправлено'
  ];

  // Список нормативных документов для поискового селектора
  final List<String> _regulationDocuments = [
    'ГОСТ 31937-2011 Здания и сооружения. Правила обследования и мониторинга технического состояния',
    'СП 20.13330.2016 Нагрузки и воздействия',
    'СП 22.13330.2016 Основания зданий и сооружений',
    'СП 70.13330.2012 Несущие и ограждающие конструкции',
    'Федеральный закон №384-ФЗ Технический регламент о безопасности зданий и сооружений',
    'ГОСТ Р 54257-2010 Надежность строительных конструкций и оснований',
    'СНиП 3.03.01-87 Несущие и ограждающие конструкции',
    'Пособие к СНиП 2.03.01-84 по проектированию бетонных и железобетонных конструкций',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.initialData != null) {
      setState(() {
        _titleController.text = widget.initialData!['title'] ?? '';
        _regulationDocController.text = widget.initialData!['regulation_doc'] ?? '';
        _correctionDatePlanController.text = widget.initialData!['correction_date_plan'] ?? '';
        _correctionDateFactController.text = widget.initialData!['correction_date_fact'] ?? '';
        _correctionDateInfoController.text = widget.initialData!['correction_date_info'] ?? '';
        _commentController.text = widget.initialData!['comment'] ?? '';
        _selectedStatus = widget.initialData!['status'];
        _isWorkStopped = widget.initialData!['is_work_stopped'] ?? false;
      });
    }
  }

  void leaveHandler() {
    Navigator.pop(context);
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
              _handleAddFile();
            },
          ),
          const Divider(height: 1),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.photo),
            title: const Text('Добавить фото'),
            onTap: () {
              Navigator.pop(ctx);
              _handleAddPhoto();
            },
          ),
        ],
      ),
    );
  }

  void _handleAddFile() {
    // TODO: Реализовать добавление файла
    print("Добавить файл");
  }

  void _handleAddPhoto() {
    // TODO: Реализовать добавление фото
    print("Добавить фото");
  }


  void _updatePunishment() {
    if (_formKey.currentState!.validate()) {
      // TODO: Реализовать обновление нарушения
      print("Обновление нарушения...");
      print("Наименование: ${_titleController.text}");
      print("Нормативный документ: ${_regulationDocController.text}");
      print("Дата устранения план: ${_correctionDatePlanController.text}");
      print("Дата устранения факт: ${_correctionDateFactController.text}");
      print("Сведения о переносе: ${_correctionDateInfoController.text}");
      print("Статус: $_selectedStatus");
      print("Остановка работ: $_isWorkStopped");
      print("Комментарий: ${_commentController.text}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Действие выполнено успешно!'),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
      Navigator.pop(context);
    }
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
        title: "Редактирование нарушения",
        subtitle: widget.objectTitle,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Наименование нарушения
                      _buildSectionTitle("Наименование нарушения"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: "Введите наименование нарушения",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Поле обязательно для заполнения';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Нормативный документ (поисковый селектор)
                      _buildSectionTitle("Нормативный документ"),
                      const SizedBox(height: 8),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return _regulationDocuments.where((String option) {
                            return option
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          _regulationDocController.text = selection;
                        },
                        fieldViewBuilder: (
                            BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted,
                            ) {
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              hintText: "Начните вводить название документа...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          );
                        },
                        optionsViewBuilder: (
                            BuildContext context,
                            AutocompleteOnSelected<String> onSelected,
                            Iterable<String> options,
                            ) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final String option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option),
                                      onTap: () {
                                        onSelected(option);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Дата устранения ПЛАН
                      _buildSectionTitle("Дата устранения ПЛАН"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _correctionDatePlanController,
                        decoration: InputDecoration(
                          hintText: "Укажите плановую дату устранения",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Дата устранения ФАКТ
                      _buildSectionTitle("Дата устранения ФАКТ"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _correctionDateFactController,
                        decoration: InputDecoration(
                          hintText: "Укажите фактическую дату устранения",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Сведения о переносе
                      _buildSectionTitle("Сведения о переносе"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _correctionDateInfoController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "Введите сведения о переносе срока",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Статус
                      _buildSectionTitle("Статус"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: _statuses.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Выберите статус';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Остановка работ
                      Row(
                        children: [
                          Checkbox(
                            value: _isWorkStopped,
                            onChanged: (bool? value) {
                              setState(() {
                                _isWorkStopped = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            "Остановка работ (да/нет)",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Комментарий
                      _buildSectionTitle("Комментарий"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _commentController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Введите комментарий",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Вложения
                      _buildSectionTitle("Вложения"),
                      const SizedBox(height: 8),
                      // TODO: Добавить список существующих вложений?????


                    ],
                  ),
                ),
              ),

              // Кнопки сохранения и добавления вложений
              Container(
                height: 50,
                child: Row(
                  children: [
                    // Кнопка сохранения
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updatePunishment,
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
                          'Обновить',
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
        ),
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

  @override
  void dispose() {
    _titleController.dispose();
    _regulationDocController.dispose();
    _correctionDatePlanController.dispose();
    _correctionDateFactController.dispose();
    _correctionDateInfoController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}