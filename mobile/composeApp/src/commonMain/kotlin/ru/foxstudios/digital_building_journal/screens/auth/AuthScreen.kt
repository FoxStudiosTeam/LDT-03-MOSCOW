package ru.foxstudios.digital_building_journal.screens.auth

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import org.jetbrains.compose.ui.tooling.preview.Preview
import ru.foxstudios.authlib.auth.IAuthStorageProvider
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import kotlinx.coroutines.launch
import ru.foxstudios.authlib.auth.IAuthProvider
import ru.foxstudios.authlib.auth.IAuthProviderDIToken
import ru.foxstudios.authlib.auth.IAuthStorageProviderDIToken
import ru.foxstudios.dependency_container.DependencyBuilder
import ru.foxstudios.dependency_container.IContainer
import ru.foxstudios.digital_building_journal.di.normalBuilder
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.ui.unit.dp
import androidx.compose.ui.graphics.Color
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import ru.foxstudios.digital_building_journal.Screen

@Composable
fun AuthScreen(
    di: IContainer,
    changeScreen: (Screen) -> Unit,
    function: () -> Unit
) {
    val authStorageProvider = di.get<IAuthStorageProvider>(IAuthStorageProviderDIToken)
    val authProvider = di.get<IAuthProvider>(IAuthProviderDIToken)
    var login by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    val coroutineScope = rememberCoroutineScope()
    var text by remember { mutableStateOf("Войти") }
    var showErrorDialog by remember { mutableStateOf(false) }
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFFD0D0D0)),
        contentAlignment = Alignment.Center
    ) {
        Card(
            shape = RoundedCornerShape(10.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp),
            modifier = Modifier
                .fillMaxWidth(0.9f)
                .wrapContentHeight()
                .padding(16.dp)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp),
                verticalArrangement = Arrangement.Center,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    "Авторизация",
                    style = MaterialTheme.typography.headlineSmall
                )
                Text("authStorageProvider.getRefreshToken(): ${authStorageProvider.getRefreshToken()}")

                Spacer(Modifier.height(30.dp))

                OutlinedTextField(
                    value = login,
                    onValueChange = { login = it },
                    label = { Text("Логин") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    shape = RoundedCornerShape(4.dp)
                )
                Spacer(Modifier.height(45.dp))
                OutlinedTextField(
                    value = password,
                    onValueChange = { password = it },
                    label = { Text("Пароль") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    shape = RoundedCornerShape(4.dp)
                )
                Spacer(Modifier.height(35.dp))
                Button(
                    onClick = {
                        Dispatchers.IO
                        coroutineScope.launch {
                            val result =
                                authProvider.login(login, password, 5000, authStorageProvider)
                            println(result)
                            result.onSuccess { abc ->
                                //text = "ok ${abc.accessToken} : ${abc.exp}"
                                    changeScreen(Screen.MAIN)
                            }
                            result.onFailure {
                                authStorageProvider.clear()
                                showErrorDialog = true
                                text = result.exceptionOrNull()?.message ?: "Ошибка авторизации"
                            }
                        }
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(35.dp),
                    shape = RoundedCornerShape(10),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color(0xFFB41313)
                        ,
                        contentColor = Color.White
                    )
                ) {
                    Text(text.uppercase())
                }

                if (showErrorDialog) {
                    AlertDialog(
                        onDismissRequest = { showErrorDialog = false },
                        title = { Text("Ошибка авторизации") },
                        text = { Text("Неверный логин или пароль") },
                        confirmButton = {
                            TextButton(onClick = { showErrorDialog = false }) {
                                Text("OK")
                            }
                        }
                    )
                }
            }
        }
    }
}

@Preview
@Composable
fun AuthScreenPreview() {
    val di = normalBuilder(DependencyBuilder)
    AuthScreen(di,{}) {
    }
}