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
      await firestore.collection("user").doc(userId).get();
      if (userSnapshot.exists) {
        // Convert Firestore data to a JSON-serializable map
        _cachedUserData = _convertFirestoreToJson(userSnapshot.data() as Map<String, dynamic>);

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

  /// Helper function to convert Firestore-specific types to JSON-serializable types
  Map<String, dynamic> _convertFirestoreToJson(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) {
        // Convert Timestamp to ISO string or milliseconds since epoch
        return MapEntry(key, value.toDate().toIso8601String());
      } else if (value is GeoPoint) {
        // Convert GeoPoint to {lat: x, lng: y}
        return MapEntry(key, {'lat': value.latitude, 'lng': value.longitude});
      } else if (value is DocumentReference) {
        // Convert DocumentReference to path string
        return MapEntry(key, value.path);
      } else if (value is Map<String, dynamic>) {
        // Recursively handle nested maps
        return MapEntry(key, _convertFirestoreToJson(value));
      } else if (value is List) {
        // Handle lists that might contain Firestore types
        return MapEntry(key, value.map((item) {
          if (item is Map<String, dynamic>) {
            return _convertFirestoreToJson(item);
          } else if (item is Timestamp) {
            return item.toDate().toIso8601String();
          }
          return item;
        }).toList());
      }
      return MapEntry(key, value);
    });
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

  Future<dynamic> getObject(String ?key) async{
    if (_prefs == null) init();
    if(key != null){
      return await _prefs?.getString(key);
    }
  }

  Future<void> storeObject(String key, String? value) async {
      if (_prefs == null) init();
      if (value != null) {
        await _prefs?.setString(key, value);
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
