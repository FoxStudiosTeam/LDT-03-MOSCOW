import 'dart:typed_data';
import 'package:flutter/services.dart';

class OcrBridge {
  static const _channel = MethodChannel("ocr_channel");

  static Future<OcrPage?> getPage(Uint8List imageBytes) async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      "getBoxes",
      {"image": imageBytes},
    );

    if (result == null) return null;

    return OcrPage.fromMap(Map<String, dynamic>.from(result));
  }
}

// ---------- OCR Models ----------

class OcrSymbol {
  final String text;
  final double confidence;
  final int left, top, right, bottom;

  OcrSymbol(this.text, this.confidence, this.left, this.top, this.right, this.bottom);

  factory OcrSymbol.fromMap(Map<String, dynamic> map) {
    return OcrSymbol(
      map['text'] ?? '',
      (map['confidence'] ?? 0).toDouble(),
      map['left'] ?? 0,
      map['top'] ?? 0,
      map['right'] ?? 0,
      map['bottom'] ?? 0,
    );
  }
}

class OcrWord {
  final String text;
  final double confidence;
  final int left, top, right, bottom;
  final List<OcrSymbol> symbols;

  OcrWord(this.text, this.confidence, this.left, this.top, this.right, this.bottom, this.symbols);

  factory OcrWord.fromMap(Map<String, dynamic> map) {
    return OcrWord(
      map['text'] ?? '',
      (map['confidence'] ?? 0).toDouble(),
      map['left'] ?? 0,
      map['top'] ?? 0,
      map['right'] ?? 0,
      map['bottom'] ?? 0,
      (map['symbols'] as List<dynamic>? ?? []).map((e) => OcrSymbol.fromMap(Map<String, dynamic>.from(e))).toList(),
    );
  }
}

class OcrLine {
  final String text;
  final double confidence;
  final int left, top, right, bottom;
  final List<OcrWord> words;

  OcrLine(this.text, this.confidence, this.left, this.top, this.right, this.bottom, this.words);

  factory OcrLine.fromMap(Map<String, dynamic> map) {
    return OcrLine(
      map['text'] ?? '',
      (map['confidence'] ?? 0).toDouble(),
      map['left'] ?? 0,
      map['top'] ?? 0,
      map['right'] ?? 0,
      map['bottom'] ?? 0,
      (map['words'] as List<dynamic>? ?? []).map((e) => OcrWord.fromMap(Map<String, dynamic>.from(e))).toList(),
    );
  }
}

class OcrParagraph {
  final String text;
  final double confidence;
  final int left, top, right, bottom;
  final List<OcrLine> lines;

  OcrParagraph(this.text, this.confidence, this.left, this.top, this.right, this.bottom, this.lines);

  factory OcrParagraph.fromMap(Map<String, dynamic> map) {
    return OcrParagraph(
      map['text'] ?? '',
      (map['confidence'] ?? 0).toDouble(),
      map['left'] ?? 0,
      map['top'] ?? 0,
      map['right'] ?? 0,
      map['bottom'] ?? 0,
      (map['lines'] as List<dynamic>? ?? []).map((e) => OcrLine.fromMap(Map<String, dynamic>.from(e))).toList(),
    );
  }
}

class OcrBlock {
  final String text;
  final double confidence;
  final int left, top, right, bottom;
  final List<OcrParagraph> paragraphs;

  OcrBlock(this.text, this.confidence, this.left, this.top, this.right, this.bottom, this.paragraphs);

  factory OcrBlock.fromMap(Map<String, dynamic> map) {
    return OcrBlock(
      map['text'] ?? '',
      (map['confidence'] ?? 0).toDouble(),
      map['left'] ?? 0,
      map['top'] ?? 0,
      map['right'] ?? 0,
      map['bottom'] ?? 0,
      (map['paragraphs'] as List<dynamic>? ?? []).map((e) => OcrParagraph.fromMap(Map<String, dynamic>.from(e))).toList(),
    );
  }
}

class OcrPage {
  final String text;
  final double confidence;
  final List<OcrBlock> blocks;

  OcrPage(this.text, this.confidence, this.blocks);

  factory OcrPage.fromMap(Map<String, dynamic> map) {
    return OcrPage(
      map['text'] ?? '',
      (map['confidence'] ?? 0).toDouble(),
      (map['blocks'] as List<dynamic>? ?? []).map((e) => OcrBlock.fromMap(Map<String, dynamic>.from(e))).toList(),
    );
  }
}
