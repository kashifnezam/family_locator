package com.kashif.family_room

import UploadWorker
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import androidx.work.*
import java.util.concurrent.TimeUnit
import android.content.Context
import org.json.JSONArray
import org.json.JSONObject



class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.kashif.location_service"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startLocationUpdates") {
                startService()
                startBackgroundWorker() // <-- Schedule WorkManager job
                result.success(null)
            } else if (call.method == "stopLocationUpdates") {
                stopService()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startService() {
        val serviceIntent = Intent(this, LocationService::class.java)
        startService(serviceIntent)
    }

    private fun stopService() {
        val serviceIntent = Intent(this, LocationService::class.java)
        stopService(serviceIntent)
    }

    private fun startBackgroundWorker() {

//        val testRequest = OneTimeWorkRequestBuilder<UploadWorker>().build()
//
//        WorkManager.getInstance(applicationContext).enqueue(testRequest)


        val uploadWorkRequest = PeriodicWorkRequestBuilder<UploadWorker>(15, TimeUnit.MINUTES)
            .build()

        WorkManager.getInstance(applicationContext).enqueueUniquePeriodicWork(
            "UploadWorker",
            ExistingPeriodicWorkPolicy.KEEP,
            uploadWorkRequest
        )
    }
}