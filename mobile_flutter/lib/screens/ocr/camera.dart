import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

class OcrCameraScreen extends StatefulWidget {
  const OcrCameraScreen({super.key});

  @override
  State<OcrCameraScreen> createState() => _OcrCameraScreenState();
}

class _OcrCameraScreenState extends State<OcrCameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }
  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    setState(() {
        _isCameraInitialized = status.isGranted;
    });
  }


  Future<void> _initCamera() async {
    await _requestCameraPermission();
    if (!_isCameraInitialized) {
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
      // For now, just print the path
      log('Picture taken: ${image.path}');
      // Later you can pass this to flutter_tesseract_ocr
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
              onPressed: _takePicture,
              shape: const CircleBorder(),
              backgroundColor: Colors.white,
              child: const Icon(Icons.camera),
            ),
          ),
        ],
      ),
    );
  }
}
