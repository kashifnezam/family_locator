// services/device_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/device_info.dart';

class DeviceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateDeviceInfo(String userId) async {
    await _firestore.collection('user').doc(userId).update({
      'deviceId': DeviceInfo.deviceId ?? '',
      'macAd': DeviceInfo.macAddress ?? '',
      'ipAddress': DeviceInfo.ipAddress ?? '',
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }
}