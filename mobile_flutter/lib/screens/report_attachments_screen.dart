import 'package:flutter/material.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/widgets/base_header.dart';

class ReportAttachmentsScreen extends StatelessWidget {
  final ReportAndAttachments data;

  const ReportAttachmentsScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final attachments = data.attachments;
    final report = data.report;

    return Scaffold(
      appBar: BaseHeader(
        title: "Вложения отчета",
        subtitle: report.title,
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.grey[50],
      body: attachments.isEmpty
          ? _buildEmptyState()
          : _buildAttachmentsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.attach_file,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Нет вложений",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "К этому отчету не прикреплено файлов",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.attachments.length,
      itemBuilder: (context, index) {
        final attachment = data.attachments[index];
        return _buildAttachmentCard(attachment);
      },
    );
  }

  Widget _buildAttachmentCard(Attachment attachment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Иконка файла
              _getFileIcon(attachment.name),
              const SizedBox(width: 16),

              // Информация о файле
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attachment.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Размер: ${_formatFileSize(attachment.size)}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (attachment.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        attachment.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Кнопка скачивания (если нужна)
              IconButton(
                onPressed: () {
                  // Показываем сообщение, что скачивание недоступно
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Для скачивания необходим доступ к di"),
                    ),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.download,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    IconData icon;
    Color color;

    switch (extension) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        color = Colors.blue;
      case 'xls':
      case 'xlsx':
        icon = Icons.table_chart;
        color = Colors.green;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        icon = Icons.photo;
        color = Colors.amber;
      case 'zip':
      case 'rar':
        icon = Icons.archive;
        color = Colors.orange;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Icon(icon, size: 32, color: color);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}