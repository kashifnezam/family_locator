import 'package:family_locator/controller/family_room_controller.dart';
import 'package:family_locator/widgets/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../utils/device_info.dart';
import '../widgets/button_widget.dart';
import 'chat_room.dart';

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
            onTap: () => CustomWidget.roomWidget(),
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
                String roomName = room[index]["name"];
                String roomSrtName =
                    roomName.length >= 2 ? roomName.substring(0, 2) : roomName;
                return ListTile(
                  onTap: () {
                    Get.to(
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
                    backgroundImage: room[index]["dp"] != ""
                        ? NetworkImage(
                            room[index]["dp"],
                          )
                        : null,
                    child: Text(roomSrtName.toUpperCase()),
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
