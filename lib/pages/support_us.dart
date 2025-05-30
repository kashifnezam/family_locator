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
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: Icon(Icons.check_circle, color: Colors.white));
  }

  // Method to get UPI payment link for QR code
  String getUpiPaymentLink() {
    return 'upi://pay?pa=${upiId.value}&pn=YourAppName&cu=INR';
  }

  // Method to launch UPI app directly (you may add UPI payment intent here)
  void initiateUpiPayment() {
    // Example: Launch UPI intent using external package if integrated
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              // Donation Message
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Your Support Matters",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Help us continue our work by donating via UPI. "
                        "Every contribution makes a difference!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // QR Code for Payment
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Scan to Donate",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      QrImageView(
                        data: controller.getUpiPaymentLink(),
                        version: QrVersions.auto,
                        size: 200.0,
                        gapless: false,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Scan with any UPI app to donate",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 10),
                      Text(
                        'UPI ID',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Obx(() => SelectableText(
                            controller.upiId.value,
                            style: TextStyle(
                                fontSize: 16, color: Colors.blueAccent),
                          )),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: controller.copyUpiId,
                        icon: Icon(Icons.copy),
                        label: Text('Copy UPI ID'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Security Message
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, color: Colors.green),
                  SizedBox(width: 5),
                  Text(
                    "Your donation is secure",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
