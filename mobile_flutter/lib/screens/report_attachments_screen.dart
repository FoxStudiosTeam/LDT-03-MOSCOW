import 'package:flutter/material.dart';
import 'package:mobile_flutter/domain/entities.dart';
import 'package:mobile_flutter/widgets/base_header.dart';
import 'package:mobile_flutter/attachment/attachments_download.dart';

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
          : _buildAttachmentsList(context),
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

  Widget _buildAttachmentsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: data.attachments.length,
      itemBuilder: (context, index) {
        final attachment = data.attachments[index];
        return _buildAttachmentCard(attachment, context);
      },
    );
  }

  Widget _buildAttachmentCard(Attachment attachment, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и кнопка скачивания
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attachment.originalFilename,
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
                          _getFileType(attachment.originalFilename),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => _downloadAttachment(attachment, context),
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

              const SizedBox(height: 12),

              // Информация о файле
              _buildFileInfo(attachment),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileInfo(Attachment attachment) {
    return Row(
      children: [
        // Иконка типа файла
        _getFileIcon(attachment.originalFilename),
        const SizedBox(width: 12),

        // Информация
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Тип: ${_getFileType(attachment.originalFilename)}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _downloadAttachment(Attachment attachment, BuildContext context) async {
    try {
      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text("Открываем файл"),
            ],
          ),
        ),
      );

      // Используем существующий метод загрузки
      await downloadTroughBrowser(attachment.uuid);

      // Закрываем диалог
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Файл ${attachment.originalFilename} открывается..."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Закрываем диалог при ошибке
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ошибка при открытии файла: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  String _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'PDF документ';
      case 'doc':
      case 'docx':
        return 'Word документ';
      case 'xls':
      case 'xlsx':
        return 'Excel таблица';
      case 'jpg':
      case 'jpeg':
        return 'Изображение JPEG';
      case 'png':
        return 'Изображение PNG';
      case 'gif':
        return 'Анимированное изображение';
      case 'zip':
        return 'ZIP архив';
      case 'rar':
        return 'RAR архив';
      default:
        return 'Файл $extension';
    }
  }
}