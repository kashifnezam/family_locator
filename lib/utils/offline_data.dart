import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_room/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Map<String, dynamic>? userInfo;

class OfflineData {
  // Singleton instance
  static final OfflineData _instance = OfflineData._internal();
  factory OfflineData() => _instance;
  OfflineData._internal();

  // SharedPreferences instance
  SharedPreferences? _prefs;

  // Cached user data
  Map<String, dynamic>? _cachedUserData;

  // Initialize SharedPreferences once
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Fetch and update user details manually, called after any profile update
  Future<void> refreshUserData(String? userId) async {
    if (userId == null) return;
    if (_prefs == null) {
      await init();
    }
    final firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot userSnapshot =
          await firestore.collection("anonymous").doc(userId).get();
      if (userSnapshot.exists) {
        // Update both cache and SharedPreferences
        _cachedUserData = userSnapshot.data() as Map<String, dynamic>?;
        if (_cachedUserData != null) {
          String userJson = jsonEncode(_cachedUserData);
          _prefs!.setString("user_details", userJson);
        }
      } else {
        AppConstants.log.e("User not found in Firestore.");
      }
      userInfo = _cachedUserData;
    } catch (e) {
      AppConstants.log.e("Error refreshing user data: $e");
    }
  }

  // Get user details with caching to avoid redundant SharedPreferences calls
  Future<Map<String, dynamic>?> getUserDetails() async {
    // Return from cache if data is already loaded
    if (_cachedUserData != null) {
      return _cachedUserData;
    }
    // Load from SharedPreferences only once and cache it
    if (_prefs == null) {
      await init();
    }
    String? userJson = _prefs!.getString("user_details");
    if (userJson != null) {
      _cachedUserData = jsonDecode(userJson);
    }
    userInfo = _cachedUserData;
    return _cachedUserData;
  }

  Future<void> storeObject(String key, String? value) async {
      if (_prefs == null) init();
      if (value != null) {
        await _prefs?.setString(key, value);
    }
     AppConstants.log.e( _prefs?.get("deviceId"));
  }
}
