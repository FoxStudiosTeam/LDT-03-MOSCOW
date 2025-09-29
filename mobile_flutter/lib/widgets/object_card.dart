import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/screens/object_screen.dart';

import '../domain/entities.dart';

class ObjectCard extends StatefulWidget {
  final String title;
  final String content;
  final IDependencyContainer di;
  final Polygon polygon;

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
  late final MapController mapController;

  bool _mapReady = false;

  @override
  void initState() {
    super.initState();

    mapController = MapController(
      initPosition: widget.polygon.getCenter(),
    );
  }

  void _onMapReady(bool tl) async {
    if (!_mapReady) {
      _mapReady = true;

      await mapController.drawRect(
        RectOSM(
          key: 'rect',
          centerPoint: widget.polygon.getCenter(),
          distance: 120.0,
          color: const Color.fromARGB(255, 255, 0, 0),
          strokeWidth: 10.0,
        ),
      );
    }
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
                height: 100,
                alignment: Alignment.center,
                child: OSMFlutter(
                  controller: mapController,
                  osmOption: OSMOption(
                    zoomOption: ZoomOption(initZoom: 15),
                  ),
                  onMapIsReady: _onMapReady,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
