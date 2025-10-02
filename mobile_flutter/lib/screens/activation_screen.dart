import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/widgets/base_header.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/fox_header.dart';
import 'package:mobile_flutter/utils/style_utils.dart';

class ChecklistActivationScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String address;
  final String projectUuid;

  const ChecklistActivationScreen({super.key, required this.di, required this.address, required this.projectUuid});

  @override
  State<ChecklistActivationScreen> createState() => _ChecklistActivationScreenState();
}

class _ChecklistActivationScreenState extends State<ChecklistActivationScreen> {
  List<ChecklistItem> checklistItems = [
    ChecklistItem(
      number: "1",
      header: "Наличие разрешительной, организационно-технологической, рабочей документации.",
      title: "",
      subtitle: "",
      status: ChecklistStatus.notRequired,
      comment: "",
    ),
    ChecklistItem(
      number: "1.1",
      title: "Наличие приказа на ответственное лицо, осуществляющего строительство (производство работ).",
      subtitle: "(п. 5.3. СП 48.13330.2019. Изм. №1. Организация строительства)",
      status: ChecklistStatus.notSelected,
      comment: "",
    ),
    ChecklistItem(
      number: "1.2",
      title: "Наличие приказа на ответственное лицо, осуществляющее строительный контроль (с указанием идентификационного номера в НРС в области строительства).",
      subtitle: "(п. 5.3. СП 48.13330.2019. Изм. №1. Организация строительства)",
      status: ChecklistStatus.notSelected,
      comment: "",
    ),
    ChecklistItem(
      number: "1.3",
      title: "Наличие приказа на ответственное лицо, осуществляющее строительный контроль (с указанием идентификационного номера в НРС в области строительства).",
      subtitle: "(п. 5.3. СП 48.13330.2019. Изм. №1. Организация строительства)",
      status: ChecklistStatus.notSelected,
      comment: "",
    ),
    ChecklistItem(
      number: "1.4",
      title: "Наличие проектной документации со штампом «В производство работ».",
      subtitle: "(п. 5.5. СП 48.13330.2019. Изм. №1. Организация строительства)",
      status: ChecklistStatus.notSelected,
      comment: "",
    ),
    ChecklistItem(
      number: "1.5",
      title: "Наличие проекта производства работ (утвержденного руководителем подрядной организации, согласованного Заказчиком, проектировщиком, эксплуатирующей организацией).",
      subtitle: "(п. 6.4., п. 6.7., п. 6.9. СП 48.13330.2019. Изм. №1. Организация строительства)",
      status: ChecklistStatus.notSelected,
      comment: "",
    ),

    ChecklistItem(
      number: "2",
      header: "Инженерная подготовка строительной площадки.",
      title: "",
      subtitle: "",
      status: ChecklistStatus.notRequired,
      comment: "",
    ),
    ChecklistItem(
      number: "2.1",
      title: "Наличие акта геодезической разбивочной основы, принятых знаков (реперов).",
      subtitle: "(п. 7.2. СП 48.13330.2019. Изм. №1. Организация строительства)",
      status: ChecklistStatus.notSelected,
      comment: "",
    ),
    ChecklistItem(
      number: "2.2",
      title: "Наличие генерального плана (ситуационного плана).",
      subtitle: "(п. 7.6. СП 48.13330.2019. Изм. №1. Организация строительства)",
      status: ChecklistStatus.notSelected,
      comment: "",
    ),
    ChecklistItem(
      number: "2.3",
      title: "Фактическое размещение временной инженерной и бытовой инфраструктуры площадки (включая стоянку автотранспорта) согласно проекту организации. Соответствие размещённых временных инфраструктуры требованиям электробезопасности, пожарных, санитарно-эпидемиологических норм и правил.",
      subtitle: "(п. 7.10., п. 7.34. СП 48.13330.2019. Изм. №1. Организация строительства)",
      status: ChecklistStatus.notSelected,
      comment: "",
    ),
    ChecklistItem(
      number: "2.4",
      title: "Наличие пунктов очистки или мойки колес транспортных средств на выездах со строительной площадки.",
      subtitle: "(п. 7.13. СП 48.13330.2019. Изм. №1. Организация строительства)",
      status: ChecklistStatus.notSelected,
      comment: "",
    ),
    ChecklistItem(
      number: "2.5",
      title: "Наличие бункеров или контейнеров для сбора отдельно бытового и отдельно строительного мусора.",
      subtitle: "(п. 7.13. СП 48.13330.2019. Изм. №1. Организация строительства)",
      status: ChecklistStatus.notSelected,
      comment: "",
    ),
    ChecklistItem(
      number: "2.6",
      title: "Наличие информационных щитов (знаков) с указанием: \n- наименование объекта; \n- наименование Застройщика (технического Заказчика); \n- наименование подрядной организации; \n- наименование проектной организации; \n- сроки строительства; \n- контактные телефоны ответственных по приказу лиц по организации.",
      subtitle: "(п. 7.13. СП 48.13330.2019. Изм. №1. Организация строительства)",
      status: ChecklistStatus.notSelected,
      comment: "",
    ),
    ChecklistItem(
      number: "2.7",
      title: "Наличие стендов пожарной безопасности с указанием на схеме мест источников воды, средств пожаротушения.",
      subtitle: "(п. 7.13. СП 48.13330.2019. Изм. №1. Организация строительства)",
      status: ChecklistStatus.notSelected,
      comment: "",
    ),
  ];


