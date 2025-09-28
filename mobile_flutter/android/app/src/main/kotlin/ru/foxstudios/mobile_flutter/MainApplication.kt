package ru.foxstudios.mobile_flutter;
import io.flutter.Log;

import android.app.Application;

import com.yandex.mapkit.MapKitFactory;

public class MainApplication: Application() {
  override fun onCreate() {
    super.onCreate()
    Log.e("MY", "HI FROM YANDEX MAPKIT SETUP")
    println("HI FROM YANDEX MAPKIT SETUP")
    MapKitFactory.setApiKey("16cba6ee-062c-4a78-b5e8-8b10014d85f0")
  }
}