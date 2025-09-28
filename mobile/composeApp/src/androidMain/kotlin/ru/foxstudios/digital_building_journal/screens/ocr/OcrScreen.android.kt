package ru.foxstudios.digital_building_journal.screens.ocr

import android.Manifest
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
//import android.media.ExifInterface
import androidx.exifinterface.media.ExifInterface
import android.util.Log
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.animation.core.VisibilityThreshold
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.vector.VectorPainter
import androidx.compose.ui.layout.Layout
import androidx.compose.ui.layout.Placeable
import androidx.compose.ui.layout.RectRulers
import androidx.compose.ui.layout.WindowInsetsRulers.Companion.SafeContent
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import androidx.lifecycle.compose.LocalLifecycleOwner
import com.google.accompanist.permissions.ExperimentalPermissionsApi
import com.google.accompanist.permissions.isGranted
import com.google.accompanist.permissions.rememberPermissionState
import ru.foxstudios.authlib.auth.IAuthProviderDIToken
import ru.foxstudios.authlib.auth.IAuthStorageProviderDIToken
import ru.foxstudios.dependency_container.DependencyBuilder
import ru.foxstudios.dependency_container.IContainer
import ru.foxstudios.digital_building_journal.R
import ru.foxstudios.digital_building_journal.Screen
import ru.foxstudios.digital_building_journal.di.I_SSO_DI_TOKEN
import ru.foxstudios.digital_building_journal.di.normalBuilder
import ru.foxstudios.digital_building_journal.dummy.DummyAuthProvider
import ru.foxstudios.digital_building_journal.dummy.DummyAuthStorageProvider
import ru.foxstudios.digital_building_journal.neural_network.IOcrDIToken
import ru.foxstudios.digital_building_journal.neural_network.IOcrEngine
import ru.foxstudios.digital_building_journal.nn.DummyAndroidTesseractOcrEngine
import ru.foxstudios.digital_building_journal.screens.ocr.AppStyle.MainColor
import ru.foxstudios.digital_building_journal.screens.ocr.AppStyle.OnMainColor
import java.io.ByteArrayOutputStream
import java.io.File


//enum class OcrState : MutableState<OcrState> {
//    GREET,
//    UNPERMITTED,
//    CAMERA,
//    PRE_PROCESSING,
//    PROCESSING,
//    POST_PROCESSING,
//    RESULT,
//    ERROR
//}

