package ru.foxstudios.digital_building_journal.screens

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.runtime.getValue
import androidx.compose.ui.text.style.TextAlign

@Composable
fun SplashScreen(showSplash: Boolean) {
    val alpha by animateFloatAsState(
        targetValue = if (showSplash) 1f else 0f,
        animationSpec = androidx.compose.animation.core.tween(1000),
        label = "splashAlpha"
    )
    Spacer(modifier = Modifier.height(24.dp))
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                "Электронный строительный журнал",
                color = Color.Black,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.alpha(alpha),
                textAlign = TextAlign.Center,
            )
            Spacer(modifier = Modifier.height(30.dp))
            CircularProgressIndicator(
                color = Color.Blue,
                modifier = Modifier.alpha(alpha)
            )
            Spacer(modifier = Modifier.height(25.dp))
            Text(
                "Загрузка...",
                color = Color.Black,
                fontSize = 16.sp,
                modifier = Modifier.alpha(alpha)
            )
        }
    }
}