import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  @override
  Widget build(BuildContext context) {
    return OSMViewer(controller: 
      SimpleMapController(
          initPosition: GeoPoint(
            latitude: 47.4358055,
            longitude: 8.4737324
          ),
          markerHome: MarkerIcon(
            assetMarker: AssetMarker(
              image: AssetImage(''), // пустая строка — возможно, не сработает
            ),
          )
      ),
      zoomOption: ZoomOption(initZoom: 16, minZoomLevel: 11),
    );
  }
}