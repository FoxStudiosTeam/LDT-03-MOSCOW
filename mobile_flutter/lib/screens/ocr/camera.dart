import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/tabler.dart';
import 'package:mobile_flutter/bridges/ocr.dart';
import 'package:mobile_flutter/widgets/base_header.dart';
import 'package:mobile_flutter/widgets/fox_header.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;

class OcrCameraScreen extends StatefulWidget {
  const OcrCameraScreen({super.key});

  @override
  State<OcrCameraScreen> createState() => _OcrCameraScreenState();
}

final red = img.ColorRgb8(255, 0, 0);
final green = img.ColorRgb8(0, 255, 0);
final blue = img.ColorRgb8(0, 0, 255);

// Future<Uint8List> drawBoxes(Uint8List imageBytes, List<OcrBox> boxes) async {
//   var image = img.decodeImage(imageBytes)!;
//   for (final box in boxes) {
//     image = img.drawRect(
//       image,
//       x1: box.left,
//       y1: box.top,
//       x2: box.right,
//       y2: box.bottom,
//       color: blue,
//       thickness: 1,
//     );
//   }
//   return Uint8List.fromList(img.encodeJpg(image));
// }



      // img.drawLine(image, x1: a.centerX.toInt(), y1: a.centerY.toInt(), x2: b.centerX.toInt(), y2: b.centerY.toInt(), color: img.ColorRgb8(255, 0, 0));


const String cameraSvg ='<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><rect width="24" height="24" fill="none"/><g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"><path d="M5 7h1a2 2 0 0 0 2-2a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1a2 2 0 0 0 2 2h1a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2"/><path d="M9 13a3 3 0 1 0 6 0a3 3 0 0 0-6 0"/></g></svg>';


Future<Uint8List> rotateClockwise(Uint8List bytes) async {
  final image = img.decodeImage(bytes)!;
  final rotated = img.copyRotate(image, angle: 90);
  return Uint8List.fromList(img.encodeJpg(rotated));
}

Future<Uint8List> rotateCounterClockwise(Uint8List bytes) async {
  final image = img.decodeImage(bytes)!;
  final rotated = img.copyRotate(image, angle: -90);
  return Uint8List.fromList(img.encodeJpg(rotated));
}

class _OcrCameraScreenState extends State<OcrCameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  Uint8List? imageWithBoxes = null;
  bool _isCameraInitialized = false;
  Uint8List? imageCache = null;
  OcrPage? ocrPage = null;
  @override
  void initState() {
    super.initState();
    _initCamera();
  }
  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  Future<void> _initCamera() async {
    var granted = await _requestCameraPermission();
    if (!granted) {
      return;
    }
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      // final image3 = await _cameraController!.takePicture();
      // log('OCR: Picture taken: ${image3.path}');
      // imageCache = null;
      // boxes = [];
      if (imageCache == null) {
        final file = File('/data/user/0/ru.foxstudios.mobile_flutter/cache/CAP4881106055615520049.jpg');
        final Uint8List bytes = await file.readAsBytes();
        imageCache = img.encodeJpg(img.decodeImage(bytes)!);
      }
      var image = imageCache!;

      if (ocrPage == null) {
        ocrPage = await OcrBridge.getPage(image);
      }

      // image = await drawBoxes(image, boxes);
      // image = await processBoxes(image, boxes);

      setState(() {
        imageWithBoxes = image;
      });

      // final ByteData data = await rootBundle.load('assets/4mo.png');
      // Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      // final Uint8List rotated = await rotateClockwise(bytes);
      // final boxes = await OcrBridge.getBoxes(rotated);
      // final boxed = await drawBoxes(rotated, boxes);
      // final Uint8List rotatedBack = boxed;
      // setState(() {
      //   imageWithBoxes = rotatedBack;
      // });
    } catch (e) {
      log('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        appBar: BaseHeader(
          title: "Распознать", 
          subtitle: "ТНН",
          onBack: () => Navigator.pop(context),
        ),
        body: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Разрешите доступ к камере'),
            const Text('Пожалуйста 🙏'),
            TextButton(
              onPressed: () => {
                _initCamera()
              }, 
              child: const Text('Разрешить'),
            )
          ],
        )),
      );
    }

    final size = MediaQuery.of(context).size;
    final isPortrait = size.height >= size.width;

    return Scaffold(
      appBar: BaseHeader(
        title: "Распознать", 
        subtitle: "ТНН",
        onBack: () => Navigator.pop(context),
        onMore: () => setState(()=>imageWithBoxes = null),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: CameraPreview(_cameraController!)
          ),
          imageWithBoxes != null ? Image.memory(
            imageWithBoxes!,
            fit: BoxFit.contain, // adjust how the image scales
          ) : Container(),
          Positioned(
            // todo!: fix non-portrait btn
            top: isPortrait ? null : (size.height / 2 - 28),
            bottom: isPortrait ? 48 : null,
            left: isPortrait ? (size.width / 2 - 28) : null,
            right: isPortrait ? null : 48,
            child: FloatingActionButton(
              backgroundColor: Colors.grey.shade300,
              onPressed: _takePicture,
              shape: const CircleBorder(),
              child: Iconify(
                cameraSvg,
                color: Colors.grey.shade700,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
