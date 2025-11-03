import 'package:flutter/material.dart';
import 'package:mobile_flutter/utils/file_utils.dart';
import 'package:file_picker/file_picker.dart';
  
Widget AttachmentsSection(
  BuildContext context,
  List<PlatformFile> attachments,
  void Function(int) onDeleted,
) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Вложения",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              if (attachments.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '(${attachments.length})',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (attachments.isEmpty)
            Text(
              "Документы, фото и другие файлы",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          else
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8,
                  runSpacing: 8,
                  children: attachments.map((file) {
                    return Chip(
                      avatar: FileUtils.getFileIcon(file.extension ?? ''),
                      label: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            file.name,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            FileUtils.formatFileSize(file.size),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      onDeleted: () {
                        onDeleted(attachments.indexOf(file));
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }