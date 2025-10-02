import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/main.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:uuid/uuid.dart';

class StylishPunishmentItemCard extends StatelessWidget {
  final DataPunishmentItem item;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isEditable;
  final Map<int, String> statuses;
  const StylishPunishmentItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onEdit,
    this.onDelete,
    required this.statuses,
    this.isEditable = false,
  });

  void _openItemCardMenu(BuildContext context) {
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
          if (isEditable) ...[
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: const Icon(Icons.edit),
              title: const Text('Редактировать нарушение'),
              onTap: () {
                Navigator.pop(ctx);
                onEdit?.call();
              },
            ),
            const Divider(height: 1),
          ],
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.visibility),
            title: const Text('Просмотреть детали'),
            onTap: () {
              Navigator.pop(ctx);
              onTap?.call();
            },
          ),
          if (isEditable) ...[
            const Divider(height: 1),
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: Icon(Icons.delete, color: Colors.red.shade600),
              title: Text(
                'Удалить нарушение',
                style: TextStyle(color: Colors.red.shade600),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onDelete?.call();
              },
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return const Color.fromARGB(255, 20, 149, 255);
      case 1:
        return const Color.fromARGB(255, 212, 210, 71);
      case 2:
        return const Color.fromARGB(255, 228, 152, 38);
      case 3:
        return const Color.fromARGB(255, 255, 102, 0);
      case 4:
        return const Color.fromARGB(255, 255, 17, 0);
      default:
        return const Color.fromARGB(255, 88, 88, 88);
    }
  }

  String _getStatusText(int status) {
    return statuses[status] ?? "Unknown status";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 10, left: 20, right: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openItemCardMenu(context),
                    icon: SvgPicture.asset(
                      'assets/icons/menu-kebab.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Regulation document
              if (item.regulationDoc.isNotEmpty)
                _buildInfoRow(
                  icon: Icons.description,
                  label: "Документ:",
                  value: item.regulationDoc,
                ),

              // Dates section
              ..._buildDatesSection(),

              // Status
              _buildStatusRow(),

              // Comment (if exists)
              if (item.comment.isNotEmpty) _buildCommentSection(),

              // Attachments (if exist)
              if (item.attachments.isNotEmpty) _buildAttachmentsSection(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDatesSection() {
    final widgets = <Widget>[];
    
    if (item.correctionDatePlan.isNotEmpty) {
      widgets.addAll([
        _buildInfoRow(
          icon: Icons.calendar_today,
          label: "План устранения:",
          value: item.correctionDatePlan,
        ),
        const SizedBox(height: 4),
      ]);
    }
    
    if (item.correctionDateFact.isNotEmpty) {
      widgets.addAll([
        _buildInfoRow(
          icon: Icons.event_available,
          label: "Факт устранения:",
          value: item.correctionDateFact,
        ),
        const SizedBox(height: 4),
      ]);
    }
    
    if (item.correctionDateInfo.isNotEmpty) {
      widgets.addAll([
        _buildInfoRow(
          icon: Icons.info,
          label: "Информация:",
          value: item.correctionDateInfo,
        ),
        const SizedBox(height: 4),
      ]);
    }
    
    return widgets;
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        Icon(
          Icons.circle,
          color: _getStatusColor(item.status),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          "Статус: ${_getStatusText(item.status)}",
          style: TextStyle(
            fontSize: 14,
            color: _getStatusColor(item.status),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12, right: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.comment, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                'Комментарий:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.comment,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                'Вложения (${item.attachments.length}):',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: item.attachments.map((file) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      size: 14,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _truncateFileName(file.name),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _truncateFileName(String fileName) {
    if (fileName.length <= 20) return fileName;
    return '${fileName.substring(0, 17)}...';
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

class DataPunishmentItem {
  final String title;
  final String regulationDoc;
  final String correctionDatePlan;
  final String correctionDateFact;
  final String correctionDateInfo;
  final String comment;
  final int status;
  final List<PlatformFile> attachments;

  DataPunishmentItem({
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

QueuedRequestModel queuedPunishmentItem(
  DataPunishmentItem item,
  String address,
) {
  final now = DateTime.now();
  return QueuedRequestModel(
    id: Uuid().v4(),
    timestamp: now.millisecondsSinceEpoch,
    title: "Зафиксированные нарушения",
    url: Uri.parse(APIRootURI).resolve('/api/punishment/create_punishment_item').toString(),
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: {
      "correction_date_plan": item.correctionDatePlan,
      "is_suspended": false,
      "place": address,
      "punish_datetime": item.correctionDateFact,
      "punishment_item_status": item.status,
      "regulation_doc": item.regulationDoc,
      "title": item.title,
      "comment": item.comment,
    },
  );
}
