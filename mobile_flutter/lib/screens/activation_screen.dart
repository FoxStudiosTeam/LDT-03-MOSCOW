import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/fox_header.dart';

class ChecklistActivationScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String objectTitle;

  const ChecklistActivationScreen({
    super.key,
    required this.di,
    required this.objectTitle,
  });

  @override
  State<ChecklistActivationScreen> createState() => _ChecklistActivationScreenState();
}
//TODO Убрать заглушку
class _ChecklistActivationScreenState extends State<ChecklistActivationScreen> {
  List<ChecklistItem> checklistItems = [
    ChecklistItem(
      number: "1.1",
      title: "Оформление наряд-допуска на безопасное проведение работ в местах охранной зоны:",
      status: ChecklistStatus.notSelected,
      comment: "",
    ),
    ChecklistItem(
      number: "1.2",
      title: "Оформление наряд-допуска на безопасное проведение работ в местах охранной зоны:",
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
      appBar: FoxHeader(
        leftIcon: IconButton(
          onPressed: leaveHandler,
          icon: SvgPicture.asset(
            'assets/icons/arrow-left.svg',
            width: 32,
            height: 32,
          ),
        ),
        title: "Чек-лист форма 1",
        subtitle: widget.objectTitle,
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

          // Сохранить и добавить вложения
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                // Кнопка сохранения
                Expanded(
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                      Navigator.pop(context);
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
                    onPressed: () => _openAddAttachmentMenu(context),//TODO ВЛОЖЕНИЯ
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

  Widget _buildChecklistItem(ChecklistItem item, int index) {
    return Container(
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
                  text: "${item.number} ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: item.title),
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
              fontSize: 12,
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
}

class ChecklistItem {
  final String number;
  final String title;
  final ChecklistStatus status;
  final String comment;

  ChecklistItem({
    required this.number,
    required this.title,
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
      number: number ?? this.number,
      title: title ?? this.title,
      status: status ?? this.status,
      comment: comment ?? this.comment,
    );
  }
}

enum ChecklistStatus {
  notSelected,
  yes,
  notRequired,
  no,
}