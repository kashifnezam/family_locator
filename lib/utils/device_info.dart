import 'package:firebase_auth/firebase_auth.dart';

import 'constants.dart';
import 'location_utils.dart';

class DeviceInfo {
  static String? macAddress;
  static String? ipAddress;
  static String? deviceId;
  static String? userUID;
  static Future<void> getDetails() async {
    try {
      // Get MAC Address
      macAddress = await LocationUtils.getMacAddress();
      AppConstants.log.i('MAC Address: $macAddress');

      // Get Local IP Address
      ipAddress = await LocationUtils.getLocalIPAddress();
      AppConstants.log.i('Local IP Address: $ipAddress');

      // Get Device ID
      deviceId = await LocationUtils.getDeviceId();
      AppConstants.log.i('Device ID: $deviceId');

      userUID = FirebaseAuth.instance.currentUser?.uid;
      AppConstants.log.i('userUID: $userUID');
    } catch (e) {
      AppConstants.log.e('Error in getDetails: $e');
    }
  }
}
