package ru.foxstudios.digital_building_journal.nn

import android.content.Context
import android.graphics.BitmapFactory
import android.util.Log
import com.googlecode.tesseract.android.TessBaseAPI
import ru.foxstudios.digital_building_journal.neural_network.IOcrEngine
import ru.foxstudios.digital_building_journal.neural_network.OcrTextBox
import java.io.File

class DummyAndroidTesseractOcrEngine : IOcrEngine {
    override fun init(): Boolean {
        return true
    }
    override fun recognize(image: ByteArray): List<OcrTextBox> {
        return emptyList()
    }
}

class AndroidTesseractOcrEngine(private val context: Context) : IOcrEngine {
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
