import 'package:family_locator/controller/family_room_controller.dart';
import 'package:family_locator/widgets/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../utils/device_info.dart';
import '../widgets/button_widget.dart';
import 'chat_room.dart';

class FamilyRoom extends StatelessWidget {
  const FamilyRoom({super.key});

  @override
  Widget build(BuildContext context) {
    final FamilyRoomController controller = Get.put(FamilyRoomController());

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey,
        title: GestureDetector(
          onTap: () => CustomWidget.roomWidget(),
          child: ButtonWidget.elevatedBtn(
            "Create/Join Group",
            height: AppConstants.height * 0.05,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Icon(Icons.search),
          ),
        ],
      ),
      body: Obx(
        () {
          // Destructure the controller's room list for better readability
          final roomList = controller.roomList;

          return ListView.builder(
            itemCount: roomList.length,
            itemBuilder: (context, index) {
              final room = roomList[index];
              final String roomName = room["name"];
              final String roomSrtName =
                  roomName.length >= 2 ? roomName.substring(0, 2) : roomName;

              return ListTile(
                onTap: () => _navigateToChatRoom(room),
                leading: _buildRoomAvatar(room, roomSrtName),
                title: _buildRoomTitle(room),
                subtitle: _buildRoomSubtitle(),
                trailing: const Text("12:33"), // Placeholder for message time
              );
            },
          );
        },
      ),
    );
  }

  // Method to navigate to the ChatRoom
  void _navigateToChatRoom(Map<String, dynamic> room) {
    Get.to(
      () => ChatRoom(
        roomId: room["roomNo"],
        userId: DeviceInfo.deviceId.toString(),
        roomName: room["name"],
        owner: room["owner"],
      ),
    );
  }

  // Method to build the Room Avatar
  Widget _buildRoomAvatar(Map<String, dynamic> room, String roomSrtName) {
    return CircleAvatar(
      radius: AppConstants.width * 0.05,
      backgroundImage: room["dp"].isNotEmpty ? NetworkImage(room["dp"]) : null,
      child: room["dp"].isEmpty ? Text(roomSrtName.toUpperCase()) : null,
    );
  }

  // Method to build the Room Title
  Widget _buildRoomTitle(Map<String, dynamic> room) {
    return Row(
      children: [
        Text(room["name"], style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 10),
        Text(room["roomNo"],
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // Method to build the Room Subtitle
  Widget _buildRoomSubtitle() {
    return const Text("My last message",
        style: TextStyle(fontSize: 12, color: Colors.grey));
  }
}
