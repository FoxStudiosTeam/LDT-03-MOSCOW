import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart' show ProjectStatus, FoxPolygon, ProjectStatusExtension;
import 'package:mobile_flutter/screens/punishments_screen.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/fox_header.dart';
import 'package:mobile_flutter/screens/report_screen.dart';

class ObjectScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String projectUuid;
  final String title;
  final ProjectStatus status;
  final FoxPolygon polygon;
  final String? customer;
  final String? foreman;
  final String? inspector;
  final String address;

  const ObjectScreen({
    super.key,
    required this.di,
    required this.projectUuid,
    required this.title,
    required this.status,
    required this.polygon,
    required this.customer,
    required this.foreman,
    required this.inspector,
    required this.address
  });

  @override
  State<ObjectScreen> createState() => _ObjectScreenState();
}

class _ObjectScreenState extends State<ObjectScreen> {
  bool _showPoints = false;

  void _navigateToReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportScreen(
          di: widget.di,
          objectTitle: widget.title, // Передаем название объекта если нужно
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = Colors.black;
    final Color pointBlockColor = Colors.grey.shade200;

    void leaveHandler() {
      Navigator.pop(context);
    }

    void openBottomBlurMenu() {
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
              leading: const Icon(Icons.file_copy),
              title: const Text('Предписания'),
              onTap: () {
                Navigator.push(ctx, MaterialPageRoute(builder: (_) => PunishmentsScreen(di: widget.di, projectUuid: widget.projectUuid, addr: widget.address)));
              },
            ),
            const Divider(height: 1),
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: const Icon(Icons.account_balance_outlined),
              title: const Text('Материалы'),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
            const Divider(height: 1),
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: const Icon(Icons.file_open),
              title: const Text('Отчет'),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToReports(); // Переход к отчетам
              },
            ),
            const Divider(height: 1),
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: const Icon(Icons.file_upload),
              title: const Text('Прикрепить файлы'),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
            const Divider(height: 1),
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              leading: const Icon(Icons.file_present_sharp),
              title: const Text('Нарушения'),
              textColor: FoxThemeButtonActiveBackground,
              iconColor: FoxThemeButtonActiveBackground,
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      );
    }

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
        title: "Объект",
        subtitle: widget.title,
        rightIcon: IconButton(
          onPressed: openBottomBlurMenu,
          icon: SvgPicture.asset(
            'assets/icons/menu-kebab.svg',
            width: 32,
            height: 32,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Информация об объекте",
                style: TextStyle(fontSize: 20, color: textColor),
              ),
              const Divider(height: 1),
              const SizedBox(height: 16),
              widget.status.toRenderingString(),
              const SizedBox(height: 16),

              // Карта с полигоном
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: widget.polygon.getCenter(),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                        userAgentPackageName:
                        'ru.foxstudios.digital_building_journal',
                      ),
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: widget.polygon.points,
                            color: Colors.blue.withOpacity(0.3),
                            borderColor: Colors.blue,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Информация о участниках
              _buildInfoCard(),

              const SizedBox(height: 16),

              const SizedBox(height: 24),
              const Divider(height: 1),

              // Заголовок с кнопкой для скрытия/показа точек
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Точки полигона',
                    style: TextStyle(fontSize: 20, color: textColor),
                  ),
                  IconButton(
                    icon: _showPoints
                        ? SvgPicture.asset(
                      "assets/icons/arrow-top.svg",
                      width: 32,
                      height: 32,
                    )
                        : SvgPicture.asset(
                      "assets/icons/arrow-bottom.svg",
                      width: 32,
                      height: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPoints = !_showPoints;
                      });
                    },
                  ),
                ],
              ),
              const Divider(height: 1),
              const SizedBox(height: 12),

              if (_showPoints)
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.polygon.points.length,
                  itemBuilder: (context, index) {
                    final point = widget.polygon.points[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: pointBlockColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Точка ${index + 1}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Широта: ${point.latitude.toStringAsFixed(6)}",
                            style: TextStyle(fontSize: 14, color: textColor),
                          ),
                          Text(
                            "Долгота: ${point.longitude.toStringAsFixed(6)}",
                            style: TextStyle(fontSize: 14, color: textColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Участники проекта",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            _buildParticipantRow("Заказчик:", widget.customer ?? "Не указан"),
            const SizedBox(height: 8),
            _buildParticipantRow("Подрядчик:", widget.foreman ?? "Не указан"),
            const SizedBox(height: 8),
            _buildParticipantRow(
                "Ответственный инспектор:", widget.inspector ?? "Не указан"),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}