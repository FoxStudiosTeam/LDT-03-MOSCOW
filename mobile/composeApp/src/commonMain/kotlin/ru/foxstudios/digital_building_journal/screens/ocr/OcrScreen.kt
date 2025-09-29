package ru.foxstudios.digital_building_journal.screens.ocr

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import org.jetbrains.compose.ui.tooling.preview.Preview
import ru.foxstudios.dependency_container.IContainer
import ru.foxstudios.digital_building_journal.Screen

@Composable
expect fun OcrScreen(di: IContainer, changeScreen: (Screen) -> Unit, function: () -> Unit)
