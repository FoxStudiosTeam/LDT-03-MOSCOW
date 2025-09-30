import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';

import '../domain/entities.dart';
import '../di/dependency_container.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
        leading: Iconify(
          Mdi.map_marker_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Адрес проекта: ${widget.title}"),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text("Статус проекта:", style: TextStyle(color: textColor)),
                  const SizedBox(width: 8),
                  widget.status.toRenderingString(),
                ],
              ),
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
                        userAgentPackageName: 'com.example.yourapp',
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

              // Заголовок с кнопкой для скрытия/показа точек
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Точки полигона',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: Iconify(
                      _showPoints ? Mdi.keyboard_arrow_up : Mdi.keyboard_arrow_down,
                      color: textColor,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPoints = !_showPoints;
                      });
                    },
                  ),
                ],
              ),

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
}
