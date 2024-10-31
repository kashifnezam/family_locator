import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../pages/room_dialogue.dart';
import '../utils/offline_data.dart';
import 'username_dialogue.dart';

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

  static Future<void> roomWidget() async {
    String? usr = await OfflineData.getData("usr");
    if (usr != null) {
      String? dateString = await OfflineData.getData("date");
      if (dateString != null) {
        DateTime date = DateTime.parse(dateString);
        if (DateTime.now().isAfter(date.add(const Duration(days: 7)))) {
          usr = null;
        }
      }
    }
    usr != null ? Get.dialog(RoomDialog()) : Get.dialog(UsernameDialog());
  }

  static Future<String> imagePickFrom({String source = "gallary"}) async {
    try {
      XFile? file;

      ImagePicker imagePicker = ImagePicker();
      if (source == "camera") {
        file = await imagePicker.pickImage(source: ImageSource.camera);
      } else if (source == "gallary") {
        file = await imagePicker.pickImage(source: ImageSource.gallery);
      }

      // if (filename == "NA") {
      //   filename = file != null ? file.name : "";
      // }
      if (file != null) {
        return file.path;
      }
      return "";
    } catch (e) {
      confirmDialogue(
          title: "Something went wrong",
          content: "Error while choosing file $e");
      return "";
    }
  }

  static CachedNetworkImage getImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
            // colorFilter:
            //     ColorFilter.mode(Colors.red, BlendMode.colorBurn),
          ),
        ),
      ),
      placeholder: (context, url) => buildCircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
