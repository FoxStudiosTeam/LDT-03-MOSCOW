package ru.foxstudios.mobile_flutter

import android.content.Context
import android.graphics.BitmapFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import java.io.File
import com.googlecode.tesseract.android.TessBaseAPI


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
                    val page: OcrPage = ocrEngine.recognize(bytes)

                    fun pageToMap(page: OcrPage): Map<String, Any> {
                        return mapOf(
                            "text" to page.text,
                            "confidence" to page.confidence,
                            "blocks" to page.blocks.map { block ->
                                mapOf(
                                    "text" to block.text,
                                    "confidence" to block.confidence,
                                    "left" to block.left,
                                    "top" to block.top,
                                    "right" to block.right,
                                    "bottom" to block.bottom,
                                    "paragraphs" to block.paragraphs.map { para ->
                                        mapOf(
                                            "text" to para.text,
                                            "confidence" to para.confidence,
                                            "left" to para.left,
                                            "top" to para.top,
                                            "right" to para.right,
                                            "bottom" to para.bottom,
                                            "lines" to para.lines.map { line ->
                                                mapOf(
                                                    "text" to line.text,
                                                    "confidence" to line.confidence,
                                                    "left" to line.left,
                                                    "top" to line.top,
                                                    "right" to line.right,
                                                    "bottom" to line.bottom,
                                                    "words" to line.words.map { word ->
                                                        mapOf(
                                                            "text" to word.text,
                                                            "confidence" to word.confidence,
                                                            "left" to word.left,
                                                            "top" to word.top,
                                                            "right" to word.right,
                                                            "bottom" to word.bottom,
                                                            "symbols" to word.symbols.map { sym ->
                                                                mapOf(
                                                                    "text" to sym.text,
                                                                    "confidence" to sym.confidence,
                                                                    "left" to sym.left,
                                                                    "top" to sym.top,
                                                                    "right" to sym.right,
                                                                    "bottom" to sym.bottom
                                                                )
                                                            }
                                                        )
                                                    }
                                                )
                                            }
                                        )
                                    }
                                )
                            }
                        )
                    }

                    result.success(pageToMap(page))
                } catch (e: Exception) {
                    result.error("OCR_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }



class AndroidTesseractOcrEngine(private val context: Context) {
    private val tess: TessBaseAPI = TessBaseAPI()

    fun init(): Boolean {
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

    fun recognize(image: ByteArray): OcrPage {
        val bitmap = BitmapFactory.decodeByteArray(image, 0, image.size)
        tess.setImage(bitmap)
        val text = tess.utF8Text // this triggers OCR
        // Log.d("OCR", "Recognized text: $text")

        // val boxes = mutableListOf<OcrTextBox>()
        // val iterator = tess.resultIterator
        // iterator.begin()
        // do {
        //     val word = iterator.getUTF8Text(TessBaseAPI.PageIteratorLevel.RIL_WORD)
        //     val conf = iterator.confidence(TessBaseAPI.PageIteratorLevel.RIL_WORD)
        //     val rect = iterator.getBoundingBox(TessBaseAPI.PageIteratorLevel.RIL_WORD)
        //     if (rect != null) {
        //         boxes.add(OcrTextBox(word ?: "", rect[0], rect[1], rect[2], rect[3]))
        //     }
        // } while (iterator.next(TessBaseAPI.PageIteratorLevel.RIL_WORD))

        // return boxes
        return extractOcrPage(tess)
    }

    fun extractOcrPage(tess: TessBaseAPI): OcrPage {
        val pageText = tess.utF8Text
        val pageConfidence = tess.meanConfidence()

        val blocks = mutableListOf<OcrBlock>()
        val blockIter = tess.resultIterator
        blockIter.begin()
        do {
            val blockText = blockIter.getUTF8Text(TessBaseAPI.PageIteratorLevel.RIL_BLOCK) ?: ""
            val blockConf = blockIter.confidence(TessBaseAPI.PageIteratorLevel.RIL_BLOCK)
            val blockRect = blockIter.getBoundingBox(TessBaseAPI.PageIteratorLevel.RIL_BLOCK)!!

            // Extract paragraphs within block
            val paragraphs = mutableListOf<OcrParagraph>()
            blockIter.begin(TessBaseAPI.PageIteratorLevel.RIL_PARA)
            do {
                val paraText = blockIter.getUTF8Text(TessBaseAPI.PageIteratorLevel.RIL_PARA) ?: ""
                val paraConf = blockIter.confidence(TessBaseAPI.PageIteratorLevel.RIL_PARA)
                val paraRect = blockIter.getBoundingBox(TessBaseAPI.PageIteratorLevel.RIL_PARA)!!

                // Extract lines within paragraph
                val lines = mutableListOf<OcrLine>()
                blockIter.begin(TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE)
                do {
                    val lineText = blockIter.getUTF8Text(TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE) ?: ""
                    val lineConf = blockIter.confidence(TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE)
                    val lineRect = blockIter.getBoundingBox(TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE)!!

                    // Extract words within line
                    val words = mutableListOf<OcrWord>()
                    blockIter.begin(TessBaseAPI.PageIteratorLevel.RIL_WORD)
                    do {
                        val wordText = blockIter.getUTF8Text(TessBaseAPI.PageIteratorLevel.RIL_WORD) ?: ""
                        val wordConf = blockIter.confidence(TessBaseAPI.PageIteratorLevel.RIL_WORD)
                        val wordRect = blockIter.getBoundingBox(TessBaseAPI.PageIteratorLevel.RIL_WORD)!!

                        // Extract symbols within word
                        val symbols = mutableListOf<OcrSymbol>()
                        blockIter.begin(TessBaseAPI.PageIteratorLevel.RIL_SYMBOL)
                        do {
                            val symText = blockIter.getUTF8Text(TessBaseAPI.PageIteratorLevel.RIL_SYMBOL) ?: ""
                            val symConf = blockIter.confidence(TessBaseAPI.PageIteratorLevel.RIL_SYMBOL)
                            val symRect = blockIter.getBoundingBox(TessBaseAPI.PageIteratorLevel.RIL_SYMBOL)!!
                            symbols.add(OcrSymbol(symText, symConf, symRect[0], symRect[1], symRect[2], symRect[3]))
                        } while (blockIter.next(TessBaseAPI.PageIteratorLevel.RIL_SYMBOL))

                        words.add(OcrWord(wordText, wordConf, wordRect[0], wordRect[1], wordRect[2], wordRect[3], symbols))
                    } while (blockIter.next(TessBaseAPI.PageIteratorLevel.RIL_WORD))

                    lines.add(OcrLine(lineText, lineConf, lineRect[0], lineRect[1], lineRect[2], lineRect[3], words))
                } while (blockIter.next(TessBaseAPI.PageIteratorLevel.RIL_TEXTLINE))

                paragraphs.add(OcrParagraph(paraText, paraConf, paraRect[0], paraRect[1], paraRect[2], paraRect[3], lines))
            } while (blockIter.next(TessBaseAPI.PageIteratorLevel.RIL_PARA))

            blocks.add(OcrBlock(blockText, blockConf, blockRect[0], blockRect[1], blockRect[2], blockRect[3], paragraphs))
        } while (blockIter.next(TessBaseAPI.PageIteratorLevel.RIL_BLOCK))

        return OcrPage(pageText ?: "", pageConfidence, blocks)
    }
 
}


data class OcrSymbol(
    val text: String,
    val confidence: Float,
    val left: Int,
    val top: Int,
    val right: Int,
    val bottom: Int
)

data class OcrWord(
    val text: String,
    val confidence: Float,
    val left: Int,
    val top: Int,
    val right: Int,
    val bottom: Int,
    val symbols: List<OcrSymbol> = emptyList()
)

data class OcrLine(
    val text: String,
    val confidence: Float,
    val left: Int,
    val top: Int,
    val right: Int,
    val bottom: Int,
    val words: List<OcrWord> = emptyList()
)

data class OcrParagraph(
    val text: String,
    val confidence: Float,
    val left: Int,
    val top: Int,
    val right: Int,
    val bottom: Int,
    val lines: List<OcrLine> = emptyList()
)

data class OcrBlock(
    val text: String,
    val confidence: Float,
    val left: Int,
    val top: Int,
    val right: Int,
    val bottom: Int,
    val paragraphs: List<OcrParagraph> = emptyList()
)

data class OcrPage(
    val text: String,
    val confidence: Float,
    val blocks: List<OcrBlock> = emptyList()
)

data class OcrTextBox(
    val text: String,
    val left: Int,
    val top: Int,
    val right: Int,
    val bottom: Int
)