import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/screens/object_screen.dart';
import 'package:latlong2/latlong.dart';

import '../domain/entities.dart';

class ObjectCard extends StatefulWidget {
  final String title;
  final String content;
  final IDependencyContainer di;
  final FoxPolygon polygon;

  const ObjectCard({
    super.key,
    required this.title,
    required this.content,
    required this.di,
    required this.polygon,
  });

  @override
  State<ObjectCard> createState() => _ObjectCardState();
}
class _ObjectCardState extends State<ObjectCard> {


  @override
  void initState() {
    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ObjectScreen(
                di: widget.di,
                title: widget.title,
                content: widget.content,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(widget.content),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 200,
                alignment: Alignment.center,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: widget.polygon.getCenter(),
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.yourapp',
                    ),

                    // Добавляем слой с полигоном
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
            ],
          ),
        ),
      ),
    );
  }
}
