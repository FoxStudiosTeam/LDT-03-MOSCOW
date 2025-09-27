package ru.foxstudios.digital_building_journal.screens.material

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import ru.foxstudios.authlib.auth.IAuthStorageProvider
import ru.foxstudios.authlib.auth.IAuthStorageProviderDIToken
import ru.foxstudios.dependency_container.IContainer
import ru.foxstudios.digital_building_journal.Screen
import androidx.compose.material3.*
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.sp
import androidx.compose.ui.zIndex
import org.jetbrains.compose.ui.tooling.preview.Preview
import ru.foxstudios.authlib.auth.IAuthProviderDIToken
import ru.foxstudios.dependency_container.DependencyBuilder
import ru.foxstudios.digital_building_journal.di.I_SSO_DI_TOKEN
import ru.foxstudios.digital_building_journal.di.normalBuilder
import ru.foxstudios.digital_building_journal.dummy.DummyAuthProvider
import ru.foxstudios.digital_building_journal.dummy.DummyAuthStorageProvider
import ru.foxstudios.digital_building_journal.screens.Header
import ru.foxstudios.digital_building_journal.screens.MainScreen

@Composable
fun MaterialsScreen(
    di : IContainer,
    changeScreen:(Screen)->Unit,
    function: () -> Unit //кал бэк
){
    val authStorageProvider = di.get<IAuthStorageProvider>(IAuthStorageProviderDIToken)
    var expanded by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
            .border(0.5.dp, Color.Gray)
            .padding(top=10.dp, bottom = 5.dp)
    ) {
        Header()
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 24.dp),
            verticalAlignment = Alignment.Top,
            horizontalArrangement = Arrangement.Start,
        ) {
            Button(
                onClick = { changeScreen(Screen.VIOLATION) },
                modifier = Modifier
                    .weight(0.5f)
                    .height(50.dp)
                    .padding(start = 8.dp, end = 8.dp),
                shape = RoundedCornerShape(8.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFFB41313),
                    contentColor = Color.White
                )
            ) {
                Text("Назад")
            }
        }
        Row {
            Button(
                onClick = { changeScreen(Screen.REPORT) },
                modifier = Modifier
                    .fillMaxWidth(0.8f)
                    .height(50.dp),
                shape = RoundedCornerShape(8.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    contentColor = Color.White
                )
            ) {
                Text("Назад1")
            }
        }

    }
}

@Composable
@Preview
fun MaterialsScreenPreview(){
    DependencyBuilder.registryDependency(IAuthProviderDIToken, DummyAuthProvider())
    DependencyBuilder.registryDependency(IAuthStorageProviderDIToken, DummyAuthStorageProvider())
    DependencyBuilder.registryDependency(I_SSO_DI_TOKEN, "dummy")
    val di = normalBuilder(DependencyBuilder)
    MaterialsScreen(di,{},{})
}