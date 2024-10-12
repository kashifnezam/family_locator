import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/constants.dart';
import '../utils/offline_data.dart';
import '../widgets/button_widget.dart';
import '../widgets/username_dialogue.dart';
import 'room_dialogue.dart';

class FamilyRoom extends StatefulWidget {
  const FamilyRoom({super.key});

  @override
  State<FamilyRoom> createState() => _FamilyRoomState();
}

class _FamilyRoomState extends State<FamilyRoom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color of the back arrow
        ),
        backgroundColor: Colors.blueGrey,
        title: GestureDetector(
          onTap: () async {
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
            usr != null
                ? Get.dialog(RoomDialog())
                : Get.dialog(UsernameDialog());
          },
          child: ButtonWidget.elevatedBtn("Create/Join Group",
              height: AppConstants.height * 0.05),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.search,
            ),
          )
        ],
      ),
    );
  }
}
