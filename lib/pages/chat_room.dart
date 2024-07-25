import 'package:family_locator/utils/device_info.dart';
import 'package:family_locator/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controller/chat_room_controller.dart';
import '../models/message_model.dart';

class ChatRoom extends StatefulWidget {
  final String roomId;
  final String userId;

  const ChatRoom({super.key, required this.roomId, required this.userId});

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
    final ChatRoomController controller = Get.put(
        ChatRoomController(roomId: widget.roomId, userId: widget.userId));
    final TextEditingController messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Room'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Obx(() {
                if (controller.isMapExpanded.value) {
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black45, width: 4),
                        borderRadius: BorderRadius.circular(8)),
                    height: 300, // Height of the expanded map
                    child: FlutterMap(
                      mapController: controller.mapController,
                      options: MapOptions(
                        onMapReady: controller.onMapCreated,
                        initialZoom: controller.zoomLevel.value,
                        initialCameraFit: CameraFit.bounds(
                          bounds: controller.userLocationBounds ??
                              LatLngBounds(
                                const LatLng(6.4626999,
                                    68.1097), // Southwest corner of India
                                const LatLng(35.6745457,
                                    97.395561), // Northeast corner of India
                              ),
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
                                strokeWidth: 2.0,
                                color: Colors.deepPurple.shade800,
                                pattern: StrokePattern.dashed(
                                  segments: const [5, 5],
                                )),
                          ],
                        ),
                        MarkerLayer(
                          rotate: true,
                          markers:
                              controller.userLocations.entries.map((entry) {
                            final userId = entry.key;
                            final location = entry.value;
                            final userName =
                                controller.userNames[userId] ?? 'Unknown';
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
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: userId == DeviceInfo.deviceId
                                        ? Colors.blueGrey
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      firstLetter,
                                      style: TextStyle(
                                        color: userId == DeviceInfo.deviceId
                                            ? Colors.white
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
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
                  if (controller.isLoading.value) {
                    return WidgetUtil.buildCircularProgressIndicator();
                  }
                  if (controller.messages.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }

                  // Group messages by date
                  final groupedMessages =
                      groupMessagesByDate(controller.messages);

                  return CustomScrollView(
                    slivers: groupedMessages.entries
                        .map((entry) {
                          final date = entry.key;
                          final messagesForDate = entry.value.reversed.toList();

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
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _formatDateHeader(date),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final message = messagesForDate[index];
                                  final senderName =
                                      controller.userNames[message.sender] ??
                                          'Unknown';
                                  final isMe =
                                      message.sender == DeviceInfo.deviceId;
                                  final formattedTime = DateFormat('HH:mm')
                                      .format(message.timestamp.toDate());

                                  return _buildMessageBubble(context, isMe,
                                      senderName, message.text, formattedTime);
                                },
                                childCount: messagesForDate.length,
                              ),
                            ),
                          );
                        })
                        .toList()
                        .reversed
                        .toList(),
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
                        onChanged: (text) => controller.validateMessage(text),
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
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: controller.toggleMapExpansion,
              child: Obx(() => Icon(
                  controller.isMapExpanded.value ? Icons.close : Icons.map)),
            ),
          ),
        ],
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
}

// Helper function to group messages by date
Map<K, List<T>> groupBy<T, K>(Iterable<T> values, K Function(T) keyFunction) =>
    Map.fromIterable(
      values.map(keyFunction).toSet(),
      value: (date) =>
          values.where((element) => keyFunction(element) == date).toList(),
    );
