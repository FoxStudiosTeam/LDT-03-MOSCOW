import 'package:flutter/services.dart';

class OcrBridge {
  static const _channel = MethodChannel("ocr_channel");

  static Future<List<OcrBox>> getOcrBoxes(List<int> imageBytes) async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      "getOcrBoxes",
      {"image": Uint8List.fromList(imageBytes)},
    );

    if (result == null) return [];

    return result.map((e) {
      final map = Map<String, dynamic>.from(e);
      return OcrBox(
        map['left'] ?? 0,
        map['right'] ?? 0,
        map['top'] ?? 0,
        map['bottom'] ?? 0,
        map['text'] ?? '',
      );
    }).toList();
  }
}


class OcrBox {
  final int left;
  final int right;
  final int top;
  final int bottom;
  final String text;

  OcrBox(this.left, this.right, this.top, this.bottom, this.text);
}