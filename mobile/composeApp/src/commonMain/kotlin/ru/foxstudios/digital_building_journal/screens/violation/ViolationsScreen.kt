package ru.foxstudios.digital_building_journal.screens.violation

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import ru.foxstudios.authlib.auth.IAuthStorageProvider
import ru.foxstudios.authlib.auth.IAuthStorageProviderDIToken
import ru.foxstudios.dependency_container.IContainer
import ru.foxstudios.digital_building_journal.Screen

@Composable
fun ViolantionsScreen(
    di : IContainer,
    changeScreen:(Screen)->Unit,
    function: () -> Unit //кал бэк
){
    val authStorageProvider = di.get<IAuthStorageProvider>(IAuthStorageProviderDIToken)
    var refreshToken by remember { mutableStateOf(authStorageProvider.getRefreshToken()) }
    Column(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally){
        Text("Главный экран")
        Spacer(Modifier.height(15.dp))
        Button(onClick =
            {
                authStorageProvider.clear()
                println("RefreshToken: $refreshToken")
                changeScreen(Screen.AUTH)  //Выход на экран авторизации
        },
            modifier = Modifier
                .height(40.dp),
            shape = RoundedCornerShape(10),
            colors = ButtonDefaults.buttonColors(
                containerColor = Color(0xFFB41313),
                contentColor = Color.White
            )
        )
        {
            Text("Выйти")
        }
        Text("Токен: $refreshToken")
        Spacer(Modifier.height(10.dp))
        Button(onClick =
            {
                changeScreen(Screen.MAIN)  //Выход на главный экран
            },
            modifier = Modifier
                .height(40.dp),
            shape = RoundedCornerShape(10),
            colors = ButtonDefaults.buttonColors(
                containerColor = Color(0xFFB41313),
                contentColor = Color.White
            )
        )
        {
            Text("MAIN SCREEN")
        }

    }
}