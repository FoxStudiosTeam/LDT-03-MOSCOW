import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/tabler.dart';
import 'package:mobile_flutter/auth/auth_storage_provider.dart';
import 'package:mobile_flutter/bridges/ocr.dart';
import 'package:mobile_flutter/di/dependency_container.dart';
import 'package:mobile_flutter/materials/materials_provider.dart';
import 'package:mobile_flutter/utils/network_utils.dart';
import 'package:mobile_flutter/utils/style_utils.dart';
import 'package:mobile_flutter/utils/file_utils.dart';
import 'package:mobile_flutter/widgets/attachments.dart';
import 'package:mobile_flutter/widgets/base_header.dart';
import 'package:mobile_flutter/widgets/fox_header.dart';
import 'package:mobile_flutter/widgets/blur_menu.dart';
import 'package:mobile_flutter/widgets/funny_things.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

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
    log(text);
    var nameAndNumber = extractNameAndNumber(text);
    var volume = extractVolume(text);
    name = nameAndNumber?.name;
    number = nameAndNumber?.number;
    this.volume = volume;
  }
}

class TTNRecord {
  final String name;
  final double number;
  final int unit;
  final String projectId;
  final List<PlatformFile> attachments;
  const TTNRecord({
    required this.name,
    required this.number,
    required this.unit,
    required this.projectId,
    required this.attachments,
  });
}

class TTNScanScreen extends StatefulWidget {
  final void Function(TTNRecord record)? onSubmit;
  final void Function()? onBack;
  final Map<int, String> measurements;
  final IDependencyContainer di;
  final String projectId;
  final String address;

  const TTNScanScreen({
    super.key, this.onSubmit, this.onBack,
     required this.measurements, required this.di,
     required this.projectId, required this.address
    });

  @override
  State<TTNScanScreen> createState() => _TTNScanScreenState();
}

