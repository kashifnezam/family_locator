package com.kashif.family_room

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters
import android.util.Log
import com.google.firebase.database.FirebaseDatabase
import org.json.JSONArray

class UploadWorker(appContext: Context, workerParams: WorkerParameters) : Worker(appContext, workerParams) {

    override fun doWork(): Result {
        val sharedPref = applicationContext.getSharedPreferences("LocationData", Context.MODE_PRIVATE)
        val locationsJsonString = sharedPref.getString("location_list", "[]")
        val jsonArray = JSONArray(locationsJsonString)

        if (jsonArray.length() == 0) {
            Log.d("UploadWorker", "No locations to upload")
            return Result.success()
        }

        val locationsToUpload = mutableListOf<Map<String, Any>>()
        for (i in 0 until jsonArray.length()) {
            val obj = jsonArray.getJSONObject(i)
            val map = mapOf(
                "latitude" to obj.getDouble("latitude"),
                "longitude" to obj.getDouble("longitude"),
                "deviceId" to obj.getString("deviceId"),
                "timestamp" to obj.getLong("timestamp")
            )
            locationsToUpload.add(map)
        }
        Log.d("UploadWorker", "Uploading ${locationsToUpload.size} locations")

        val uploadSuccess = uploadLocationsBatch(locationsToUpload)

        return if (uploadSuccess) {
            sharedPref.edit().putString("location_list", "[]").apply()
            Result.success()
        } else {
            Result.retry()
        }
    }

    private fun uploadLocationsBatch(locations: List<Map<String, Any>>): Boolean {
        return try {
            val database = FirebaseDatabase.getInstance().reference.child("locations_batch")
            val batchId = System.currentTimeMillis().toString()
            database.child(batchId).setValue(locations)
            true
        } catch (e: Exception) {
            Log.e("UploadWorker", "Upload failed: ${e.message}")
            false
        }
    }
}
