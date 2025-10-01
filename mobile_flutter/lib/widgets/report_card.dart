import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart';

import 'blur_menu.dart';

class ReportCard extends StatelessWidget {
  final ReportAndAttachments data;
  final IDependencyContainer di;
  final Role? role;
  final Map<int, String> statuses;

  const ReportCard({
    super.key,
    required this.data,
    required this.di,
    required this.role,
    required this.statuses,
  });

  void _openReportMenu(BuildContext context) {
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
            title: const Text('Вложения'),
            onTap: () {
              Navigator.pop(ctx);
              _handleAttachments();
            },
          ),
          const Divider(height: 1),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: const Text('Принять', style: TextStyle(color: Colors.green)),
            onTap: () {
              Navigator.pop(ctx);
              _handleApprove();
            },
          ),
          const Divider(height: 1),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.cancel, color: Colors.red),
            title: const Text('Отклонить', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(ctx);
              _handleReject();
            },
          ),
        ],
      ),
    );
  }

  void _handleAttachments() {
    // Обработка просмотра вложений
    // TODO: Реализовать логику просмотра вложений
  }

  void _handleApprove() {
    // TODO: Реализовать логику принятия отчета
  }

  void _handleReject() {
    // TODO: Реализовать логику отклонения отчета
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange;
      case 0:
        return Colors.green;
      case 2:
        return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(int status) {
    return statuses[status] ?? "Unknown status";
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data.report.title,
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
                  onPressed: () => _openReportMenu(context),
                  icon: SvgPicture.asset(
                    'assets/icons/menu-kebab.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Дата создания
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: "Дата создания:",
              value: "${data.report.reportDate.day}."
                  "${data.report.reportDate.month}."
                  "${data.report.reportDate.year}.",
            ),
            const SizedBox(height: 8),

            // Дата проверки
            _buildInfoRow(
              icon: Icons.verified,
              label: "Дата проверки:",
              value: data.report.checkDate != null
                  ? "${data.report.reportDate.day}."
                    "${data.report.reportDate.month}."
                    "${data.report.reportDate.year}."
                  : "Не проверено",
            ),
            const SizedBox(height: 8),

            // Статус
            Row(
              children: [
                Icon(
                  Icons.circle,
                  color: _getStatusColor(data.report.status),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(data.report.status),
                  style: TextStyle(
                    fontSize: 14,
                    color: _getStatusColor(data.report.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}