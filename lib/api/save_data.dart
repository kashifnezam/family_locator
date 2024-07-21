import '../models/anonymous_model.dart';
import '../utils/constants.dart';
import 'firebase_api.dart';

class SaveDataApi {
  static Future<void> saveAnonymousData(String? deviceId, int groupId, String? macAddress, String? ipAddress, String currentLocation) async {
     // Check if device ID is not null before proceeding
      if (deviceId != null) {
        // Add data to Firebase if device ID is valid
        await FirebaseApi.addDataIfNotExists(
          "anonymous",
          deviceId,
          AnonymousModel(
            currLoc: currentLocation.toString(),
            groupId: ['groupId'],
            id: deviceId,
            macAd: macAddress ?? '',
            ipAddress: ipAddress ?? '', // Handle potential null
            name: "munna",
          ),
        );
        AppConstants.log.i('Device Id: $deviceId');
      } else {
        AppConstants.log.e('Device ID is null, data not added to Firebase.');
      }
  }
}