  List<String> attachments = [];

  void leaveHandler() {
    Navigator.pop(context);
    Navigator.pop(context); //два чтобы менюшка закрывалась
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseHeader(
        title: "Чек-лист форма 1",
        subtitle: widget.address,
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Список пунктов чек-листа
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: checklistItems.length,
              itemBuilder: (context, index) {
                return _buildChecklistItem(checklistItems[index], index);
              },
            ),
          ),

          // Раздел вложений
          if (attachments.isNotEmpty) _buildAttachmentsSection(),

          // Нижняя панель с кнопками
          Padding(padding: EdgeInsetsGeometry.all(16),
            child: Container(
            height: 50,
            child: Row(
              children: [
                // Кнопка сохранения
                Expanded(
                  child: ElevatedButton(
                    onPressed:() {
                      // Navigator.pop(context);
                      for (var v in checklistItems) {
                        if (v.status == ChecklistStatus.notSelected || v.status == ChecklistStatus.no) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Все поля должны быть ДА или НЕ ТРЕБУЕТСЯ!"),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }
                      // TODO: ACTIVATE OBJECT AND BACK
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
                      'Подтвердить',
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
                    onPressed: () => _openAddAttachmentMenu(context),//TODO ВЛОЖЕНИЯ
                    icon: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),),
        ],
      ),
    );
  }



  Widget _buildChecklistItem(ChecklistItem item, int index) {


    return item.header != null ?
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.w500
              ),
              children: [
                TextSpan(
                  text: "${item.number}.  ",
                  // style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: item.header),
              ],
            ),
          ),
      )
    : Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Номер и название пункта
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: "${item.number}  ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: item.title),
                TextSpan(
                  text: "\n${item.subtitle}",
                  style: const TextStyle(fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
                )
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Селектор статуса
          _buildStatusSelector(item, index),

          const SizedBox(height: 16),

          // Поле для комментария
          TextField(
            decoration: const InputDecoration(
              hintText: "Комментарий...",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                checklistItems[index] = item.copyWith(comment: value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector(ChecklistItem item, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatusButton(
          "Да",
          ChecklistStatus.yes,
          item.status,
          index,
          Colors.green,
        ),
        _buildStatusButton(
          "Не требуется",
          ChecklistStatus.notRequired,
          item.status,
          index,
          Colors.orange,
        ),
        _buildStatusButton(
          "Нет",
          ChecklistStatus.no,
          item.status,
          index,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatusButton(
      String text,
      ChecklistStatus status,
      ChecklistStatus currentStatus,
      int index,
      Color activeColor,
      ) {
    bool isSelected = currentStatus == status;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              checklistItems[index] = checklistItems[index].copyWith(status: status);
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? activeColor : Colors.grey[200],
            foregroundColor: isSelected ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Вложения",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: attachments.map((attachment) {
              return Chip(
                label: Text(attachment),
                onDeleted: () {
                  setState(() {
                    attachments.remove(attachment);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ChecklistItem {
  final String? header;
  final String number;
  final String title;
  final String subtitle;
  final ChecklistStatus status;
  final String comment;

  ChecklistItem({
    this.header,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.comment,
  });

  ChecklistItem copyWith({
    String? number,
    String? title,
    ChecklistStatus? status,
    String? comment,
  }) {
    return ChecklistItem(
      header: header,
      number: number ?? this.number,
      title: title ?? this.title,
      subtitle: subtitle,
      status: status ?? this.status,
      comment: comment ?? this.comment,
    );
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
            title: const Text('Добавить вложение'),
            onTap: () {
              Navigator.pop(ctx);//TODO ДОБАВИТЬ ФАЙЛ
            },
          ),
          const Divider(height: 1),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.photo),
            title: const Text('Добавить фото'),
            onTap: () {
              Navigator.pop(ctx);//TODO ДОБАВИТЬ ФОТО
            },
          ),
        ],
      ),
    );
  }

enum ChecklistStatus {
  notSelected,
  yes,
  notRequired,
  no,
}