import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:mobile_flutter/utils/StyleUtils.dart';
import '../domain/entities.dart';
import '../screens/object_screen.dart';
import '../di/dependency_container.dart';

class ObjectCard extends StatefulWidget {
  final String title;
  final String address;
  final String projectUuid;
  final ProjectStatus status;
  final IDependencyContainer di;
  final FoxPolygon polygon;

  const ObjectCard({
    super.key,
    required this.title,
    required this.address,
    required this.projectUuid,
    required this.status,
    required this.di,
    required this.polygon,
  });

  @override
  State<ObjectCard> createState() => _ObjectCardState();
}

class _ObjectCardState extends State<ObjectCard> {
  bool _expanded = false;
  bool _showPoints = false;

  @override
  Widget build(BuildContext context) {
    // Цвет для текста и иконок (например, основной цвет темы или черный)
    final Color textAndIconColor = Colors.black; // Или Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ObjectScreen(
                address: widget.address,
                projectUuid: widget.projectUuid,
                di: widget.di,
                title: widget.title,
                status: widget.status,
                polygon: widget.polygon,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Адрес: ${widget.title}",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: textAndIconColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _expanded = !_expanded;
                        if (!_expanded) _showPoints = false;
                      });
                    },
                    child: Iconify(
                      _expanded ? Mdi.keyboard_arrow_up : Mdi.keyboard_arrow_down,
                      color: textAndIconColor,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Статус (оставляю как есть, предполагая что внутри toRenderingString() тоже используется тема)
              widget.status.toRenderingString(),
              const SizedBox(height: 8),
              Text("Заказчик: "),
              const SizedBox(height: 8),

              if (_expanded)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      margin: const EdgeInsets.only(top: 8),
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
                    const SizedBox(height: 12),

                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showPoints = !_showPoints;
                        });
                      },
                      icon: Iconify(
                        _showPoints ? Mdi.keyboard_arrow_up : Mdi.keyboard_arrow_down,
                        color: textAndIconColor,
                      ),
                      label: Text(
                        _showPoints ? "Скрыть точки на полигоне" : "Показать точки на полигоне",
                        style: TextStyle(color: textAndIconColor),
                      ),
                    ),

                    if (_showPoints)
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          itemCount: widget.polygon.points.length,
                          itemBuilder: (context, index) {
                            final point = widget.polygon.points[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: FoxThemeButtonTextColor,
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
                                      color: textAndIconColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Широта: ${point.latitude.toStringAsFixed(6)}",
                                    style: TextStyle(fontSize: 14, color: textAndIconColor),
                                  ),
                                  Text(
                                    "Долгота: ${point.longitude.toStringAsFixed(6)}",
                                    style: TextStyle(fontSize: 14, color: textAndIconColor),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}