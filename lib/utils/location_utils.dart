import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:family_locator/api/firebase_tpr_api.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:network_info_plus/network_info_plus.dart';

class LocationUtils {
  static LatLng? _previousLocation;
  static double distanceThreshold = 15.0; // Meters
  // ignore: constant_identifier_names
  static const int BATCH_UPLOAD_INTERVAL = 300; // 5 minutes
  static Timer? _batchUploadTimer;

  /// Call this method when done to stop the batch timer
  static void dispose() {
    _batchUploadTimer?.cancel();
  }

  static void initializeBatchUpload() {
    _batchUploadTimer = Timer.periodic(
      Duration(seconds: BATCH_UPLOAD_INTERVAL),
      (Timer timer) => FirebaseTprApi.uploadBatchLocations(),
    );
  }


  static void getCurrentLocation({
    required Function(LatLng) onLocationLoaded,
    Function(String)? onError,
    Function() ?onStartMoving,
  }) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
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
          onError!("Location services are disabled.");
        },
      );
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        onError!("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      onError!("Location permissions are permanently denied.");
      return;
    }

    // Start listening for location updates
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    ).listen((Position position) {
      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      // Check if the user has started moving
      if (_previousLocation != null &&
          Geolocator.distanceBetween(
                _previousLocation!.latitude,
                _previousLocation!.longitude,
                currentLocation.latitude,
                currentLocation.longitude,
              ) >=
              distanceThreshold) {
        onStartMoving?.call();
       FirebaseTprApi.bufferLocationUpdate(currentLocation);
      }

      _previousLocation = currentLocation;
      onLocationLoaded(currentLocation);
    }, onError: (e) {
      onError!("Error getting live location: $e");
    });
  }

  static Future<String?> getLocalIPAddress() async {
    try {
      final info = NetworkInfo();
      // Get the local IP address
      String? ipAddress = await info.getWifiIP();
      return ipAddress; // Return the local IP address
    } catch (e) {
      AppConstants.log.e('Error fetching local IP address: $e');
      return null;
    }
  }

  static Future<String?> getMacAddress() async {
    try {
      final info = NetworkInfo();
      // Get the MAC address of the Wi-Fi
      String? macAddress = await info.getWifiBSSID();
      return macAddress; // Return the MAC address
    } catch (e) {
      AppConstants.log.e('Error fetching MAC address: $e');
      return null;
    }
  }

  static Future<String?> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? deviceId;

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // Unique ID for Android devices
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor; // Unique ID for iOS devices
      }
    } catch (e) {
      AppConstants.log.e('Error fetching device ID: $e');
      return null;
    }

    return deviceId;
  }

  static LatLng? parseLocation(String currLoc) {
    // Example: "LatLng(latitude:28.617113, longitude:77.373625)"
    final regex =
        RegExp(r'LatLng\(latitude:(-?\d+\.\d+), longitude:(-?\d+\.\d+)\)');
    final match = regex.firstMatch(currLoc);
    if (match != null) {
      final latitude = double.parse(match.group(1)!);
      final longitude = double.parse(match.group(2)!);
      return LatLng(latitude, longitude);
    }
    return null; // Return null if parsing fails
  }
}
