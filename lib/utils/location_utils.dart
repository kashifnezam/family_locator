import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';

class LocationUtils {
  static void getCurrentLocation({
    required Function(LatLng) onLocationLoaded,
    required Function(String) onError,
  }) async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.defaultDialog(
        title: 'Location Services Disabled',
        middleText:
            'Location services are disabled. Would you like to enable them?',
        textConfirm: 'Yes',
        onConfirm: () async {
          await Geolocator.openLocationSettings();
          Get.back();
        },
        textCancel: 'No',
        onCancel: () {
          onError("Location services are disabled.");
        },
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        onError("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      onError("Location permissions are permanently denied.");
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      onLocationLoaded(LatLng(position.latitude, position.longitude));
    } catch (e) {
      onError("Error getting location: $e");
    }
  }
}
