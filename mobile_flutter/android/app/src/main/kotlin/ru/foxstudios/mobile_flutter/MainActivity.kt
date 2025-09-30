package ru.foxstudios.mobile_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import ru.foxstudios.digital_building_journal.neural_network.OcrTextBox

data class OcrTextBox(
    val text: String,
    val left: Int,
    val top: Int,
    val right: Int,
    val bottom: Int
)

class MainActivity : FlutterActivity() {
    private val CHANNEL = "ocr_channel"
    private lateinit var ocrEngine: AndroidTesseractOcrEngine

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        ocrEngine = AndroidTesseractOcrEngine(this)
        val initOk = ocrEngine.init()
        Log.d("OCR", "Engine init result: $initOk")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBoxes" -> {
                        val bytes = call.argument<ByteArray>("image")
                        if (bytes == null) {
                            result.error("NO_IMAGE", "Image bytes are required", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val boxes: List<OcrTextBox> = ocrEngine.recognize(bytes)
                            // Преобразуем в Map для Flutter
                            val mapped = boxes.map { box ->
                                mapOf(
                                    "text" to box.text,
                                    "x" to box.x,
                                    "y" to box.y,
                                    "w" to box.w,
                                    "h" to box.h
                                )
                            }
                            result.success(mapped)
                        } catch (e: Exception) {
                            result.error("OCR_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}


class AndroidTesseractOcrEngine(private val context: Context) {
    private val tess: TessBaseAPI = TessBaseAPI()

    override fun init(): Boolean {
        try {
            val tessFolder = File(context.filesDir, "tesseract")
            val tessDataFolder = File(tessFolder, "tessdata")
            Log.d("OCR", "Checking if tessFolder exists: ${tessFolder.absolutePath}")

            if (!tessFolder.exists()) {
                Log.d("OCR", "tessFolder does not exist, creating...")
                tessFolder.mkdirs()
            } else {
                Log.d("OCR", "tessFolder already exists")
            }

            if (!tessDataFolder.exists()) {
                Log.d("OCR", "tessDataFolder does not exist, creating...")
                tessDataFolder.mkdirs()
            } else {
                Log.d("OCR", "tessDataFolder already exists")
            }

            val trainedFile = File(tessDataFolder, "rus.traineddata")
            if (!trainedFile.exists()) {
                Log.d("OCR", "rus.traineddata not found, copying from assets...")
                context.assets.open("tesseract/tessdata/rus.traineddata").use { input ->
                    trainedFile.outputStream().use { output ->
                        input.copyTo(output)
                    }
                }
                Log.d("OCR", "rus.traineddata copied successfully")
            } else {
                Log.d("OCR", "rus.traineddata already exists")
            }

            val assetFiles = context.assets.list("tesseract/tessdata")
            Log.d("OCR", "Files in assets/tesseract/tessdata: ${assetFiles?.joinToString()}")

            Log.d("OCR", "Initializing TessBaseAPI with path: ${tessFolder.absolutePath}")
            val r = tess.init(tessFolder.absolutePath, "rus")
            Log.d("OCR", "TessBaseAPI init result: $r")

            if (!r) {
                Log.e("OCR", "TessBaseAPI initialization failed")
                tess.recycle()
                return false
            }

            Log.d("OCR", "TessBaseAPI initialized successfully")
            return true
        } catch (e: Exception) {
            Log.e("OCR", "Exception during init: ${e.message}", e)
            tess.recycle()
            return false
        }
    }

    override fun recognize(image: ByteArray): List<OcrTextBox> {
        val bitmap = BitmapFactory.decodeByteArray(image, 0, image.size)
        tess.setImage(bitmap)
        val text = tess.utF8Text // this triggers OCR
        Log.d("OCR", "Recognized text: $text")

        val boxes = mutableListOf<OcrTextBox>()
        val iterator = tess.resultIterator
        iterator.begin()
        do {
            val word = iterator.getUTF8Text(TessBaseAPI.PageIteratorLevel.RIL_WORD)
            val conf = iterator.confidence(TessBaseAPI.PageIteratorLevel.RIL_WORD)
            val rect = iterator.getBoundingBox(TessBaseAPI.PageIteratorLevel.RIL_WORD)
            if (rect != null) {
                boxes.add(OcrTextBox(word ?: "", rect[0], rect[1], rect[2], rect[3]))
            }
        } while (iterator.next(TessBaseAPI.PageIteratorLevel.RIL_WORD))

        return boxes
    }
}
