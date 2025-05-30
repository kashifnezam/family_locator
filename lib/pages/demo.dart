import 'package:family_room/utils/constants.dart';
import 'package:flutter/services.dart';

class NativeChannel {
  // static const MethodChannel _channel =
  //     MethodChannel('com.kashif.family_room/native_channel');
  static const MethodChannel _channel =
      MethodChannel('com.kashif.family_room/native_channel');

  // Method to invoke native code
  static Future<String?> getNativeData() async {
    try {
      // Calls a method on the native side (Java)
      final String? result = await _channel.invokeMethod('getNativeData');
      return result;
    } on PlatformException catch (e) {
      AppConstants.log.e("Failed to get native data: '${e.message}'.");
      return null;
    }
  }
}
