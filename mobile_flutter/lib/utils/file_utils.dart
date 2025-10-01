import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileUtils {
  // Метод для выбора файлов
  static Future<List<PlatformFile>?> pickFiles({
    required BuildContext context,
    List<String>? allowedExtensions,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'zip', 'rar'],
      ).onError((error, stackTrace) {
        _handleFilePickerError(error, context);
        return null;
      });

      return result?.files;
    } catch (e) {
      _handleFilePickerError(e, context);
      return null;
    }
  }

  // Метод для выбора фото
  static Future<List<PlatformFile>?> pickImages({
    required BuildContext context,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      ).onError((error, stackTrace) {
        _handleFilePickerError(error, context);
        return null;
      });

      return result?.files;
    } catch (e) {
      _handleFilePickerError(e, context);
      return null;
    }
  }

  // Обработка ошибок file_picker
  static void _handleFilePickerError(dynamic error, BuildContext context) {
    String errorMessage = 'Ошибка при выборе файлов';

    if (error is Exception) {
      final errorString = error.toString();
      if (errorString.contains('PERMISSION_DENIED')) {
        errorMessage = 'Доступ к файлам запрещен. Проверьте разрешения приложения';
      } else if (errorString.contains('CANCELLED')) {
        // Пользователь отменил выбор - не показываем ошибку
        return;
      } else {
        errorMessage = 'Ошибка: $errorString';
      }
    }

    showErrorSnackbar(errorMessage, context);
  }

  // Показать ошибку
  static void showErrorSnackbar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Успешная привязка
  static void showSuccessSnackbar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Метод для получения иконки файла по расширению
  static Icon getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue);
      case 'xls':
      case 'xlsx':
        return const Icon(Icons.table_chart, color: Colors.green);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return const Icon(Icons.photo, color: Colors.amber);
      case 'zip':
      case 'rar':
        return const Icon(Icons.archive, color: Colors.orange);
      default:
        return const Icon(Icons.insert_drive_file);
    }
  }

  // Метод для форматирования размера файла
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Получить расширение файла из имени
  static String getFileExtension(String fileName) {
    try {
      return fileName.split('.').last.toLowerCase();
    } catch (e) {
      return '';
    }
  }

  // Проверить, является ли файл изображением
  static bool isImageFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  // Проверить, является ли файл документом
  static bool isDocumentFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'].contains(extension);
  }

  // Проверить, является ли файл архивом
  static bool isArchiveFile(String fileName) {
    final extension = getFileExtension(fileName);
    return ['zip', 'rar', '7z'].contains(extension);
  }
}