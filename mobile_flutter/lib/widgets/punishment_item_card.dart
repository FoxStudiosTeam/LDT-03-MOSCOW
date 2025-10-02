import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/screens/punishment_item_screen.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/screens/update_punishment_item.dart';
class PunishmentItemCard extends StatelessWidget {
  final PunishmentItem data;
  final List<Attachment>? atts;
  final Map<int, String> statuses;
  final IDependencyContainer di;
  final Map<String, String> docs;
  final Role? role;
  final bool isNear;

  const PunishmentItemCard({
    super.key,
    required this.di,
    this.atts,
    required this.data,
    required this.statuses,
    required this.docs,
    this.role,
    required this.isNear,
  });

  void _openPunishmentItemMenu(BuildContext context) {
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
          if (role == Role.ADMIN || (role == Role.CUSTOMER || role == Role.INSPECTOR)&&isNear)
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: const Icon(Icons.edit),
              title: const Text('Редактировать'),
              onTap: () {
                Navigator.pop(ctx);
                _handleEditItem();
              },
            ),
          if (atts != null)
            const Divider(height: 1),
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: const Icon(Icons.attach_file),
              title: const Text('Вложения'),
              onTap: () {
                Navigator.pop(ctx);
                _handleViewAttachments(context);
              },
            ),
        ],
      ),
    );
  }

  void _handleEditItem() {
    // TODO: Реализовать редактирование
    print("Редактировать нарушение: ${data.title}");
  }

  void _handleViewAttachments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PunishmentItemScreen(
          di: di,
          addr: data.title,
          atts: atts!,
        ),
      ),
    );
  }

  String boolToString(bool is_suspend) {
    return is_suspend ? "Да" : "Нет";
  }

  String dateToString(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }

  String nullableDateToString(DateTime? date, String nullString) {
    return date != null ? dateToString(date) : nullString;
  }

  String dateTimeToString(DateTime date) {
    return "${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusText = statuses[data.punish_item_status] ?? "Неизвестный статус";
    final docText = docs[data.regulation_doc ?? ''] ?? 'Нормативный документ не указан';

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 10, left: 20, right: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и кнопка меню
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => _openPunishmentItemMenu(context),
                  icon: SvgPicture.asset(
                    'assets/icons/menu-kebab.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Основная информация
            _buildInfoRow(
              icon: Icons.description,
              label: "Нормативный документ:",
              value: docText,
            ),
            const SizedBox(height: 8),

            _buildInfoRow(
              icon: Icons.calendar_today,
              label: "Дата выдачи:",
              value: dateTimeToString(data.punish_datetime),
            ),
            const SizedBox(height: 8),

            _buildInfoRow(
              icon: Icons.location_on,
              label: "Местоположение:",
              value: data.place,
            ),
            const SizedBox(height: 8),

            _buildInfoRow(
              icon: Icons.pause_circle,
              label: "Приостановка работ:",
              value: boolToString(data.is_suspend),
            ),
            const SizedBox(height: 8),

            _buildInfoRow(
              icon: Icons.event_available,
              label: "Плановая дата устранения:",
              value: dateToString(data.correction_date_plan),
            ),
            const SizedBox(height: 8),

            _buildInfoRow(
              icon: Icons.event_note,
              label: "Фактическая дата устранения:",
              value: nullableDateToString(data.correction_date_fact, "Нарушение еще не устранено"),
            ),
            const SizedBox(height: 8),

            // Статус
            Row(
              children: [
                Icon(
                  Icons.circle,
                  color: _getStatusColor(data.punish_item_status),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  "Статус: $statusText",
                  style: TextStyle(
                    fontSize: 14,
                    color: _getStatusColor(data.punish_item_status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Примечание (если есть)
            if (data.comment != null && data.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.comment,
                label: "Примечание:",
                value: data.comment!,
              ),
            ],

            // Сведения о переносе (если есть)
            if (data.correction_date_info != null && data.correction_date_info!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.info,
                label: "Сведения о переносе:",
                value: data.correction_date_info!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}