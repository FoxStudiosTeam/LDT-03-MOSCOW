import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/domain/entities.dart'
    show ProjectStatus, FoxPolygon, ProjectStatusExtension;
import 'package:mobile_flutter/widgets/fox_header.dart';

class ObjectScreen extends StatefulWidget {
  final IDependencyContainer di;
  final String title;
  final ProjectStatus status;
  final FoxPolygon polygon;

  const ObjectScreen({
    super.key,
    required this.di,
    required this.title,
    required this.status,
    required this.polygon,
  });

  @override
  State<ObjectScreen> createState() => _ObjectScreenState();
}

class _ObjectScreenState extends State<ObjectScreen> {
  bool _showPoints = false;

  @override
  Widget build(BuildContext context) {
    final Color textColor = Colors.black; // Можно заменить на тему
    final Color pointBlockColor = Colors.grey.shade200; // Вместо фиолетового

    void leaveHandler() {
      Navigator.pop(context);
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
          onPressed: () {
            showBlurMenu(context);
          },
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
              Divider(height: 1),
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
              Divider(height: 1),
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

  void showBlurMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
            ),

            DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.2,
              maxChildSize: 0.8,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const Text(
                        'Меню',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Сканировать'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Настройки'),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }



}
