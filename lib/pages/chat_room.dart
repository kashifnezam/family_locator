import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/utils/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_map/flutter_map.dart';
import '../controller/chat_room_controller.dart';
import '../models/message_model.dart';

class ChatRoom extends StatefulWidget {
  final String roomId;
  final String userId;
  final String roomName;

  const ChatRoom(
      {super.key,
      required this.roomId,
      required this.userId,
      required this.roomName});

  @override
  ChatRoomState createState() => ChatRoomState();
}

class ChatRoomState extends State<ChatRoom> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var counter = 9;
    final ChatRoomController controller = Get.put(ChatRoomController(
        roomId: widget.roomId,
        userId: widget.userId,
        rooomName: widget.roomName));
    final TextEditingController messageController = TextEditingController();
    return WillPopScope(
      // This widget captures the back button press
      onWillPop: () async {
        bool shouldLeave = await _showExitConfirmationDialog(context);
        return shouldLeave; // Return true if the user confirms to exit, false otherwise.
      },
      child: Scaffold(
        appBar: AppBar(
          title: ListTile(
            title: Text(widget.roomName),
            subtitle: Text(widget.roomId),
          ),
          actions: [
            Stack(
              children: <Widget>[
                IconButton(
                  onPressed: controller.toggleNotification,
                  icon: const Icon(Icons.notifications),
                ),
                counter != 0
                    ? Positioned(
                        right: 11,
                        top: 11,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '$counter',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            Focus(
              onFocusChange: (focused) {
                if (focused && controller.isLargerMap.value) {
                  controller.toggleLargeMap();
                }
              },
              child: Column(
                children: [
                  Obx(() {
                    if (controller.isMapExpanded.value) {
                      double height = AppConstants.height * 0.35;
                      if (controller.isLargerMap.value) {
                        height = AppConstants.height * 0.77;
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black45, width: 4),
                            borderRadius: BorderRadius.circular(8)),
                        height: height,
                        child: FlutterMap(
                          mapController: controller.mapController,
                          options: MapOptions(
                            // cameraConstraint: CameraConstraint.contain(
                            //     bounds: MapConstants.maxBounds),
                            minZoom: 0.2,
                            backgroundColor: Colors.blue.shade100,
                            onMapReady: controller.onMapCreated,
                            initialZoom: controller.zoomLevel.value,
                            initialCameraFit: CameraFit.bounds(
                              bounds: controller.userLocationBounds ??
                                  MapConstants.indiaBounds,
                              padding: const EdgeInsets.all(30),
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            ),
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points:
                                      controller.userLocations.values.toList(),
                                  strokeWidth: 1.0,
                                  color: Colors.grey,
                                ),
                                Polyline(
                                  points: controller.routePoints,
                                  strokeWidth: 4.0,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                            MarkerClusterLayerWidget(
                              options: MarkerClusterLayerOptions(
                                maxClusterRadius: 45,
                                size: const Size(40, 40),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(50),
                                maxZoom: 15,
                                markers: [
                                  ...controller.userLocations.entries
                                      .map((entry) {
                                    final userId = entry.key;
                                    final location = entry.value;
                                    final userName =
                                        controller.userNames[userId] ??
                                            'Unknown';
                                    final firstLetter = userName.isNotEmpty
                                        ? userId == DeviceInfo.deviceId
                                            ? "You"
                                            : userName[0].toUpperCase()
                                        : '?';
                                    return Marker(
                                      point: location,
                                      width: 40,
                                      height: 40,
                                      child: GestureDetector(
                                        onTap: () =>
                                            controller.selectLocation(location),
                                        onDoubleTap: () =>
                                            controller.selectLocation(null),
                                        child: Tooltip(
                                          message: userName,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.blue),
                                              color:
                                                  userId == DeviceInfo.deviceId
                                                      ? Colors.blueGrey
                                                      : Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                firstLetter,
                                                style: TextStyle(
                                                  color: userId ==
                                                          DeviceInfo.deviceId
                                                      ? Colors.white
                                                      : Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                                builder: (context, markers) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.blueGrey),
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.blue),
                                    child: Center(
                                      child: Text(
                                        markers.length.toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value &&
                          controller.messages.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.messages.isEmpty) {
                        return const Center(child: Text('No messages yet'));
                      }

                      final groupedMessages =
                          groupMessagesByDate(controller.messages);
                      return CustomScrollView(
                        controller: controller.scrollController,
                        slivers: [
                          if (controller.isLoading.value)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                            ),
                          ...groupedMessages.entries
                              .map((entry) {
                                final date = entry.key;
                                final messagesForDate = entry.value;

                                return SliverStickyHeader(
                                  header: Container(
                                    height: 40,
                                    color: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    alignment: Alignment.center,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[500],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _formatDateHeader(date),
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final message = messagesForDate[
                                            messagesForDate.length - index - 1];
                                        final senderName = controller
                                                .userNames[message.sender] ??
                                            'Unknown';
                                        final isMe =
                                            message.sender == controller.userId;
                                        final formattedTime =
                                            DateFormat('HH:mm').format(
                                                message.timestamp.toDate());

                                        // Check if the message is a system message
                                        if (message.sender == "System") {
                                          return _buildSystemMessageBubble(
                                              context, message.text);
                                        } else {
                                          return _buildMessageBubble(
                                              context,
                                              isMe,
                                              senderName,
                                              message.text,
                                              formattedTime);
                                        }
                                      },
                                      childCount: messagesForDate.length,
                                    ),
                                  ),
                                );
                              })
                              .toList()
                              .reversed
                        ],
                      );
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (text) =>
                                controller.validateMessage(text),
                          ),
                        ),
                        Obx(
                          () => IconButton(
                            icon: const Icon(Icons.send),
                            color: controller.isMessageValid.value
                                ? Colors.blue
                                : Colors.grey,
                            onPressed: () {
                              if (controller.isMessageValid.value) {
                                controller.sendMessage(messageController.text);
                                messageController.clear();
                                controller.validateMessage('');
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: controller.toggleMapExpansion,
                child: Obx(() => Icon(
                    controller.isMapExpanded.value ? Icons.close : Icons.map)),
              ),
            ),
            Obx(() {
              if (controller.isMapExpanded.value) {
                return Positioned(
                  top: 16,
                  left: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      if (!controller.isLargerMap.value) {
                        FocusScope.of(context).unfocus();
                      }
                      controller.toggleLargeMap();
                    },
                    child: const Icon(Icons
                        .aspect_ratio_sharp), // No need for Obx here since the icon is constant.
                  ),
                );
              } else {
                return const SizedBox
                    .shrink(); // To ensure the Positioned widget is not shown when the condition is false.
              }
            }),
            Positioned(
              bottom: 75,
              right: 16,
              child: Obx(() {
                return controller.isAtBottom.value
                    ? const SizedBox
                        .shrink() // Hide the button if at the bottom
                    : FloatingActionButton(
                        onPressed: controller.scrollToBottom,
                        child: const Icon(Icons.arrow_downward),
                      );
              }),
            ),
            Obx(() {
              if (controller.isNotification.value) {
                return Container(
                  color: Colors.amberAccent
                      .shade100, // Lighter background for better contrast
                  child: ListView.builder(
                    itemCount: 4, // Number of list items
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8), // Add spacing between items
                        decoration: BoxDecoration(
                          color: Colors.white, // Background for each list item
                          borderRadius:
                              BorderRadius.circular(8), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2), // Shadow position
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          title: Text("Item ${index + 1}",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent
                                      .shade400, // Custom color for accept button
                                  shape:
                                      const CircleBorder(), // Rounded shape for button
                                  padding: const EdgeInsets.all(
                                      8), // Padding to adjust size
                                ),
                                onPressed: () {
                                  // Handle accept button press
                                },
                                child: const Icon(Icons.check,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent
                                      .shade400, // Custom color for reject button
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(8),
                                ),
                                onPressed: () {
                                  // Handle reject button press
                                },
                                child: const Icon(Icons.close,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const SizedBox
                    .shrink(); // To ensure the Positioned widget is not shown when the condition is false.
              }
            }),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<MessageModel>> groupMessagesByDate(
      List<MessageModel> messages) {
    return groupBy(
        messages,
        (MessageModel m) => DateTime(
              m.timestamp.toDate().year,
              m.timestamp.toDate().month,
              m.timestamp.toDate().day,
            ));
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  Widget _buildMessageBubble(BuildContext context, bool isMe, String senderName,
      String text, String time) {
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
      bottomRight: isMe ? Radius.zero : const Radius.circular(12),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: borderRadius,
          border: Border.all(
            color: isMe ? Colors.blue.shade300 : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                senderName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                  fontSize: 12,
                ),
              ),
            Text(text),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMessageBubble(BuildContext context, String text) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.black54, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}

// Helper function to group messages by date
Map<K, List<T>> groupBy<T, K>(Iterable<T> values, K Function(T) keyFunction) =>
    Map.fromIterable(
      values.map(keyFunction).toSet(),
      value: (date) =>
          values.where((element) => keyFunction(element) == date).toList(),
    );

// Show a confirmation dialog to ask the user before exiting
Future<bool> _showExitConfirmationDialog(BuildContext context) async {
  return await Get.dialog(
        AlertDialog(
          title: const Text('Confirm Exit'),
          content: const Text('Are you sure you want to exit group?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Get.back(result: false); // Close the dialog, return false
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Get.back(result: true); // Close the dialog, return true
              },
            ),
          ],
        ),
      ) ??
      false; // Return false if the dialog is dismissed without a choice.
}
