package ru.foxstudios.digital_building_journal.screens.ocr

import androidx.compose.runtime.Composable
import ru.foxstudios.dependency_container.IContainer
import ru.foxstudios.digital_building_journal.Screen

@Composable
actual fun OcrScreen(
    di: IContainer,
    changeScreen: (Screen) -> Unit,
    function: () -> Unit
) {
}