import 'package:family_room/controller/family_room_controller.dart';
import 'package:family_room/widgets/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
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
            "Create/Join Rooms",
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

          return !controller.isLoading.value
              ? roomList.isNotEmpty
                  ? ListView.builder(
                      itemCount: roomList.length,
                      itemBuilder: (context, index) {
                        final room = roomList[index];
                        final String roomName = room["name"];
                        final String roomSrtName = roomName.length >= 2
                            ? roomName.substring(0, 2)
                            : roomName;

                        return ListTile(
                          onTap: () => _navigateToChatRoom(room),
                          leading: _buildRoomAvatar(room, roomSrtName),
                          title: _buildRoomTitle(room),
                          subtitle: _buildRoomSubtitle(room["msg"]),
                          trailing: const Text(
                              "12:33"), // Placeholder for message time
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("No Rooms avialable"),
                          Text(
                            "Please either Join or Create Rooms",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
              : ShimmerList();
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
      child: room["dp"].isEmpty
          ? Text(roomSrtName.toUpperCase())
          : CustomWidget.getImage(room["dp"]),
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
  Widget _buildRoomSubtitle(String msg) {
    return Text(msg, style: TextStyle(fontSize: 12, color: Colors.grey));
  }
}

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10, // Adjust the count based on your needs
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              radius: AppConstants.width * 0.05,
            ),
            title: Container(
              height: 30,
              width: 200,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
