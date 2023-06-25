package com.example.health_diagnosis

import android.Manifest
import android.app.Service
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.telephony.PhoneStateListener
import android.telephony.SmsManager
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.google.firebase.database.*
import io.flutter.Log


class NotificationService : Service() {

    private var heartRate: String = "Loading..."
    private var oxygenLevel: String = "Loading..."
    private var temperatureBody: String = "Loading..."
    private lateinit var builder: NotificationCompat.Builder
    private val numbersList = ArrayList<String>()

    @RequiresApi(api = Build.VERSION_CODES.S)
    private abstract class CallStateListener : TelephonyCallback(),
        TelephonyCallback.CallStateListener {
        abstract override fun onCallStateChanged(state: Int)
    }

    private var callStateListenerRegistered = false

    private val callStateListener: CallStateListener? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) object : CallStateListener() {
            override fun onCallStateChanged(state: Int) {
                android.util.Log.d("MyPhoneListener", "$state ")

            }
        }
        else null

    private val phoneStateListener: PhoneStateListener? =
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) object : PhoneStateListener() {
            override fun onCallStateChanged(state: Int, phoneNumber: String) {

                android.util.Log.d("MyPhoneListener", "$state incoming no:$phoneNumber")

                // zero state is CALL_STATE_IDLE
                if (state == 0) {
                    val msg = "New Phone Call Event. Phone Number : $phoneNumber"
                    android.util.Log.d("MyPhoneListener", msg)
                }
            }
        }
        else null

    override fun onCreate() {

        val sharedPref: SharedPreferences = applicationContext.getSharedPreferences(
            "FlutterSharedPreferences",
            MODE_PRIVATE
        )

        val numbersCount = sharedPref.getLong("flutter.phoneNumbersCount", 0)
        Log.v("numbersCount", numbersCount.toString())

        for (i in 0..numbersCount) {
            val number = sharedPref.getString("flutter.phoneNumber_$i", null)
            if (number != null) {
                Log.v("numbersCount", number);
                numbersList.add(number)
            } else break
        }
        buildNotification()
        super.onCreate()
    }

    @RequiresApi(Build.VERSION_CODES.M)
    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        val connectivityManager =
            getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        if (connectivityManager.activeNetworkInfo == null ||
            connectivityManager.activeNetworkInfo?.isConnected == false
        ) {
            val smsManager: SmsManager = SmsManager.getDefault()
            for (number in numbersList) {
                smsManager.sendTextMessage(
                    "+20$number", null,
                    "The internet has stopped",
                    null, null
                )
            }
        }
        val networkCallback = object : ConnectivityManager.NetworkCallback() {

            override fun onAvailable(network: Network) {
                val database: FirebaseDatabase = FirebaseDatabase.getInstance()
                database.getReference("heartRate").addValueEventListener(
                    object : ValueEventListener {
                        override fun onDataChange(snapshot: DataSnapshot) {
                            heartRate = snapshot.value.toString()
                            println(snapshot.value)
                            Log.v("Firebase RD", snapshot.value.toString())
                            if (Integer.parseInt(snapshot.value.toString()).toLong() > 300) {
                                try {
                                    for (number in numbersList) {
                                        val intentCall = Intent(Intent.ACTION_CALL)
                                        intentCall.data = Uri.parse("tel:+20$number")
                                        intentCall.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                        sendBroadcast(
                                            intent,
                                            "android.intent.action.CALL",
                                        )
                                        startActivity(intentCall)

                                    }
                                } catch (e: ActivityNotFoundException) {
                                    println("Sample call in androidCall failed $e")
                                }
                            }

                            Toast.makeText(
                                applicationContext, snapshot.value.toString(),
                                Toast.LENGTH_SHORT
                            ).show()
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                buildNotification()
                            }
                        }

                        override fun onCancelled(error: DatabaseError) {
                            Log.v("FirebaseError", error.message)
                        }
                    })

                database.getReference("temperature").addValueEventListener(
                    object : ValueEventListener {
                        override fun onDataChange(snapshot: DataSnapshot) {
                            temperatureBody = snapshot.value.toString()
                            println(snapshot.value)
                            Log.v("Firebase RD", snapshot.value.toString())
                            if (Integer.parseInt(snapshot.value.toString()).toLong() > 300) {
                                try {
                                    for (number in numbersList) {
                                        val intentCall = Intent(Intent.ACTION_CALL)
                                        intentCall.data = Uri.parse("tel:+20$number")
                                        intentCall.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                        sendBroadcast(
                                            intent,
                                            "android.intent.action.CALL",
                                        )
                                        startActivity(intentCall)

                                    }
                                } catch (e: ActivityNotFoundException) {
                                    println("Sample call in androidCall failed $e")
                                }
                            }
                            Toast.makeText(
                                applicationContext, snapshot.value.toString(),
                                Toast.LENGTH_SHORT
                            ).show()
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                buildNotification()
                            }
                        }

                        override fun onCancelled(error: DatabaseError) {
                            Log.v("FirebaseError", error.message)
                        }
                    })

                database.getReference("spO2").addValueEventListener(
                    object : ValueEventListener {
                        override fun onDataChange(snapshot: DataSnapshot) {
                            oxygenLevel = snapshot.value.toString()
                            println(snapshot.value)
                            Log.v("Firebase RD", snapshot.value.toString())
                            if (Integer.parseInt(snapshot.value.toString()).toLong() > 300) {
                                try {

                                    for (number in numbersList) {
                                        val intentCall = Intent(Intent.ACTION_CALL)
                                        intentCall.data = Uri.parse("tel:+20$number")
                                        intentCall.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                        sendBroadcast(
                                            intent,
                                            "android.intent.action.CALL",
                                        )
                                        startActivity(intentCall)

                                    }

                                } catch (e: ActivityNotFoundException) {
                                    println("Sample call in androidCall failed $e")
                                }
                            }
                            Toast.makeText(
                                applicationContext, snapshot.value.toString(),
                                Toast.LENGTH_SHORT
                            ).show()
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                buildNotification()
                            }
                        }

                        override fun onCancelled(error: DatabaseError) {
                            Log.v("FirebaseError", error.message)
                        }
                    })
            }

            override fun onLost(network: Network) {
                Toast.makeText(
                    applicationContext, network.toString(),
                    Toast.LENGTH_SHORT
                ).show()
                // Call SMS
                val smsManager: SmsManager = SmsManager.getDefault()

                for (number in numbersList) {
                    smsManager.sendTextMessage(
                        "+20$number", null,
                        "The internet has stopped",
                        null, null
                    )
                }
            }
        }

        val networkRequest = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()

        connectivityManager.registerNetworkCallback(networkRequest, networkCallback)
        onTaskRemoved(intent)
        return START_STICKY
    }

    private fun buildNotification() {
        builder =
            NotificationCompat.Builder(this, "messages")
                .setContentTitle("Your current health status...")
                .setContentText("Drag Down to know your status")
                .setStyle(
                    NotificationCompat.BigTextStyle().bigText(
                        "Your Heart Rate: $heartRate\n" +
                                "Your SpO2: $oxygenLevel\n" +
                                "Your Temperature Body: $temperatureBody"
                    )
                )
                .setSound(null)
                .setSmallIcon(R.drawable.caduceus)
        startForeground(888, builder.build())
    }

    override fun onTaskRemoved(rootIntent: Intent) {
        val restartServiceIntent = Intent(applicationContext, this.javaClass)
        restartServiceIntent.setPackage(packageName)
        super.onTaskRemoved(rootIntent)
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

}