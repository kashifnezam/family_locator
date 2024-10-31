import 'package:family_locator/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; // For clipboard functionality
import 'package:qr_flutter/qr_flutter.dart'; // For QR code generation

class SupportUsController extends GetxController {
  // Observable for UPI ID
  var upiId = 'kashifnezam123@oksbi'.obs; // Replace with your actual UPI ID

  // Method to copy UPI ID to clipboard
  void copyUpiId() {
    Clipboard.setData(ClipboardData(text: upiId.value));
    Get.snackbar("Copied", "UPI ID copied to clipboard",
        snackPosition: SnackPosition.BOTTOM);
  }

  // Method to get UPI payment link for QR code
  String getUpiPaymentLink() {
    return 'upi://pay?pa=${upiId.value}';
  }
}

class SupportUs extends StatelessWidget {
  final SupportUsController controller = Get.put(SupportUsController());

  SupportUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Us'),
      ),
      body: Padding(
        padding: EdgeInsets.only(
            top: AppConstants.height * 0.1, left: AppConstants.width * 0.03),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'UPI ID',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Obx(() => Text(
                      controller.upiId.value,
                      style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                    )),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    controller.copyUpiId();
                  },
                  child: Text('Copy UPI ID'),
                ),
                SizedBox(height: 20),
                QrImageView(
                  data: controller.getUpiPaymentLink(),
                  version: QrVersions.auto,
                  size: 200.0,
                  gapless: false,
                ),
                SizedBox(height: 10),
                Text("Scan to pay with any UPI app",
                    style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
