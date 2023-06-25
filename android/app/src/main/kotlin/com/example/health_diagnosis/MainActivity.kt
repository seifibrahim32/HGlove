package com.example.health_diagnosis

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.view.WindowCompat
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity(), FlutterPlugin {

    private val CHANNEL = "samples.flutter.dev/HGlove"

    private lateinit var forService: Intent
    private lateinit var contextFlutter: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        contextFlutter = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        contextFlutter = binding.applicationContext
    }

    @RequiresApi(Build.VERSION_CODES.S)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Aligns the Flutter view vertically with the window.
        WindowCompat.setDecorFitsSystemWindows(window, false)

        if (ActivityCompat.checkSelfPermission(
                this, Manifest.permission.CALL_PHONE
            ) != PackageManager.PERMISSION_GRANTED
            && ActivityCompat.checkSelfPermission(
                this, Manifest.permission.SEND_SMS
            ) != PackageManager.PERMISSION_GRANTED

        ) {
            ActivityCompat.requestPermissions(
                this, arrayOf(
                    Manifest.permission.CALL_PHONE,
                    Manifest.permission.SEND_SMS
                ), 11
            )
        }

        val sharedPref: SharedPreferences = applicationContext.getSharedPreferences(
            "FlutterSharedPreferences",
            MODE_PRIVATE
        )
        val username = sharedPref.getString("flutter.username", null)
        if (username?.isNotEmpty() == true) {
            grantNotification()
            startService()
        }

    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            11 -> {
                if ((grantResults.isNotEmpty()) && (grantResults[0] ==
                            PackageManager.PERMISSION_GRANTED)
                ) {
                    return
                } else {
                    // permission was not granted
                    if (ActivityCompat.shouldShowRequestPermissionRationale(
                            this, Manifest.permission.CALL_PRIVILEGED
                        )
                        || ActivityCompat.shouldShowRequestPermissionRationale(
                            this, Manifest.permission.CALL_PHONE
                        )
                        || ActivityCompat.shouldShowRequestPermissionRationale(
                            this, Manifest.permission.SEND_SMS
                        )
                    ) {
                        Toast.makeText(
                            applicationContext, "Needs permission",
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                }
            }
        }

    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "login" -> {

                    val sharedPref: SharedPreferences = applicationContext.getSharedPreferences(
                        "FlutterSharedPreferences",
                        MODE_PRIVATE
                    )

                    val numbersCount = sharedPref.getLong("flutter.phoneNumbersCount",
                        0)
                    Log.v("numbersCount", numbersCount.toString())
                    grantNotification()
                    startService()
                    result.success(0)
                }
                "logOut" -> {
                    stopService(forService)
                    result.success(0)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun grantNotification() {
        val filter = IntentFilter(Intent.ACTION_CALL)
        registerReceiver(MyReceiver(), filter)
        forService = Intent(this, NotificationService::class.java)
        this.flutterEngine?.let { GeneratedPluginRegistrant.registerWith(it) }
    }

    private fun startService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(forService)
        } else {
            startService(forService)
        }
    }

}