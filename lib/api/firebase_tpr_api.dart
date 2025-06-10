import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_room/utils/offline_data.dart';
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
    OfflineData offlineData = OfflineData();
    final userId = await offlineData.getObject("uid");
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

       } catch (e) {
      AppConstants.log.e("Error uploading location batch: $e");
    }
  }

  /// Method to remove records older than 3 days
  static Future<void> cleanupOldRecords(String userId) async {
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
        final encodedPolyline = doc['encodedPolyline'] as String;
        final decodedLocations = decodePolyline(encodedPolyline); // Your polyline decoder function from previous message

        return {
          'locations': decodedLocations, // List<List<double>> of lat/lng points
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

List<List<double>> decodePolyline(String encoded) {
  List<List<double>> points = [];
  int index = 0;
  int lat = 0;
  int lng = 0;

  while (index < encoded.length) {
    int shift = 0;
    int result = 0;
    int b;

    // Decode latitude
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
    lat += dlat;

    // Decode longitude
    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
    lng += dlng;

    points.add([lat / 1e5, lng / 1e5]);
  }

  return points;
}
