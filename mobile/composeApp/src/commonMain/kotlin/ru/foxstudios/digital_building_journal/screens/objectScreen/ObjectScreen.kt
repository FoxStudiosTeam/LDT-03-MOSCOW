package ru.foxstudios.digital_building_journal.screens.objectScreen

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.jetbrains.compose.ui.tooling.preview.Preview
import ru.foxstudios.authlib.auth.IAuthProviderDIToken
import ru.foxstudios.authlib.auth.IAuthStorageProvider
import ru.foxstudios.authlib.auth.IAuthStorageProviderDIToken
import ru.foxstudios.dependency_container.DependencyBuilder
import ru.foxstudios.dependency_container.IContainer
import ru.foxstudios.digital_building_journal.Screen
import ru.foxstudios.digital_building_journal.di.I_SSO_DI_TOKEN
import ru.foxstudios.digital_building_journal.di.normalBuilder
import ru.foxstudios.digital_building_journal.dummy.DummyAuthProvider
import ru.foxstudios.digital_building_journal.dummy.DummyAuthStorageProvider
import ru.foxstudios.digital_building_journal.screens.Header

@Composable
fun ObjectScreen(
    di : IContainer,
    changeScreen:(Screen)->Unit,
    function: () -> Unit //кал бэк
){
    val authStorageProvider = di.get<IAuthStorageProvider>(IAuthStorageProviderDIToken)
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
            .border(0.5.dp, Color.Gray)
            .padding(top=10.dp, bottom = 5.dp)
    ) {
        Header(changeScreen)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 24.dp, start = 16.dp, end = 16.dp)
                .height(100.dp), // увеличиваем высоту строки
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Button(
                onClick = { changeScreen(Screen.MAIN) },
                shape = RoundedCornerShape(8.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.White,
                    contentColor = Color.Black
                ),
                modifier = Modifier
                    .height(56.dp) // увеличиваем высоту кнопки
                    .fillMaxWidth(0.12f),
                contentPadding = PaddingValues(0.dp)
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .fillMaxHeight(),
                ) {
                    Text(
                        "\u2B05",
                        fontSize = 40.sp,
                        modifier = Modifier
                            .align(Alignment.TopCenter)
                    )
                }
            }
            Text(
                text = "Объект_нейм",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier
                    .weight(1f)
                    .padding(start = 16.dp, end = 16.dp),
                maxLines = 1
            )
            Button(
                onClick = { },
                shape = RoundedCornerShape(8.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.White,
                    contentColor = Color.Black
                ),
                modifier = Modifier
                    .height(52.dp)
                    .padding(start = 8.dp),
                contentPadding = PaddingValues(0.dp)
            ) {
                Text("\uFE19",
                    fontSize = 38.sp,
                )

            }
        }
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.Top,
            horizontalArrangement = Arrangement.Start
        ) {
            // Здесь должны быть данные, полученные по id объекта из БД
            // Например:
            // val objectData = remember { getObjectById(objectId) }
            //
            // Text("Название: ${objectData.name}")
            // Text("Адрес: ${objectData.address}")
            // Text("Статус: ${objectData.status}")
            //
            // Для примера используем заглушку:
            Column(
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text("Название: Пример объекта", fontSize = 18.sp)
                Text("Адрес: г. Москва, ул. Примерная, д. 1", fontSize = 16.sp)
                Text("Статус: В работе", fontSize = 16.sp)
                // Добавьте другие необходимые поля
            }

        }
    }
}
@Composable
@Preview
fun ObjectScreenPreview(){
    DependencyBuilder.registryDependency(IAuthProviderDIToken, DummyAuthProvider())
    DependencyBuilder.registryDependency(IAuthStorageProviderDIToken, DummyAuthStorageProvider())
    DependencyBuilder.registryDependency(I_SSO_DI_TOKEN, "dummy")
    val di = normalBuilder(DependencyBuilder)
    ObjectScreen(di,{},{})
}