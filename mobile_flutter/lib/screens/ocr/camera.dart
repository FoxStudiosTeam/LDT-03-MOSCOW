import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/tabler.dart';
import 'package:permission_handler/permission_handler.dart';

class OcrCameraScreen extends StatefulWidget {
  const OcrCameraScreen({super.key});

  @override
  State<OcrCameraScreen> createState() => _OcrCameraScreenState();
}

const String cameraSvg ='<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><rect width="24" height="24" fill="none"/><g fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"><path d="M5 7h1a2 2 0 0 0 2-2a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1a2 2 0 0 0 2 2h1a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2"/><path d="M9 13a3 3 0 1 0 6 0a3 3 0 0 0-6 0"/></g></svg>';

class _OcrCameraScreenState extends State<OcrCameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

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
      final image = await _cameraController!.takePicture();
      log('Picture taken: ${image.path}');
      String text = await FlutterTesseractOcr.extractText(image.path, language: 'rus',
        args: {
          "psm": "4",
          "preserve_interword_spaces": "1",
        });
      print("OCR: $text");
      
    } catch (e) {
      log('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    if (!_isCameraInitialized) {
      return Scaffold(
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
              child: const Text('Рарешить'),
            )
          ],
        )),
      );
    }

    final size = MediaQuery.of(context).size;
    final isPortrait = size.height >= size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: CameraPreview(_cameraController!)
          ),
          Positioned(
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
