import 'package:flutter/services.dart';

class OcrBridge {
  static const _channel = MethodChannel("ocr_channel");

  static Future<List<Map<String, dynamic>>> getBoxes(List<int> imageBytes) async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      "getBoxes",
      {"image": Uint8List.fromList(imageBytes)},
    );
    return result?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
  }
}