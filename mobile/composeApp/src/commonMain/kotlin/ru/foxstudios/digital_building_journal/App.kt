package ru.foxstudios.digital_building_journal

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.runtime.setValue
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking
import org.jetbrains.compose.ui.tooling.preview.Preview
import ru.foxstudios.authlib.auth.IAuthStorageProvider
import ru.foxstudios.authlib.auth.IAuthStorageProviderDIToken
import ru.foxstudios.dependency_container.DependencyBuilder
import ru.foxstudios.dependency_container.IContainer
import ru.foxstudios.digital_building_journal.di.normalBuilder
import ru.foxstudios.digital_building_journal.screens.*
import ru.foxstudios.digital_building_journal.screens.material.MaterialsScreen
import ru.foxstudios.digital_building_journal.screens.auth.AuthScreen
import ru.foxstudios.digital_building_journal.screens.subject.ObjectScreen
import ru.foxstudios.digital_building_journal.screens.punishment.PunishmentsScreen
import ru.foxstudios.digital_building_journal.screens.report.ReportsScreen
import ru.foxstudios.digital_building_journal.screens.violation.ViolantionsScreen

enum class Screen {
    AUTH,
    MAIN,
    OBJECT,
    REPORT,
    MATERIALS,
    PUNISHMENT,
    VIOLATION
}
@Composable
@Preview
fun App() {
    var showSplash by remember { mutableStateOf(true) }
    var isLoading by remember { mutableStateOf(true) }
    LaunchedEffect(Unit) {
        delay(2000L)
        showSplash = false
        delay(500L)
        isLoading = false
    }
    if (isLoading) {
        SplashScreen(showSplash = showSplash)
    } else {
        MainAppContent()
    }
}
@Composable
fun MainAppContent(){
    val di = normalBuilder(DependencyBuilder)
    val authStorageProvider = di.get<IAuthStorageProvider>(IAuthStorageProviderDIToken)
    var startScreen by remember { mutableStateOf(checkCurrentScreen(di)) }
    MaterialTheme {
        when (startScreen) {
            Screen.AUTH -> AuthScreen(di, { next -> startScreen = next }) {}
            Screen.MAIN -> MainScreen(di, { next -> startScreen = next }) {}
            Screen.OBJECT -> ObjectScreen(di, { next -> startScreen = next }) {}
            Screen.REPORT -> ReportsScreen(di, { next -> startScreen = next }) {}
            Screen.MATERIALS -> MaterialsScreen(di, { next -> startScreen = next }) {}
            Screen.PUNISHMENT -> PunishmentsScreen(di, { next -> startScreen = next }) {}
            Screen.VIOLATION -> ViolantionsScreen(di, { next -> startScreen = next }) {}
        }
    }
}

fun checkCurrentScreen(di : IContainer): Screen {
    val authStorageProvider = di.get<IAuthStorageProvider>(IAuthStorageProviderDIToken)
    val refreshToken = runBlocking { authStorageProvider.getRefreshToken() }
    if (refreshToken.isNotEmpty()){
        return Screen.MAIN
    }
    return Screen.AUTH
}

@Composable
@Preview
fun PreviewApp() {
    App()
}