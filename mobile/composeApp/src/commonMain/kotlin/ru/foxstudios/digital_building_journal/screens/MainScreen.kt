package ru.foxstudios.digital_building_journal.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
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
fun MainScreen(
    di : IContainer,
    changeScreen:(Screen)->Unit,
    function: () -> Unit //кал бэк
){
    val authStorageProvider = di.get<IAuthStorageProvider>(IAuthStorageProviderDIToken)
    var refreshToken by remember { mutableStateOf(authStorageProvider.getRefreshToken()) }
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFFD0D0D0)),
        contentAlignment = Alignment.Center
    ) {
            Column(
                modifier = Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.Center,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text("Вы успешно авторизовались")
                Button(onClick =
                        {
                              //Выход на первый экран
                        },
                    modifier = Modifier
                        .height(35.dp),
                    shape = RoundedCornerShape(10),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color(0xFFB41313),
                        contentColor = Color.White
                    )
                )
                {
                    Text("В процессе")
                }


                Button(onClick =
                    {

                    },
                    modifier = Modifier
                        .height(35.dp),
                    shape = RoundedCornerShape(10),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color(0xFFB41313),
                        contentColor = Color.White
                    )
                )
                {
                    Text("Завершенные")
                }
                Button(onClick =
                    {
                        authStorageProvider.clear()
                        changeScreen(Screen.AUTH)//Выход на первый экран
                    },
                    modifier = Modifier
                        .height(35.dp),
                    shape = RoundedCornerShape(10),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color(0xFFB41313),
                        contentColor = Color.White
                    )
                )
                {
                    Text("Выход")
                }
                Text("Токен: $refreshToken")
        }
    }
}