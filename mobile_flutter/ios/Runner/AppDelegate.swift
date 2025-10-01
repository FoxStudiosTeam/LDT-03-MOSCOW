import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "ocr_channel", binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { (call, result) in
            switch call.method {
            case "getBoxes":
                guard let args = call.arguments as? [String: Any],
                      let imageBytes = args["image"] as? FlutterStandardTypedData,
                      let image = UIImage(data: imageBytes.data) else {
                    result(
                        FlutterError(
                            code: "INVALID_IMAGE",
                            message: "Image data is missing or invalid",
                            details: nil))
                    return
                }

                guard let tesseract = G8Tesseract(language: "rus") else {
                    result(
                        FlutterError(
                            code: "OCR_INIT_FAILED",
                            message: "Tesseract init failed",
                            details: nil))
                    return
                }

                tesseract.engineMode = .tesseractOnly
                tesseract.pageSegmentationMode = .auto
                tesseract.image = image.g8_blackAndWhite()
                tesseract.recognize()

                // Convert hierarchy
                func symbolToDict(_ symbol: G8RecognizedBlock) -> [String: Any] {
                    let rect = symbol.boundingBox
                    return [
                        "text": symbol.text ?? "",
                        "confidence": symbol.confidence,
                        "left": Int(rect.origin.x),
                        "top": Int(rect.origin.y),
                        "right": Int(rect.origin.x + rect.width),
                        "bottom": Int(rect.origin.y + rect.height)
                    ]
                }

                func wordToDict(_ word: G8RecognizedBlock) -> [String: Any] {
                    let rect = word.boundingBox
                    let symbols = (word.symbols ?? []) as! [G8RecognizedBlock]
                    return [
                        "text": word.text ?? "",
                        "confidence": word.confidence,
                        "left": Int(rect.origin.x),
                        "top": Int(rect.origin.y),
                        "right": Int(rect.origin.x + rect.width),
                        "bottom": Int(rect.origin.y + rect.height),
                        "symbols": symbols.map(symbolToDict)
                    ]
                }

                func lineToDict(_ line: G8RecognizedBlock) -> [String: Any] {
                    let rect = line.boundingBox
                    let words = (line.words ?? []) as! [G8RecognizedBlock]
                    return [
                        "text": line.text ?? "",
                        "confidence": line.confidence,
                        "left": Int(rect.origin.x),
                        "top": Int(rect.origin.y),
                        "right": Int(rect.origin.x + rect.width),
                        "bottom": Int(rect.origin.y + rect.height),
                        "words": words.map(wordToDict)
                    ]
                }

                func paragraphToDict(_ para: G8RecognizedBlock) -> [String: Any] {
                    let rect = para.boundingBox
                    let lines = (para.lines ?? []) as! [G8RecognizedBlock]
                    return [
                        "text": para.text ?? "",
                        "confidence": para.confidence,
                        "left": Int(rect.origin.x),
                        "top": Int(rect.origin.y),
                        "right": Int(rect.origin.x + rect.width),
                        "bottom": Int(rect.origin.y + rect.height),
                        "lines": lines.map(lineToDict)
                    ]
                }

                func blockToDict(_ block: G8RecognizedBlock) -> [String: Any] {
                    let rect = block.boundingBox
                    let paragraphs = (block.paragraphs ?? []) as! [G8RecognizedBlock]
                    return [
                        "text": block.text ?? "",
                        "confidence": block.confidence,
                        "left": Int(rect.origin.x),
                        "top": Int(rect.origin.y),
                        "right": Int(rect.origin.x + rect.width),
                        "bottom": Int(rect.origin.y + rect.height),
                        "paragraphs": paragraphs.map(paragraphToDict)
                    ]
                }

                // Build page dictionary
                let blocks = tesseract.recognizedBlocks(by: .block) as? [G8RecognizedBlock] ?? []
                let pageDict: [String: Any] = [
                    "text": tesseract.recognizedText ?? "",
                    "confidence": tesseract.meanConfidence(),
                    "blocks": blocks.map(blockToDict)
                ]

                result(pageDict)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
