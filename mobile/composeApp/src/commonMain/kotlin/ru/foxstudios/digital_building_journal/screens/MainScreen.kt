package ru.foxstudios.digital_building_journal.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateDp
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.updateTransition
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import ru.foxstudios.authlib.auth.IAuthStorageProvider
import ru.foxstudios.authlib.auth.IAuthStorageProviderDIToken
import ru.foxstudios.dependency_container.IContainer
import ru.foxstudios.digital_building_journal.Screen
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.layout.Layout
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.zIndex
import org.jetbrains.compose.ui.tooling.preview.Preview
import ru.foxstudios.authlib.auth.IAuthProviderDIToken
import ru.foxstudios.dependency_container.DependencyBuilder
import ru.foxstudios.digital_building_journal.di.I_SSO_DI_TOKEN
import ru.foxstudios.digital_building_journal.di.normalBuilder
import ru.foxstudios.digital_building_journal.dummy.DummyAuthProvider
import ru.foxstudios.digital_building_journal.dummy.DummyAuthStorageProvider
import ru.foxstudios.digital_building_journal.screens.Header
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(
    di: IContainer,
    changeScreen: (Screen) -> Unit,
    function: () -> Unit //кал бэк
) {
    val authStorageProvider = di.get<IAuthStorageProvider>(IAuthStorageProviderDIToken)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
            .border(0.5.dp, Color.Gray)
            .padding(top = 10.dp, bottom = 5.dp)
            
    ) {
        Header(changeScreen)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 24.dp),
            verticalAlignment = Alignment.Top,
            horizontalArrangement = Arrangement.Start,
        ) {
            Button(
                onClick = { },
                modifier = Modifier
                    .weight(1f)
                    .height(50.dp)
                    .padding(start = 20.dp, end = 20.dp),
                shape = RoundedCornerShape(8.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFFB41313),
                    contentColor = Color.White
                )
            ) {
                Text("В процессе")
            }
            Button(
                onClick = { },
                modifier = Modifier
                    .weight(1f)
                    .height(50.dp)
                    .padding(start = 20.dp, end = 20.dp),
                shape = RoundedCornerShape(8.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFFB41313),
                    contentColor = Color.White
                )
            ) {
                Text("Завершенные")
            }
        }
        Spacer(modifier = Modifier.height(20.dp))
        val dbRecords = remember {
            listOf(
                mapOf(
                    "Адрес" to "г. Москва, ул. Флотская, д. 54,58к1",
                    "Статус" to "В процессе",
                    "Заказчик" to "ООО Рога и Копыта",
                    "Исполнитель" to "ИП Иванов",
                    "Подрядчик" to "ООО Подряд",
                    "Ответственный инспектор" to "Петров П.П.",
                    "Координаты" to "55.7558, 37.6176"
                ),
                mapOf(
                    "Адрес" to "г. Москва, ул. Флотская, д. 54,58к1",
                    "Статус" to "В процессе",
                    "Заказчик" to "ООО Рога и Копыта",
                    "Исполнитель" to "ИП Иванов",
                    "Подрядчик" to "ООО Подряд",
                    "Ответственный инспектор" to "Петров П.П.",
                    "Координаты" to "55.7558, 37.6176"
                ),
                mapOf(
                    "Адрес" to "г. Москва, ул. Флотская, д. 54,58к1",
                    "Статус" to "В процессе",
                    "Заказчик" to "ООО Рога и Копыта",
                    "Исполнитель" to "ИП Иванов",
                    "Подрядчик" to "ООО Подряд",
                    "Ответственный инспектор" to "Петров П.П.",
                    "Координаты" to "55.7558, 37.6176"
                ),
                mapOf(
                    "Адрес" to "г. Москва, ул. Флотская, д. 54,58к1",
                    "Статус" to "В процессе",
                    "Заказчик" to "ООО Рога и Копыта",
                    "Исполнитель" to "ИП Иванов",
                    "Подрядчик" to "ООО Подряд",
                    "Ответственный инспектор" to "Петров П.П.",
                    "Координаты" to "55.7558, 37.6176"
                ),
                mapOf(
                    "Адрес" to "г. Москва, ул. Флотская, д. 54,58к1",
                    "Статус" to "В процессе",
                    "Заказчик" to "ООО Рога и Копыта",
                    "Исполнитель" to "ИП Иванов",
                    "Подрядчик" to "ООО Подряд",
                    "Ответственный инспектор" to "Петров П.П.",
                    "Координаты" to "55.7558, 37.6176"
                ),
                mapOf(
                    "Адрес" to "г. Москва, ул. Ленина, д. 5",
                    "Статус" to "в норме",
                    "Заказчик" to "ООО СтройИнвест",
                    "Исполнитель" to "ИП Сидоров",
                    "Подрядчик" to "ООО Гарант",
                    "Ответственный инспектор" to "Сидоров С.С.",
                    "Координаты" to "59.9343, 30.3351"
                )

            )
        }
        androidx.compose.foundation.rememberScrollState().let { scrollState ->
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .verticalScroll(scrollState)
            ) {
                dbRecords.forEachIndexed { index, item ->
                    var expandedRecord by remember { mutableStateOf(false) }
                    val transition =
                        updateTransition(targetState = expandedRecord, label = "expandTransition")
                    val animatedAlpha by transition.animateFloat(label = "expandAlpha") { expanded -> if (expanded) 1f else 0f }

                    Column(
                        modifier = Modifier
                            .fillMaxWidth(0.9f)
                            .background(Color.White)
                            .border(0.5.dp, Color.Gray, RoundedCornerShape(6.dp))
                            .align(Alignment.CenterHorizontally)
                            .padding(all = 12.dp)
                            .padding(bottom = 16.dp),
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(IntrinsicSize.Min),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Column(
                                verticalArrangement = Arrangement.Center,
                                horizontalAlignment = Alignment.Start,
                                modifier = Modifier
                                    .weight(1f)
                                    .clickable() {
                                        changeScreen(Screen.OBJECT)
                                    }
                            ) {
                                Text(
                                    text = "\uD83D\uDCCDАдрес: ${item["Адрес"]}",
                                    fontSize = 18.sp,
                                    color = Color.Black,
                                    fontWeight = FontWeight.Medium,
                                    maxLines = Int.MAX_VALUE,
                                    softWrap = true,
                                    modifier = Modifier.fillMaxWidth()
                                )
                                Spacer(modifier = Modifier.height(10.dp))
                                Text(
                                    text = "Статус: ${item["Статус"]}",
                                    fontSize = 18.sp,
                                    color = Color.Black,
                                    fontWeight = FontWeight.Medium,
                                    maxLines = Int.MAX_VALUE,
                                    softWrap = true,
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }
                            Button(
                                onClick = { expandedRecord = !expandedRecord },
                                shape = RoundedCornerShape(8.dp),
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = Color.White,
                                    contentColor = Color.Black,
                                ),
                                modifier = Modifier
                                    .height(40.dp)
                                    .padding(start = 8.dp),
                                contentPadding = PaddingValues(0.dp)
                            ) {
                                Text(
                                    text = if (expandedRecord) "▲" else "▼",
                                    fontSize = 32.sp,
                                    color = Color.Black
                                )
                            }
                        }
                        AnimatedVisibility(
                            visible = expandedRecord,
                            enter = expandVertically() + fadeIn(),
                            exit = shrinkVertically() + fadeOut()
                        ) {
                            Column(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .alpha(animatedAlpha)
                            ) {
                                Spacer(modifier = Modifier.height(4.dp))
                                item.forEach { (key, value) ->
                                    if (key != "Адрес" && key != "Статус") {
                                        Text(
                                            text = "$key: $value",
                                            fontSize = 20.sp,
                                            color = Color.Black,
                                            maxLines = Int.MAX_VALUE,
                                            softWrap = true,
                                            modifier = Modifier.fillMaxWidth()
                                        )
                                        Spacer(modifier = Modifier.height(4.dp))
                                    }
                                }
                            }
                        }
                    }
                    Spacer(modifier = Modifier.height(20.dp))
                }
            }
        }
    }
}
@Composable
@Preview
fun MainScreenPreview(){
    DependencyBuilder.registryDependency(IAuthProviderDIToken, DummyAuthProvider())
    DependencyBuilder.registryDependency(IAuthStorageProviderDIToken, DummyAuthStorageProvider())
    DependencyBuilder.registryDependency(I_SSO_DI_TOKEN, "dummy")
    val di = normalBuilder(DependencyBuilder)
    MainScreen(di,{},{})
}



