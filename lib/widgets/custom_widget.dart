import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomWidget {
  static Widget buildCircularProgressIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  static Future<bool> confirmDialogue(
      {required String title,
      required String content,
      String cancel = "Cancel",
      String confirm = "Confirm",
      bool isCancel = true}) async {
    return await Get.dialog(
          AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              if (isCancel)
                TextButton(
                  child: Text(cancel),
                  onPressed: () {
                    Get.back(result: false); // Close the dialog, return false
                  },
                ),
              TextButton(
                child: Text(confirm),
                onPressed: () {
                  Get.back(result: true); // Close the dialog, return true
                },
              ),
            ],
          ),
        ) ??
        false; // Return false if the dialog is dismissed without a choice.
  }
}
