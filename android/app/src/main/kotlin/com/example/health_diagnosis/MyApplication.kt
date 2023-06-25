package com.example.health_diagnosis

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.app.FlutterApplication

class MyApplication : FlutterApplication(){

    override fun onCreate() {
        super.onCreate()
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            val channel = NotificationChannel("messages","messages",
                NotificationManager.IMPORTANCE_HIGH)
            val manager : NotificationManager = getSystemService(NotificationManager::class.java)

            manager.createNotificationChannel(channel)
        }
    }
}
