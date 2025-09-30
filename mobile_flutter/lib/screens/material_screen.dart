import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/utils/StyleUtils.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/fox_header.dart';

class MaterialsScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String objectTitle;

  const MaterialsScreen({
    super.key,
    required this.di,
    required this.objectTitle,
  });

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

// Модель материала
class MaterialItem {
  final String name;
  final String volume;
  final DateTime deliveryDate;
  final MaterialStatus status;

  MaterialItem({
    required this.name,
    required this.volume,
    required this.deliveryDate,
    required this.status,
  });
}

// Статусы материала
enum MaterialStatus {
  delivered,
  pending,
  qualityCheck,
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  // Пример данных для материалов
  final List<MaterialItem> materials = [
    MaterialItem(
      name: "Цемент М500",
      volume: "50 тонн",
      deliveryDate: DateTime(2024, 1, 15),
      status: MaterialStatus.delivered,
    ),
    MaterialItem(
      name: "Арматура 12мм",
      volume: "2 тонны",
      deliveryDate: DateTime(2024, 1, 20),
      status: MaterialStatus.pending,
    ),
    MaterialItem(
      name: "Песок строительный",
      volume: "100 м³",
      deliveryDate: DateTime(2024, 1, 25),
      status: MaterialStatus.qualityCheck,
    ),
    MaterialItem(
      name: "Щебень гранитный",
      volume: "80 м³",
      deliveryDate: DateTime(2024, 2, 1),
      status: MaterialStatus.delivered,
    ),
    MaterialItem(
      name: "Кирпич облицовочный",
      volume: "10 000 шт",
      deliveryDate: DateTime(2024, 2, 5),
      status: MaterialStatus.pending,
    ),
  ];

  void leaveHandler() {
    Navigator.pop(context);
  }

  void _openMaterialMenu(BuildContext context, int materialIndex) {
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
            leading: const Icon(Icons.download),
            title: const Text('Скачать ТТН'),
            onTap: () {
              Navigator.pop(ctx);
              _handleDownloadTTN(materialIndex);
            },
          ),
          const Divider(height: 1),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.description),
            title: const Text('Скачать паспорт кач.'),
            onTap: () {
              Navigator.pop(ctx);
              _handleDownloadQualityPassport(materialIndex);
            },
          ),
          const Divider(height: 1),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.science),
            title: const Text('Запросить исследование'),
            onTap: () {
              Navigator.pop(ctx);
              _handleRequestResearch(materialIndex);
            },
          ),
        ],
      ),
    );
  }

  void _handleDownloadTTN(int materialIndex) {
    // Обработка скачивания ТТН
    print("Скачать ТТН для: ${materials[materialIndex].name}");
    // TODO: Реализовать логику скачивания ТТН
  }

  void _handleDownloadQualityPassport(int materialIndex) {
    // Обработка скачивания паспорта качества
    print("Скачать паспорт качества для: ${materials[materialIndex].name}");
    // TODO: Реализовать логику скачивания паспорта качества
  }

  void _handleRequestResearch(int materialIndex) {
    // Обработка запроса исследования
    print("Запросить исследование для: ${materials[materialIndex].name}");
    // TODO: Реализовать логику запроса исследования
  }

  Color _getStatusColor(MaterialStatus status) {
    switch (status) {
      case MaterialStatus.delivered:
        return Colors.green;
      case MaterialStatus.pending:
        return Colors.orange;
      case MaterialStatus.qualityCheck:
        return Colors.blue;
    }
  }

  String _getStatusText(MaterialStatus status) {
    switch (status) {
      case MaterialStatus.delivered:
        return "Доставлен";
      case MaterialStatus.pending:
        return "Ожидает доставки";
      case MaterialStatus.qualityCheck:
        return "Проверка качества";
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
        title: "Материалы",
        subtitle: widget.objectTitle,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: materials.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final material = materials[index];
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
                            material.name,
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
                          onPressed: () => _openMaterialMenu(context, index),
                          icon: SvgPicture.asset(
                            'assets/icons/menu-kebab.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Объем
                    _buildInfoRow(
                      icon: Icons.scale,
                      label: "Объем:",
                      value: material.volume,
                    ),
                    const SizedBox(height: 8),

                    // Дата поставки
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: "Дата поставки:",
                      value: _formatDate(material.deliveryDate),
                    ),
                    const SizedBox(height: 8),

                    // Статус
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: _getStatusColor(material.status),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStatusText(material.status),
                          style: TextStyle(
                            fontSize: 14,
                            color: _getStatusColor(material.status),
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