import 'package:family_locator/controller/family_room_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/constants.dart';
import '../utils/device_info.dart';
import '../utils/offline_data.dart';
import '../widgets/button_widget.dart';
import '../widgets/username_dialogue.dart';
import 'chat_room.dart';
import 'room_dialogue.dart';

class FamilyRoom extends StatefulWidget {
  const FamilyRoom({super.key});

  @override
  State<FamilyRoom> createState() => _FamilyRoomState();
}

class _FamilyRoomState extends State<FamilyRoom> {
  FamilyRoomController controller = Get.put(FamilyRoomController());

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
                  if (DateTime.now()
                      .isAfter(date.add(const Duration(days: 7)))) {
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
        body: Obx(
          () {
            return ListView.builder(
              itemCount: controller.roomList.length,
              itemBuilder: (context, index) {
                List room = controller.roomList;
                return ListTile(
                  onTap: () {
                    Get.off(
                      () => ChatRoom(
                        roomId: room[index]["roomNo"],
                        userId: DeviceInfo.deviceId.toString(),
                        roomName: room[index]["name"],
                        owner: room[index]["owner"],
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    radius: AppConstants.width * 0.05,
                    backgroundImage: NetworkImage(
                      room[index]["dp"],
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        room[index]["name"],
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        room[index]["roomNo"],
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    "My last message",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: Text("12:33"),
                );
              },
            );
          },
        ));
  }
}
