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
                    let image = UIImage(data: imageBytes.data)
                else {
                    result(
                        FlutterError(
                            code: "INVALID_IMAGE", message: "Image data is missing or invalid",
                            details: nil))
                    return
                }

                guard let tesseract = G8Tesseract(language: "rus") else {
                    result(
                        FlutterError(
                            code: "OCR_INIT_FAILED", message: "Tesseract init failed", details: nil)
                    )
                    return
                }

                tesseract.engineMode = .tesseractOnly
                tesseract.pageSegmentationMode = .auto
                tesseract.image = image.g8_blackAndWhite()
                tesseract.recognize()

                var boxes: [[String: Any]] = []

                if let words = tesseract.recognizedBlocks(by: .word) as? [G8RecognizedBlock] {
                    for word in words {
                        let rect = word.boundingBox
                        boxes.append([
                            "text": word.text ?? "",
                            "left": Int(rect.origin.x),
                            "top": Int(rect.origin.y),
                            "right": Int(rect.origin.x + rect.width),
                            "bottom": Int(rect.origin.y + rect.height),
                        ])
                    }
                }

                result(boxes)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
