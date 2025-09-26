package ru.foxstudios.digital_building_journal.screens.material

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import ru.foxstudios.authlib.auth.IAuthStorageProvider
import ru.foxstudios.authlib.auth.IAuthStorageProviderDIToken
import ru.foxstudios.dependency_container.IContainer
import ru.foxstudios.digital_building_journal.Screen

@Composable
fun MaterialsScreen(
    di : IContainer,
    changeScreen:(Screen)->Unit,
    function: () -> Unit //кал бэк
){
    val authStorageProvider = di.get<IAuthStorageProvider>(IAuthStorageProviderDIToken)

    Column(modifier = Modifier.fillMaxSize(), verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally){
        Text("Экран 1")
        Button(onClick =
            {
                //Выход на первый экран
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

    }
}