@OptIn(ExperimentalPermissionsApi::class)
@Composable
actual fun OcrScreen(
    di: IContainer,
    changeScreen: (Screen) -> Unit,
    function: () -> Unit
) {
    Ocr(di, changeScreen, function)
//    val context = LocalContext.current
//    val lifecycleOwner = LocalLifecycleOwner.current
//    val tess = di.get<IOcrEngine>(IOcrDIToken)
//
//    val cameraPermissionState = rememberPermissionState(Manifest.permission.CAMERA)
//
//    LaunchedEffect(Unit) {
//        if (!cameraPermissionState.status.isGranted) {
//            cameraPermissionState.launchPermissionRequest()
//        }
//    }
//
//    var imageCapture: ImageCapture? by remember { mutableStateOf(null) }
//    var lastCapturedPath by remember { mutableStateOf<String?>(null) }
//
//    Column(Modifier.fillMaxSize()) {
//        AndroidView(
//            modifier = Modifier.weight(1f),
//            factory = { ctx ->
//                val previewView = PreviewView(ctx)
//
//                val cameraProviderFuture = ProcessCameraProvider.getInstance(ctx)
//                cameraProviderFuture.addListener({
//                    val cameraProvider = cameraProviderFuture.get()
//
//                    val preview = Preview.Builder().build().also {
//                        it.setSurfaceProvider(previewView.surfaceProvider)
//                    }
//
//                    imageCapture = ImageCapture.Builder().build()
//
//                    try {
//                        cameraProvider.unbindAll()
//                        cameraProvider.bindToLifecycle(
//                            lifecycleOwner,
//                            CameraSelector.DEFAULT_BACK_CAMERA,
//                            preview,
//                            imageCapture
//                        )
//                    } catch (e: Exception) {
//                        Log.e("OCR", "Camera binding failed", e)
//                    }
//                }, ContextCompat.getMainExecutor(ctx))
//
//                previewView
//            }
//        )
//        Button(
//            onClick = {
//                val photoFile = File(
//                    context.filesDir,
//                    "captured.jpg"
//                )
//                val outputOptions = ImageCapture.OutputFileOptions.Builder(photoFile).build()
//                imageCapture?.takePicture(
//                    outputOptions,
//                    ContextCompat.getMainExecutor(context),
//                    object : ImageCapture.OnImageSavedCallback {
//                        override fun onImageSaved(output: ImageCapture.OutputFileResults) {
//                            lastCapturedPath = photoFile.absolutePath
//                            Log.d("OCR", "Image saved: $lastCapturedPath")
//                            lastCapturedPath?.let { path ->
//                                val ei = ExifInterface(path)
//                                val bitmap = BitmapFactory.decodeFile(path)
//                                val orientation = ei.getAttributeInt(
//                                    ExifInterface.TAG_ORIENTATION,
//                                    ExifInterface.ORIENTATION_UNDEFINED
//                                )
//                                fun Bitmap.rotate(degrees: Float): Bitmap {
//                                    val matrix = Matrix()
//                                    matrix.postRotate(degrees)
//                                    return Bitmap.createBitmap(this, 0, 0, width, height, matrix, true)
//                                }
//                                val rotatedBitmap = when (orientation) {
//                                    ExifInterface.ORIENTATION_ROTATE_90 -> bitmap.rotate(90f)
//                                    ExifInterface.ORIENTATION_ROTATE_180 -> bitmap.rotate(180f)
//                                    ExifInterface.ORIENTATION_ROTATE_270 -> bitmap.rotate(270f)
//                                    else -> bitmap
//                                }
//                                val stream = ByteArrayOutputStream()
//                                rotatedBitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream)
//                                val boxes = tess.recognize(stream.toByteArray())
//                                Log.d("OCR", "Boxes: $boxes")
//                            }
//                        }
//
//                        override fun onError(exc: ImageCaptureException) {
//                            Log.e("OCR", "Capture failed: ${exc.message}", exc)
//                        }
//                    }
//                )
//            },
//            modifier = Modifier.fillMaxWidth()
//        ) {
//            Text("Capture")
//        }
//
//        lastCapturedPath?.let {
//            Text("Last captured: $it", modifier = Modifier.padding(8.dp))
//        }
//    }
}

// experemental
object AppStyle {
    val MainColor = Color(0.80f, 0.2f, 0.2f, 1.0f)
    val OnMainColor = Color.White
    val ShadowedAreaColor = Color(0.2f, 0.2f, 0.2f, 0.2f)

    @Composable
    fun ButtonColors() = ButtonDefaults.buttonColors(
        containerColor = MainColor,
        contentColor = OnMainColor
    )
}

fun Typography.scaled(factor: Float) = Typography(
    displayLarge = displayLarge.copy(fontSize = displayLarge.fontSize * factor),
    displayMedium = displayMedium.copy(fontSize = displayMedium.fontSize * factor),
    displaySmall = displaySmall.copy(fontSize = displaySmall.fontSize * factor),
    headlineLarge = headlineLarge.copy(fontSize = headlineLarge.fontSize * factor),
    headlineMedium = headlineMedium.copy(fontSize = headlineMedium.fontSize * factor),
    headlineSmall = headlineSmall.copy(fontSize = headlineSmall.fontSize * factor),
    titleLarge = titleLarge.copy(fontSize = titleLarge.fontSize * factor),
    titleMedium = titleMedium.copy(fontSize = titleMedium.fontSize * factor),
    titleSmall = titleSmall.copy(fontSize = titleSmall.fontSize * factor),
    bodyLarge = bodyLarge.copy(fontSize = bodyLarge.fontSize * factor),
    bodyMedium = bodyMedium.copy(fontSize = bodyMedium.fontSize * factor),
    bodySmall = bodySmall.copy(fontSize = bodySmall.fontSize * factor),
    labelLarge = labelLarge.copy(fontSize = labelLarge.fontSize * factor),
    labelMedium = labelMedium.copy(fontSize = labelMedium.fontSize * factor),
    labelSmall = labelSmall.copy(fontSize = labelSmall.fontSize * factor)
)

