import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  Connectivity connectivity = Connectivity();

  @override
  void onInit() {
    connectivity.onConnectivityChanged.listen(updateConnectionStatus);
    super.onInit();
  }

  void dismissSnackbar() {
    if (Get.isSnackbarOpen) {
      Get.back(); // Dismiss the snackbar if it is open
    }
  }

  showSnackbar() {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        "Low internet",
        "Check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        icon: const Icon(Icons.wifi_off, color: Colors.red),
        shouldIconPulse: true,
        isDismissible: false,
        duration:
            const Duration(days: 365), // Keeps the snackbar open indefinitely
        margin: const EdgeInsets.all(16.0),
        borderRadius: 12.0,
        animationDuration: const Duration(milliseconds: 500),
        boxShadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8.0,
            offset: Offset(0, 4),
          ),
        ],
        // mainButton: TextButton(
        //   onPressed: () {
        //     // Optionally open network settings or retry logic here
        //     Get.back(); // Dismiss the snackbar
        //   },
        //   child: const Text(
        //     "Retry",
        //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //   ),
        // ),
      );
    }
  }

  void updateConnectionStatus(List<ConnectivityResult> connectivityResultList) {
    if (connectivityResultList.contains(ConnectivityResult.none)) {
      showSnackbar();
    } else if (connectivityResultList.contains(ConnectivityResult.other)) {
    } else {
      dismissSnackbar();
    }
  }
}
