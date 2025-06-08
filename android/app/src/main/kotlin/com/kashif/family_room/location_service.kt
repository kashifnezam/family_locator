package com.kashif.family_room

import android.annotation.TargetApi
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.location.Location
import android.os.Build
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.*
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.SetOptions
import org.json.JSONArray
import org.json.JSONObject
import android.content.pm.ServiceInfo


class LocationService : Service() {

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback

    override fun onCreate() {
        super.onCreate()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        createNotificationChannel()
        startForegroundService()
        startLocationUpdates()
    }

    @TargetApi(Build.VERSION_CODES.ECLAIR)
    private fun startForegroundService() {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Family Room Service")
            .setContentText("Please Enjoy our service")
            .setSmallIcon(R.drawable.ic_launcher)
            .setContentIntent(pendingIntent)
            .build()

        val foregroundServiceType =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
                ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
            else
                null

        if (foregroundServiceType != null) {
            startForeground(1, notification, foregroundServiceType)
        } else {
            startForeground(1, notification)
        }
    }

    private fun getDeviceIdFromSharedPreferences(): String {
        val sharedPref = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        return sharedPref.getString("flutter.deviceId", "") ?: ""
    }

    private fun startLocationUpdates() {
        val locationRequest = LocationRequest.create().apply {
            interval = 10000L
            fastestInterval = 5000L
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        }

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                locationResult ?: return
                for (location in locationResult.locations) {
                    sendLocationToServer(location)
                }
            }
        }

        fusedLocationClient.requestLocationUpdates(
            locationRequest,
            locationCallback,
            Looper.getMainLooper()
        )
    }

    private fun sendLocationToServer(location: Location) {
        val firestore = FirebaseFirestore.getInstance()
        val userId = getDeviceIdFromSharedPreferences()

        if (userId.isEmpty()) {
            Log.e("LocationSharing", "Device ID not found in SharedPreferences")
            return
        }

        // Save location locally in SharedPreferences for batching or future use
        LocationUtils.addLocationToSharedPrefs(applicationContext, location.latitude, location.longitude)

        val locationString = "LatLng(latitude:${location.latitude}, longitude:${location.longitude})"

        val locationData = hashMapOf(
            "currLoc" to locationString
        )


        firestore.collection("anonymous")
            .document(userId)
            .set(locationData, SetOptions.merge())
            .addOnSuccessListener {
                Log.d("LocationSharing", "Location updated in Firestore successfully")
            }
            .addOnFailureListener { e ->
                Log.e("LocationSharing", "Error updating location in Firestore: ${e.message}")
            }
    }

    override fun onDestroy() {
        super.onDestroy()
        fusedLocationClient.removeLocationUpdates(locationCallback)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Location Service Channel",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    fun stopService() {
        stopForeground(true)
        stopSelf()
        Log.d("LocationService", "Service stopped")
    }

    companion object {
        private const val CHANNEL_ID = "LocationServiceChannel"
    }
}

object LocationUtils {
    fun addLocationToSharedPrefs(context: Context, latitude: Double, longitude: Double) {
        // Get deviceId from FlutterSharedPreferences
        val flutterPrefs: SharedPreferences =
            context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val deviceId = flutterPrefs.getString("flutter.deviceId", "") ?: ""

        // Prepare location storage in separate SharedPreferences
        val locationPrefs = context.getSharedPreferences("LocationData", Context.MODE_PRIVATE)
        val locationsJsonString = locationPrefs.getString("location_list", "[]")
        val jsonArray = JSONArray(locationsJsonString)

        val locationObject = JSONObject().apply {
            put("latitude", latitude)
            put("longitude", longitude)
            put("deviceId", deviceId)
            put("timestamp", System.currentTimeMillis())
        }

        jsonArray.put(locationObject)
        locationPrefs.edit().putString("location_list", jsonArray.toString()).apply()
    }
}
