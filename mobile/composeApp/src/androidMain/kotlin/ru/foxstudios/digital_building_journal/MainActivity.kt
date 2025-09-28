package ru.foxstudios.digital_building_journal

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import ru.foxstudios.authlib.auth.AuthStorageProvider
import ru.foxstudios.authlib.auth.IAuthStorageProviderDIToken
import ru.foxstudios.dependency_container.DependencyBuilder
import ru.foxstudios.digital_building_journal.di.I_SSO_DI_TOKEN
import ru.foxstudios.digital_building_journal.neural_network.IOcrDIToken
import ru.foxstudios.digital_building_journal.nn.AndroidTesseractOcrEngine

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        DependencyBuilder.registryDependency(IAuthStorageProviderDIToken, AuthStorageProvider(this))
        DependencyBuilder.registryDependency(I_SSO_DI_TOKEN, "http://81.200.145.130:32460")
        val nn = AndroidTesseractOcrEngine(this)
        val r = nn.init() // TODO: CHECK FALSE
        DependencyBuilder.registryDependency(IOcrDIToken, nn)

        setContent {
            App()
        }
    }
}

@Preview
@Composable
fun AppAndroidPreview() {
    App()
}