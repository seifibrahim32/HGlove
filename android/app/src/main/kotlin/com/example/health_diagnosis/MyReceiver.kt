package com.example.health_diagnosis

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import android.util.Log
import android.widget.Toast


class MyReceiver: BroadcastReceiver() {
    private lateinit var contextp : Context;
    @SuppressLint("UnsafeProtectedBroadcastReceiver")
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context != null) {
            contextp = context
        };
        try {
            val tmgr = context?.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            val PhoneListener = MyPhoneStateListener()
            tmgr.listen(PhoneListener, PhoneStateListener.LISTEN_CALL_STATE)
        } catch (e: Exception) {
            Log.e("Phone Receive Error", " $e")
        }
        Toast.makeText(context, intent?.action, Toast.LENGTH_LONG).show()
    }
    private class MyPhoneStateListener : PhoneStateListener() {
        @Deprecated("Deprecated in Java")
        override fun onCallStateChanged(state: Int, phoneNumber: String) {
            Log.d("MyPhoneListener", "$state incoming no:$phoneNumber")

            // zero state is CALL_STATE_IDLE
            if (state == 0) {
                val msg = "New Phone Call Event. Phone Number : $phoneNumber"
                Log.d("MyPhoneListener", msg)
            }
        }
    }

}