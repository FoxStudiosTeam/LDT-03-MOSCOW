import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_flutter/widgets/base_header.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;


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

class NameAndNumber {
  String name;
  String number;
  NameAndNumber(this.name, this.number);
}

NameAndNumber? extractNameAndNumber(String text) {
  var reg = RegExp(r'Наименование\s*[—-]\s*(.+?)[,\.]\s*([^\s]+)');
  var match = reg.firstMatch(text);
  if (match == null) {return null;}
  var name = match.group(1)?.trim();
  var number = match.group(2)?.trim();
  if (name == null || number == null) return null;
  return NameAndNumber(name, number);
}

String? extractVolume(String text) {
  var reg = RegExp(r'Объем\s*[—-]\s*([^\s]+)');
  var match = reg.firstMatch(text);
  if (match == null) {return null;}
  var volume = match.group(1)?.trim();
  return volume;
}


class MaybeTTN {
  String? name;
  String? number;
  String? volume;
  MaybeTTN(this.name, this.number, this.volume);
  MaybeTTN.extract(String text) {
    var nameAndNumber = extractNameAndNumber(text);
    var volume = extractVolume(text);
    name = nameAndNumber?.name;
    number = nameAndNumber?.number;
    this.volume = volume;
  }
}

class TTNRecord {
  final String name;
  final String number;
  final String volume;
  const TTNRecord({
    required this.name, 
    required this.number, 
    required this.volume
  });
}

class TTNScanScreen extends StatefulWidget {
  final void Function(TTNRecord record)? onSubmit;
  final void Function(String error)? onErr;
  final void Function()? onBack;

  const TTNScanScreen({super.key, this.onSubmit, this.onErr, this.onBack});

  @override
  State<TTNScanScreen> createState() => _TTNScanScreenState();
}

class _TTNScanScreenState extends State<TTNScanScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  
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
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  Widget build(BuildContext ctx) {
    if (!_isCameraInitialized) {return _cameraNotInitialized(ctx);}
    return Container();
  }

  Widget _cameraNotInitialized(BuildContext ctx){
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
          const Text('Разрешите доступ к камере для распознавания'),
          const Text('Пожалуйста 🙏'),
          TextButton(
            onPressed: () => {
              _initCamera()
            }, 
            child: const Text('Разрешить'),
          ),
          TextButton(
            onPressed: () => {
              _initCamera()
            }, 
            child: const Text('Ввести вручную'),
          ),
        ],
      )),
    );
  }
}