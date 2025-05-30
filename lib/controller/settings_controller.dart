import 'package:family_room/utils/constants.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  // Observable variable to track location setting
  var isLocationTrackingEnabled = true.obs;

  // Method to toggle location tracking
  void toggleLocationTracking(bool value) {
    isLocationTrackingEnabled.value = value;
    // Here you can add logic to start/stop location tracking if needed
    if (value) {
      // Start tracking location
      AppConstants.log.i("Location tracking enabled");
    } else {
      // Stop tracking location
      AppConstants.log.i("Location tracking disabled");
    }
  }
}
