import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/screens/punishment_items_screen.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';

class PunishmentCard extends StatelessWidget {
  final Punishment data;
  final Map<int, String> statuses;
  final String addr;
  final IDependencyContainer di;

  const PunishmentCard({
    super.key,
    required this.statuses,
    required this.di,
    required this.data,
    required this.addr,
  });

  void _openPunishmentCardMenu(BuildContext context) {
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
            leading: const Icon(Icons.visibility),
            title: const Text('Просмотреть детали'),
            onTap: () {
              Navigator.pop(ctx);
              _handleViewDetails(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.edit),
            title: const Text('Редактировать'),
            onTap: () {
              Navigator.pop(ctx);
              _handleEditPunishment();
            },
          ),
          const Divider(height: 1),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.download),
            title: const Text('Скачать документ'),
            onTap: () {
              Navigator.pop(ctx);
              _handleDownloadDocument();
            },
          ),
        ],
      ),
    );
  }

  void _handleViewDetails(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PunishmentItemsScreen(
                di: di,
                punishmentUuid: data.uuid,
                addr: addr
            )
        )
    );
  }

  void _handleEditPunishment() {
    // TODO: Реализовать редактирование предписания
    print("Редактировать предписание: ${data.customNumber}");
  }

  void _handleDownloadDocument() {
    // TODO: Реализовать скачивание документа
    print("Скачать документ предписания: ${data.customNumber}");
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1: // Активный
        return Colors.orange;
      case 2: // Выполнен
        return Colors.green;
      case 3: // Отменен
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


  @override
  Widget build(BuildContext context) {
    final statusText = statuses[data.punishmentStatus] ?? "Неизвестный статус";
    final formattedDate = "${data.punishDatetime.day}."
        "${data.punishDatetime.month}."
        "${data.punishDatetime.year} "
        "${data.punishDatetime.hour}:${data.punishDatetime.minute.toString().padLeft(2, '0')}";

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PunishmentItemsScreen(
                di: di,
                punishmentUuid: data.uuid,
                addr: addr,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и кнопка меню
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Предписание №${data.customNumber ?? "N/A"}",
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
                    onPressed: () => _openPunishmentCardMenu(context),
                    icon: SvgPicture.asset(
                      'assets/icons/menu-kebab.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Дата выдачи
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: "Дата выдачи:",
                value: formattedDate,
              ),
              const SizedBox(height: 8),

              // Статус
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: _getStatusColor(data.punishmentStatus),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Статус: $statusText",
                    style: TextStyle(
                      fontSize: 14,
                      color: _getStatusColor(data.punishmentStatus),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}