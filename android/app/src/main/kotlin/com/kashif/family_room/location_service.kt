package com.kashif.family_room

import kotlin.math.roundToInt
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

    private fun getUIDFromSharedPreferences(): String {
        val sharedPref = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        return sharedPref.getString("flutter.uid", "") ?: ""
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
        val userId = getUIDFromSharedPreferences()

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


        firestore.collection("user")
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

    private const val THRESHOLD_METERS = 30.0

    fun addLocationToSharedPrefs(context: Context, latitude: Double, longitude: Double) {
        val prefs = context.getSharedPreferences("LocationData", Context.MODE_PRIVATE)
        val encoded = prefs.getString("encoded_polyline", "") ?: ""

        // Decode existing polyline into list of points
        val latLngList = PolylineDecoder.decode(encoded).toMutableList()

        val newPoint = Pair(latitude, longitude)

        // Only add if movement is significant
        if (latLngList.isNotEmpty()) {
            val last = latLngList.last()
            val distance = haversineDistance(last.first, last.second, newPoint.first, newPoint.second)
            if (distance < THRESHOLD_METERS) {
                return // Do not store insignificant movement
            }
        }

        latLngList.add(newPoint)
        val newEncoded = PolylineEncoder.encode(latLngList)

        prefs.edit().putString("encoded_polyline", newEncoded).apply()
    }

    private fun haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double): Double {
        val R = 6371000.0 // Earth radius in meters
        val dLat = Math.toRadians(lat2 - lat1)
        val dLon = Math.toRadians(lon2 - lon1)
        val a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                Math.sin(dLon / 2) * Math.sin(dLon / 2)
        val c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
        return R * c
    }
}


object PolylineEncoder {

    fun encode(points: List<Pair<Double, Double>>): String {
        var prevLat = 0
        var prevLng = 0
        val result = StringBuilder()

        for ((lat, lng) in points) {
            val latE5 = (lat * 1e5).roundToInt()
            val lngE5 = (lng * 1e5).roundToInt()

            val dLat = latE5 - prevLat
            val dLng = lngE5 - prevLng

            encodeValue(dLat, result)
            encodeValue(dLng, result)

            prevLat = latE5
            prevLng = lngE5
        }

        return result.toString()
    }

    private fun encodeValue(v: Int, result: StringBuilder) {
        var value = if (v < 0) {
            // For negative numbers: ZigZag encoding
            (v shl 1).inv()  // Replaced ~(v shl 1) with (v shl 1).inv()
        } else {
            // For non-negative numbers
            v shl 1
        }

        while (value >= 0x20) {
            result.append(((0x20 or (value and 0x1f)) + 63).toChar())
            value = value shr 5
        }
        result.append((value + 63).toChar())
    }}
object PolylineDecoder {
    fun decode(encoded: String): List<Pair<Double, Double>> {
        val poly = mutableListOf<Pair<Double, Double>>()
        var index = 0
        val len = encoded.length
        var lat = 0
        var lng = 0

        while (index < len) {
            val resultLat = decodeValue(encoded, index)
            index = resultLat.second
            lat += resultLat.first

            val resultLng = decodeValue(encoded, index)
            index = resultLng.second
            lng += resultLng.first

            val latitude = lat / 1e5
            val longitude = lng / 1e5
            poly.add(Pair(latitude, longitude))
        }

        return poly
    }

    private fun decodeValue(encoded: String, startIndex: Int): Pair<Int, Int> {
        var index = startIndex
        var shift = 0
        var result = 0

        while (true) {
            val b = encoded[index++].code - 63
            result = result or ((b and 0x1F) shl shift)
            shift += 5
            if (b < 0x20) break
        }

        val delta = if ((result and 1) != 0) -(result shr 1) else (result shr 1)
        return Pair(delta, index)
    }
}
