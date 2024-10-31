import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../utils/constants.dart';
import '../utils/device_info.dart';

class FirebaseTprApi {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final List<Map<String, dynamic>> _locationBuffer = [];
  static bool _hasCleanedUp = false;

  // Method to batch upload location updates as an array in a single document
  static Future<void> uploadBatchLocations() async {
    AppConstants.log.e("tpr check");
    AppConstants.log.e(_locationBuffer);
    if (_locationBuffer.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    final userId = DeviceInfo.deviceId;
    final userDocRef =
        FirebaseFirestore.instance.collection('History_TPR').doc(userId);

    try {
      for (var locationData in _locationBuffer) {
        final timestampedLocation = {
          "location": locationData,
          "timestamp":
              FieldValue.serverTimestamp(), // Add server timestamp as a field
        };

        final locationRef = userDocRef.collection("locations").doc();
        batch.set(locationRef, timestampedLocation);
      }

      await batch.commit();
      _locationBuffer.clear();
      if (!_hasCleanedUp) {
        _cleanupOldRecords(userId!); // Clean up only on first initialization
        _hasCleanedUp = true;
      }
    } catch (e) {
      AppConstants.log.e("Error uploading location batch: $e");
    }
  }

// Method to remove location records older than 3 days within a document
  static Future<void> _cleanupOldRecords(String userId) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: 3));

    try {
      final docRef = _firestore.collection('History_TPR').doc(userId);

      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final List<dynamic> locations = snapshot['locations'] ?? [];

        // Filter locations to exclude those older than the cutoff date
        final updatedLocations = locations
            .where((location) => (location['timestamp'] as Timestamp)
                .toDate()
                .isAfter(cutoffDate))
            .toList();

        // Update the document with the filtered list
        await docRef.update({'locations': updatedLocations});
      }
    } catch (e) {
      AppConstants.log.e("Error cleaning up old records: $e");
    }
  }

// Method to retrieve location updates for a specific user

static Future<List<Map<String, dynamic>>> getLocationHistory(
    String userId, {List<DateTime>? dateRange}) async {
  try {
    // Determine start and end dates based on the dateRange parameter
    DateTime startDate;
    DateTime endDate;

    if (dateRange != null && dateRange.length == 2) {
      // Use the provided DateTime objects as start and end dates
      startDate = dateRange[0];
      endDate = dateRange[1];
    } else {
      // Default to today's date range if dateRange is not provided
      final now = DateTime.now();
      startDate = DateTime(now.year, now.month, now.day);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    }

    // Reference to the user's locations subcollection
    final locationsCollection = FirebaseFirestore.instance
        .collection('History_TPR')
        .doc(userId)
        .collection('locations');

    // Retrieve documents within the specified date range, ordered by timestamp
    final snapshot = await locationsCollection
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('timestamp', descending: true)
        .get();

    // Convert each document snapshot into a map with its data
    final locationHistory = snapshot.docs.map((doc) {
      return {
        'location': doc['location'],
        'timestamp': (doc['timestamp'] as Timestamp).toDate(),
      };
    }).toList();

    return locationHistory;
  } catch (e) {
    AppConstants.log.e("Error fetching location history: $e");
    return [];
  }
}

/// Buffer location updates and batch upload every 5 minutes
  static void bufferLocationUpdate(LatLng location) {
    final locationData = {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'deviceId': DeviceInfo.deviceId,
    };
    _locationBuffer.add(locationData);
  }
}
