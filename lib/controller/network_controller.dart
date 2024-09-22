import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  Connectivity connectivity = Connectivity();
  bool chk = false;
  RxString connectionStatus = ''.obs;

  @override
  void onInit() {
    connectivity.onConnectivityChanged.listen(updateConnectionStatus);
    super.onInit();
  }

  void updateConnectionStatus(List<ConnectivityResult> connectivityResultList) {
    // if (connectivityResultList.contains(ConnectivityResult.mobile)) {
    //   chk = true;
    //   connectionStatus.value = "Connected with Mobile Data";
    //   AppConstants.log.i(connectionStatus.value);
    // }

    // if (connectivityResultList.contains(ConnectivityResult.wifi)) {
    //   chk = true;
    //   connectionStatus.value = "Connected with Wifi";
    //   AppConstants.log.i(connectionStatus.value);
    // }
    // if (connectivityResultList.contains(ConnectivityResult.vpn)) {
    //   chk = true;
    //   connectionStatus.value = "Connected with VPN";
    //   AppConstants.log.i(connectionStatus.value);
    // }
    // if (connectivityResultList.contains(ConnectivityResult.ethernet)) {
    //   chk = true;
    //   connectionStatus.value = "Connected with Ethernet";
    //   AppConstants.log.i(connectionStatus.value);
    // }
    // if (connectivityResultList.contains(ConnectivityResult.bluetooth)) {
    //   chk = true;
    //   connectionStatus.value = "Connected with Bluetooth";
    //   AppConstants.log.i(connectionStatus.value);
    // }
    if (connectivityResultList.contains(ConnectivityResult.none)) {
      chk = false;
      connectionStatus.value = "No Internet Available";
      AppConstants.log.i(connectionStatus.value);
    }
    if (connectivityResultList.contains(ConnectivityResult.other)) {
      chk = false;
      connectionStatus.value = "Something went wrong";
      AppConstants.log.i(connectionStatus.value);
    }
    if (chk) {
      Get.snackbar(
        "Network Status",
        connectionStatus.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
        isDismissible: false,
      );
    }
  }
}
