package ru.foxstudios.digital_building_journal.neural_network

data class OcrTextBox(
    val text: String,
    val left: Int,
    val top: Int,
    val right: Int,
    val bottom: Int
)

const val IOcrDIToken = "IOcrDIToken"

interface IOcrEngine {
    fun init(): Boolean
    fun recognize(image: ByteArray): List<OcrTextBox>
}
