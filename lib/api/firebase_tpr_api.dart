import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../utils/constants.dart';
import '../utils/device_info.dart';

class FirebaseTprApi {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final List<Map<String, dynamic>> _locationBuffer = [];
  static bool _hasCleanedUp = false;

  /// Method to batch upload location updates
  static Future<void> uploadBatchLocations() async {
    if (_locationBuffer.isEmpty) return;

    final userId = DeviceInfo.deviceId;
    if (userId == null) return;

    final userDocRef = _firestore.collection('History_TPR').doc(userId);
    final batch = _firestore.batch();

    try {
      for (var locationData in _locationBuffer) {
        final locationRef = userDocRef.collection("locations").doc();
        batch.set(locationRef, {
          "location": locationData,
          "timestamp": FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      _locationBuffer.clear();

      if (!_hasCleanedUp) {
        await _cleanupOldRecords(userId);
        _hasCleanedUp = true;
      }
    } catch (e) {
      AppConstants.log.e("Error uploading location batch: $e");
    }
  }

  /// Method to remove records older than 3 days
  static Future<void> _cleanupOldRecords(String userId) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: 3));

    try {
      final locations = await _firestore
          .collection('History_TPR')
          .doc(userId)
          .collection("locations")
          .where("timestamp", isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (var doc in locations.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      AppConstants.log.e("Error cleaning up old records: $e");
    }
  }

  /// Method to retrieve location history within an optional date range
  static Future<List<Map<String, dynamic>>> getLocationHistory(
      String userId, {List<DateTime>? dateRange}) async {
    try {
      DateTime startDate, endDate;
      if (dateRange != null && dateRange.length == 2) {
        startDate = dateRange[0];
        endDate = dateRange[1];
      } else {
        final now = DateTime.now();
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      }

      final snapshot = await _firestore
          .collection('History_TPR')
          .doc(userId)
          .collection('locations')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'location': doc['location'],
          'timestamp': (doc['timestamp'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      AppConstants.log.e("Error fetching location history: $e");
      return [];
    }
  }

  /// Buffer location updates to batch upload every 5 minutes
  static void bufferLocationUpdate(LatLng location) {
    _locationBuffer.add({
      'latitude': location.latitude,
      'longitude': location.longitude,
      'deviceId': DeviceInfo.deviceId,
    });
  }
}
