import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/utils/StyleUtils.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/fox_header.dart';

class ReportScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String objectTitle;

  const ReportScreen({
    super.key,
    required this.di,
    required this.objectTitle,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}
// Модель отчета
class Report {
  final String workName;
  final DateTime createdAt;
  DateTime? checkedAt;
  ReportStatus status;

  Report({
    required this.workName,
    required this.createdAt,
    this.checkedAt,
    required this.status,
  });
}

// Статусы отчета
enum ReportStatus {
  pending,
  approved,
  rejected,
}

class _ReportScreenState extends State<ReportScreen> {
  // Пример данных для отчетов
  final List<Report> reports = [
    Report(
      workName: "Заливка фундамента",
      createdAt: DateTime(2024, 1, 15),
      checkedAt: DateTime(2024, 1, 18),
      status: ReportStatus.pending,
    ),
    Report(
      workName: "Монтаж стен",
      createdAt: DateTime(2024, 1, 20),
      checkedAt: DateTime(2024, 1, 22),
      status: ReportStatus.approved,
    ),
    Report(
      workName: "Установка кровли",
      createdAt: DateTime(2024, 1, 25),
      checkedAt: null,
      status: ReportStatus.rejected,
    ),
    Report(
      workName: "Отделочные работы",
      createdAt: DateTime(2024, 2, 1),
      checkedAt: null,
      status: ReportStatus.pending,
    ),
  ];

  void leaveHandler() {
    Navigator.pop(context);
  }

  void _openReportMenu(BuildContext context, int reportIndex) {
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
              _handleAttachments(reportIndex);
            },
          ),
          const Divider(height: 1),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: const Text('Принять', style: TextStyle(color: Colors.green)),
            onTap: () {
              Navigator.pop(ctx);
              _handleApprove(reportIndex);
            },
          ),
          const Divider(height: 1),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.cancel, color: Colors.red),
            title: const Text('Отклонить', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(ctx);
              _handleReject(reportIndex);
            },
          ),
        ],
      ),
    );
  }

  void _handleAttachments(int reportIndex) {
    // Обработка просмотра вложений
    print("Просмотр вложений для отчета: ${reports[reportIndex].workName}");
    // TODO: Реализовать логику просмотра вложений
  }

  void _handleApprove(int reportIndex) {
    setState(() {
      reports[reportIndex].status = ReportStatus.approved;
      reports[reportIndex].checkedAt = DateTime.now();
    });
    // TODO: Реализовать логику принятия отчета
    print("Отчет принят: ${reports[reportIndex].workName}");
  }

  void _handleReject(int reportIndex) {
    setState(() {
      reports[reportIndex].status = ReportStatus.rejected;
      reports[reportIndex].checkedAt = DateTime.now();
    });
    // TODO: Реализовать логику отклонения отчета
    print("Отчет отклонен: ${reports[reportIndex].workName}");
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.approved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return "На рассмотрении";
      case ReportStatus.approved:
        return "Принят";
      case ReportStatus.rejected:
        return "Отклонен";
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
        title: "Отчеты",
        subtitle: widget.objectTitle,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = reports[index];
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
                    // Заголовок и кнопка меню
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            report.workName,
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
                          onPressed: () => _openReportMenu(context, index),
                          icon: SvgPicture.asset(
                            'assets/icons/menu-kebab.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Дата создания
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: "Дата создания:",
                      value: _formatDate(report.createdAt),
                    ),
                    const SizedBox(height: 8),

                    // Дата проверки
                    _buildInfoRow(
                      icon: Icons.verified,
                      label: "Дата проверки:",
                      value: report.checkedAt != null
                          ? _formatDate(report.checkedAt!)
                          : "Не проверено",
                    ),
                    const SizedBox(height: 8),

                    // Статус
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: _getStatusColor(report.status),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStatusText(report.status),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getStatusColor(report.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
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

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }
}

