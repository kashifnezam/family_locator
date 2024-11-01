// constants.dart
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';


class AppConstants {
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

  static final cacheStore =  MemCacheStore();
}