class _TTNScanScreenState extends State<TTNScanScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  final MaybeTTN _maybeTTN = MaybeTTN(null, null, null);
  bool _inCamera = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countController = TextEditingController();

  List<PlatformFile> attachments = [];
  String? _selectedUnit;

  // Список единиц измерения
  List<String> _units = [];


  @override
  void initState() {
    super.initState();
    _initCamera();
    _units = widget.measurements.values.toList();
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

  Future<void> _takePictureAndMerge() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      setState(() {
        _isProcessing = true;
      });
      final image = await _cameraController!.takePicture();
      log('OCR: Picture taken: ${image.path}');

      final file = File(image.path);
      final Uint8List rawBytes = await file.readAsBytes();
      await file.delete();
      var bytes = img.encodeJpg(img.decodeImage(rawBytes)!);

      var text = await OcrBridge.getText(bytes);
      setState(() {
        _isProcessing = false;
      });
      if (text == null) {
        return;
      }
      var v = MaybeTTN.extract(text);
      setState(() {
        _maybeTTN.name = v.name ?? _maybeTTN.name;
        _maybeTTN.number = v.number ?? _maybeTTN.number;
        _maybeTTN.volume = v.volume ?? _maybeTTN.volume;
        log("OCR: Extracted name: ${_maybeTTN.name}");
        log("OCR: Extracted number: ${_maybeTTN.number}");
        log("OCR: Extracted volume: ${_maybeTTN.volume}");
        _nameController.text = _maybeTTN.name ?? _nameController.text;
        _countController.text = _maybeTTN.number ?? _countController.text;
        _inCamera = false;
      });
    } catch (e) {
      log('Error taking picture: $e');
    }
    return;
  }

  // Методы для работы с вложениями
  Future<void> _pickFiles() async {
    final files = await FileUtils.pickFiles(context: context);
    if (files != null && files.isNotEmpty) {
      setState(() {
        attachments.addAll(files);
      });
      FileUtils.showSuccessSnackbar('Файлы добавлены', context);
    }
  }

  Future<void> _pickImages() async {
    final images = await FileUtils.pickImages(context: context);
    if (images != null && images.isNotEmpty) {
      setState(() {
        attachments.addAll(images);
      });
      FileUtils.showSuccessSnackbar('Фото добавлены', context);
    }
  }

  void _openAddAttachmentMenu(BuildContext context) {
    showBlurBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.attach_file),
            title: const Text('Добавить файл'),
            onTap: () {
              Navigator.pop(ctx);
              _pickFiles();
            },
          ),
          const Divider(height: 1),
          ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: const Icon(Icons.photo),
            title: const Text('Добавить фото'),
            onTap: () {
              Navigator.pop(ctx);
              _pickImages();
            },
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext ctx) {
    return _inCamera ?
    _isCameraInitialized ?
    _cameraScan(ctx) : _cameraNotInitialized(ctx) : _TTNEditor(ctx);
  }

  Widget _cameraScan(BuildContext ctx) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height >= size.width;

    return Scaffold(
      appBar: BaseHeader(
        title: "Распознать ТТН",
        subtitle: "Наведите камеру на документ",
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
              child: CameraPreview(_cameraController!)
          ),

          // Кнопка съемки
          Positioned(
            top: isPortrait ? null : (size.height / 2 - 28),
            bottom: isPortrait ? 48 : null,
            left: isPortrait ? (size.width / 2 - 28) : null,
            right: isPortrait ? null : 48,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: _isProcessing ? null : () => _takePictureAndMerge(),
                shape: const CircleBorder(),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.grey.shade700,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

          // Индикатор обработки
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(FoxThemeButtonActiveBackground),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Обработка изображения...",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cameraNotInitialized(BuildContext ctx){
    return Scaffold(
      appBar: BaseHeader(
        title: "Распознать ТТН",
        subtitle: "Сканирование документа",
        onBack: () => Navigator.pop(context),
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Иконка камеры
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 40,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Текст
              Text(
                'Доступ к камере',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Для распознавания ТТН необходимо разрешить доступ к камере',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Кнопки
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _initCamera,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FoxThemeButtonActiveBackground,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Разрешить доступ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _inCamera = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: FoxThemeButtonActiveBackground,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: FoxThemeButtonActiveBackground,
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        'Ввести вручную',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext ctx, TextEditingController controller, {String? hintText}){
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: FoxThemeButtonActiveBackground,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[800],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Поле обязательно для заполнения';
        }
        return null;
      },
    );
  }

  // ignore: non_constant_identifier_names
  Widget _TTNEditor(BuildContext ctx){
    return Scaffold(
      appBar: BaseHeader(
        title: "Редактирование ТТН",
        subtitle: "Введите данные вручную",
        onBack: () => Navigator.pop(context),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Карточка с формой
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Наименование товара"),
                            const SizedBox(height: 8),
                            _buildInput(ctx, _nameController, hintText: "Введите наименование"),
                            const SizedBox(height: 10),
                            SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle("Количество"),
                                  const SizedBox(height: 8),
                                  _buildInput(ctx, _countController, hintText: "Введите количество"),
                                  const SizedBox(width: 15),
                                ],
                              ),
                            ),
                            // Селектор единиц измерения
                            SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle("Единицы"),
                                  _buildSectionTitle("${_units.indexOf(_selectedUnit!)}"),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: _selectedUnit,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: FoxThemeButtonActiveBackground,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    hint: Text(
                                      "",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    items: _units.map((String unit) {
                                      return DropdownMenuItem<String>(
                                        value: unit,
                                        child: Text(
                                          unit,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedUnit = newValue;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Выберите единицу';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Раздел вложений
                      AttachmentsSection(
                        context,
                        attachments,
                        (index) => setState(() => attachments.removeAt(index)),
                      ),

                      // Подсказка
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.shade100,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Вы можете отсканировать ТТН для автоматического заполнения полей",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade800,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Кнопки действий
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    // Кнопка сохранения
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_nameController.text.isEmpty ||
                              _countController.text.isEmpty ||
                              _selectedUnit == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Заполните все обязательные поля'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          int? c = int.tryParse(_countController.text);
                          if (c == null) {
                            showErrSnackbar(ctx, "Введите корректное количество");
                            return;
                          }

                          final record = TTNRecord(
                            name: _nameController.text,
                            number: c!.toDouble(),
                            unit: _units.indexOf(_selectedUnit!),
                            attachments: attachments,
                            projectId: widget.projectId
                          );

                          final req = widget.di.getDependency<IQueuedRequests>(IQueuedRequestsDIToken);
                          var toSend = queuedMaterial(record);

                          final token = await widget.di.getDependency<IAuthStorageProvider>(IAuthStorageProviderDIToken).getAccessToken();
                          var res = await req.queuedSend(toSend, token);
                          if (res.isDelayed) {
                            showWarnSnackbar(context, "Файлы будут прикреплены после выхода в интернет");
                          } else if (res.isOk) {
                            showSuccessSnackbar(context, "Файлы успешно прикреплены");
                          } else {
                            showErrSnackbar(context, "Не удалось прикрепить файлы");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FoxThemeButtonActiveBackground,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Сохранить ТТН',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Кнопка добавления вложений
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: FoxThemeButtonActiveBackground,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => _openAddAttachmentMenu(context),
                        icon: const Icon(Icons.add, color: Colors.white, size: 24),
                        tooltip: 'Добавить вложения',
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Кнопка камеры
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _inCamera = true;
                          });
                        },
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.grey.shade700,
                          size: 24,
                        ),
                        tooltip: 'Сканировать',
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          '*',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _nameController.dispose();
    _countController.dispose();
    super.dispose();
  }
}