import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/majesticons.dart';

class CurrentLocationMarkerLayer extends StatelessWidget {
  final LatLng? location;
  final double markerSize;
  final void Function()? onTap;

  const CurrentLocationMarkerLayer({
    Key? key,
    required this.location,
    this.markerSize = 64,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (location == null) return const SizedBox.shrink();

    return MarkerLayer(
      markers: [
        Marker(
          point: location!,
          width: markerSize,
          height: markerSize,
          child: IconButton(
            onPressed: onTap,
            style: ButtonStyle(
            ),
            icon: Stack(
              children: [
                // Blur effect behind icon
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Iconify(
                    Majesticons.map_marker,
                    color: Colors.black.withOpacity(1.0),
                    size: markerSize,
                  ),
                ),
                // Foreground icon
                Iconify(
                  Majesticons.map_marker,
                  color: Colors.red,
                  size: markerSize,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
