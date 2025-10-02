import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/fox_header.dart';
import 'package:mobile_flutter/widgets/punishment_item_card.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:mobile_flutter/domain/entities.dart';

class CreatePunishmentScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String objectTitle;
  final Map<int, String> statues;
  final Map<String, String> documents;
  final bool isNear;

  const CreatePunishmentScreen({
    super.key,
    required this.di,
    required this.objectTitle,
    required this.statues,
    required this.documents,
    required this.isNear,
  });

  @override
  State<CreatePunishmentScreen> createState() => _CreatePunishmentScreenState();
}

class _CreatePunishmentScreenState extends State<CreatePunishmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Контроллеры для полей ввода
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _regulationDocController = TextEditingController();
  final TextEditingController _correctionDateController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  // Переменные для селектора и чекбокса
  String? _selectedStatus;
  String? _selectedDocUuid;
  bool _isWorkStopped = false;

  // Отфильтрованный список документов для поиска
  List<String> _filteredDocuments = [];

  @override
  void initState() {
    super.initState();
    _filteredDocuments = widget.documents.values.toList();
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

  void _filterDocuments(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDocuments = widget.documents.values.toList();
      } else {
        _filteredDocuments = widget.documents.values.toList()
            .where((doc) => doc.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _savePunishment() {
    // if (_formKey.currentState!.validate()) {
    //   final data = PunishmentItem(
    //       correction_date_plan: correction_date_plan,
    //       is_suspend: is_suspend,
    //       place: place,
    //       punish_datetime: punish_datetime,
    //       punishment: punishment,
    //       punish_item_status: punish_item_status,
    //       title: title,
    //       uuid: uuid)
    //   Navigator.pop(context, PunishmentItemCreateRequest(punishment: PunishmentItemCard(
    //       di: di,
    //       data: data,
    //       statuses: statuses,
    //       docs: docs,
    //       isNear: isNear),
    // } TODO govno
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
        title: "Новое нарушение",
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

                      _buildSectionTitle("Нормативный документ"),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedDocUuid,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: widget.documents.entries.map((doc) {
                          return DropdownMenuItem<String>(
                            value: doc.key,
                            child: ConstrainedBox(
                              constraints:
                              const BoxConstraints(maxWidth: 250),
                              child: Text(
                                doc.value,
                                softWrap: true,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDocUuid = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Выберите документ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Дата устранения
                      _buildSectionTitle("Плановая дата устранения"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _correctionDateController,
                        decoration: InputDecoration(
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
                        items: widget.statues.entries.map((status) {
                          return DropdownMenuItem<String>(
                            value: status.key.toString(),
                            child: Text(status.value),
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

                      // Вложение
                      _buildSectionTitle("Вложения"),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Кнопки сохранения и добавления вложений в одной строке
              Container(
                height: 50,
                child: Row(
                  children: [
                    // Кнопка сохранения
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _savePunishment,// TODO: Реализовать сохранение нарушения
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
                    const SizedBox(width: 12),


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
    _correctionDateController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}