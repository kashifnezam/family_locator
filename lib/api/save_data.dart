import '../models/anonymous_model.dart';
import '../utils/constants.dart';
import 'firebase_api.dart';

class SaveDataApi {
  static Future<void> saveAnonymousData(
      String? deviceId, String? macAddress, String? ipAddress) async {
    // Check if device ID is not null before proceeding
    if (deviceId != null) {
      // Add data to Firebase if device ID is valid
      await FirebaseApi.addAnonymousData(
        "anonymous",
        deviceId,
        AnonymousModel(
          id: deviceId,
          macAd: macAddress ?? '',
          ipAddress: ipAddress ?? '', // Handle potential null
        ),
      );
      AppConstants.log.i('Device Id: $deviceId');
    } else {
      AppConstants.log.e('Device ID is null, data not added to Firebase.');
    }
  }
}
