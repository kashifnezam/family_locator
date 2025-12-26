// constants.dart
import 'dart:ui';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';


class AppConstants {
  static const authDomain = "familykashif.auth";
  static const String appTitle = 'Family Locator';
  static Logger log = Logger();
  static double height = Get.height;
  static double width = Get.width;
}

//Map Contants
class MapConstants {
  // Map Layer/Url
  static final tileLayer = TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  // Max Movement Bounds
  static final maxBounds = LatLngBounds(
    const LatLng(
        84.27047334318138, 180.0), // Northeast corner with valid longitude
    const LatLng(-84.97624835066578,
        -170.0), // Adjusted Southwest corner with increased longitude
  );

  // India Bounds
  static final indiaBounds = LatLngBounds(
    const LatLng(6.4626999, 68.1097), // Southwest corner of India
    const LatLng(35.6745457, 97.395561), // Northeast corner of India
  );

  static final cacheStore = MemCacheStore(
    // Maximum size of a single cached tile (in bytes)
    maxEntrySize: 5 * 1024 * 1024, // 5MB per tile

    // Total maximum size of the cache (in bytes)
    maxSize: 100 * 1024 * 1024, // 100MB total cache

    // Optional: How long to keep tiles in cache
  );
}

// Define your color palette
class AppColors {
  static const Color primary = Color(0xFF4361EE);  // Vibrant blue
  static const Color secondary = Color(0xFF3F37C9);  // Darker blue
  static const Color accent = Color(0xFF4CC9F0);  // Light blue
  static const Color background = Color(0xFFF8F9FA);  // Light grey
  static const Color surface = Color(0xFFFFFFFF);  // White
  static const Color error = Color(0xFFE63946);  // Red
  static const Color success = Color(0xFF2EC4B6);  // Teal
  static const Color warning = Color(0xFFFFBF69);  // Orange

  // Text colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status colors
  static const Color statusActive = Color(0xFF38B000);
  static const Color statusInactive = Color(0xFF6C757D);
  static const Color statusPending = Color(0xFFFFBF69);
}
