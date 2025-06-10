import android.content.Context
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import java.util.concurrent.CountDownLatch

class UploadWorker(appContext: Context, workerParams: WorkerParameters) : Worker(appContext, workerParams) {

    override fun doWork(): Result {
        Log.d("UploadWorker", "Worker is running...")

        val sharedPref = applicationContext.getSharedPreferences("LocationData", Context.MODE_PRIVATE)
        val flutterPrefs = applicationContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val uid = flutterPrefs.getString("flutter.uid", "") ?: ""

        if (uid.isEmpty()) {
            Log.e("UploadWorker", "Device ID not found")
            return Result.failure()
        }

        val encodedPolyline = sharedPref.getString("encoded_polyline", "") ?: ""

        if (encodedPolyline.isEmpty()) {
            Log.d("UploadWorker", "No encoded polyline to upload")
            return Result.success()
        }

        val firestore = FirebaseFirestore.getInstance()
        val userDocRef = firestore.collection("History_TPR").document(uid)
        val batch = firestore.batch()

        val locRef = userDocRef.collection("locations").document()
        val data = mapOf(
            "encodedPolyline" to encodedPolyline,
            "timestamp" to FieldValue.serverTimestamp()
        )
        batch.set(locRef, data)

        var result: Result = Result.retry()
        val latch = CountDownLatch(1)

        batch.commit()
            .addOnSuccessListener {
                Log.d("UploadWorker", "Encoded polyline uploaded successfully")
                sharedPref.edit().putString("encoded_polyline", "").apply()
                result = Result.success()
                latch.countDown()
            }
            .addOnFailureListener { e ->
                Log.e("UploadWorker", "Upload failed: ${e.message}")
                result = Result.retry()
                latch.countDown()
            }

        latch.await()
        return result
    }
}
