import 'dart:math';

import 'package:family_locator/api/firebase_tpr_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class HistoryTPRController extends GetxController {
  // Dummy LatLng data for the polyline
  RxList<LatLng> polylinePoints = <LatLng>[].obs;
  final mapController = MapController();
  RxList<Map<String, dynamic>> arrowMarkers = <Map<String, dynamic>>[].obs;
  final String userId;
  RxBool isLoading = true.obs;
  RxBool isCal = false.obs;
  HistoryTPRController({required this.userId});
  RxString selectedDate = ''.obs; // Observable for selected date


  bool isDateEnabled(DateTime date) {
    // Enable only today, yesterday, and the day before yesterday
    DateTime today = DateTime.now();
    return date.isAfter(today.subtract(Duration(days: 3))) &&
        date.isBefore(today.add(Duration(days: 1)));
  }

  List<String> getAvailableDates() {
    // Return formatted strings for today, yesterday, and day before yesterday
    DateTime today = DateTime.now();
    return [
      DateFormat('yyyy-MM-dd').format(today),
      DateFormat('yyyy-MM-dd').format(today.subtract(Duration(days: 1))),
      DateFormat('yyyy-MM-dd').format(today.subtract(Duration(days: 2))),
    ];
  }

  @override
  void onInit() {
    super.onInit();
    getTPR();
  }

  getTPR({int offset = 0}) async {
    final locationHistoryData =
        await FirebaseTprApi.getLocationHistory(userId, offset);

    // Map each location entry to a LatLng object
    polylinePoints.value = locationHistoryData.map((location) {
      final locationData = location['location'];
      return LatLng(locationData['latitude'], locationData['longitude']);
    }).toList();

    fitMapToBounds();
    calculateArrowMarkers();
    isLoading.value = false;
  }

  // Add arrows at intervals (e.g., every 3rd point) along the polyline
  void calculateArrowMarkers() {
    arrowMarkers.clear();
    for (int i = 0; i < polylinePoints.length - 1; i += 2) {
      final point1 = polylinePoints[i];
      final point2 = polylinePoints[i + 1];

      final angle = _calculateBearing(point1, point2);
      arrowMarkers.add({
        'position': point1,
        'angle': angle,
      });
    }
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final lat1 = start.latitudeInRad;
    final lon1 = start.longitudeInRad;
    final lat2 = end.latitudeInRad;
    final lon2 = end.longitudeInRad;

    final dLon = lon2 - lon1;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    return atan2(y, x);
  }

  fitMapToBounds() {
    if (polylinePoints.isNotEmpty && polylinePoints.length > 1) {
      final bounds = LatLngBounds.fromPoints(polylinePoints);
      mapController.fitCamera(CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
      ));
    }
  }
}