// experemental # 2
@Composable
fun MyAppTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = lightColorScheme(
            primary = Color(0.80f, 0.2f, 0.2f, 1.0f), // main - button color
            secondary = Color.Green,
            outline = Color.Yellow,
            background = Color.Cyan,
            surface = Color.Red,
            surfaceContainerLow = Color.White, // bottom sheet background
        ),
        typography = Typography().scaled(1.5f)
    ) {
        content()
    }
}



@Composable
fun Greet(
    onBackClick: () -> Unit,
    onRecognizeClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White),
        contentAlignment = Alignment.Center
    ) {
        Column(
            modifier = Modifier.width(IntrinsicSize.Min),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Button(
                onClick = onRecognizeClick,
//                colors = AppStyle.ButtonColors(),
//                shape = MaterialTheme.shapes.small,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Recognize")
            }

            Button(
                onClick = onBackClick,
//                colors = AppStyle.ButtonColors(),
//                shape = MaterialTheme.shapes.small,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Back")
            }
        }
    }
}

enum class RecognizeType {
    TTN,
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RecognizeSelector(
    onBackClick: () -> Unit,
    onRecognizeSelected: (RecognizeType) -> Unit,
    items: @Composable () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onBackClick,
        modifier = Modifier.widthIn(0.dp, 600.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(0.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            items()
        }
    }
}

@Composable
fun Ocr(
    di: IContainer,
    changeScreen: (Screen) -> Unit,
    function: () -> Unit
){
//    var state = remember { mutableStateOf<OcrState>(OcrState.GREET) }
    var recognizeSelectorOpen = remember { mutableStateOf(true) }
//    var recognizeType = remember { mutableStateOf<RecognizeType?>(null) }
    MyAppTheme {
        // add prev screen. (or screen history)
        Greet({ changeScreen(Screen.MAIN) }, { recognizeSelectorOpen.value = true })
        if (recognizeSelectorOpen.value) {
            RecognizeSelector(
                onBackClick = { recognizeSelectorOpen.value = false },
                onRecognizeSelected = { /*typeSelected -> recognizeType = typeSelected; state = OcrState.UNPERMITTED*/ },
            ){
                Button(
                    onClick = {},
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.White, contentColor = Color.Black),
                    shape = RoundedCornerShape(0.dp),
                ){Text("TTN", modifier = Modifier.fillMaxWidth().padding(horizontal=8.dp, vertical=8.dp))}
                Button(
                    onClick = {},
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.White, contentColor = Color.Black),
                    shape = RoundedCornerShape(0.dp),
                ){Text("Yandex", modifier = Modifier.fillMaxWidth().padding(horizontal=8.dp, vertical=8.dp))}
                Button(
                    onClick = {},
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.White, contentColor = Color.Black, ),
                    shape = RoundedCornerShape(0.dp),
                ){Text("Dota", modifier = Modifier.fillMaxWidth().padding(horizontal=8.dp, vertical=8.dp))}
                Button(
                    onClick = {},
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.White, contentColor = Color.Black),
                    shape = RoundedCornerShape(0.dp),
                ){Text("Pudge", modifier = Modifier.fillMaxWidth().padding(horizontal=8.dp, vertical=8.dp))}
            }
        }
    }
}


@org.jetbrains.compose.ui.tooling.preview.Preview
@Composable
fun OcrScreenPreview() {
    DependencyBuilder.registryDependency(IAuthProviderDIToken, DummyAuthProvider())
    DependencyBuilder.registryDependency(IAuthStorageProviderDIToken, DummyAuthStorageProvider())
    DependencyBuilder.registryDependency(I_SSO_DI_TOKEN, "dummy")
    val nn = DummyAndroidTesseractOcrEngine()
    val r = nn.init()
    DependencyBuilder.registryDependency(IOcrDIToken, nn)
    val di = normalBuilder(DependencyBuilder)
//    OcrScreen(di, {}) {}
    Ocr(di, {}, {})
}