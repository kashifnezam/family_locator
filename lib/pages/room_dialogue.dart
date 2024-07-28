import 'package:family_locator/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/room_dialogue_controller.dart';

class RoomDialog extends StatelessWidget {
  final controller = Get.put(RoomDialogController());

  RoomDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    controller.isCreatingRoom.value
                        ? 'Create Room'
                        : 'Join Room',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Obx(
                      () => ElevatedButton(
                        onPressed: () => controller.isCreatingRoom.value
                            ? null
                            : controller.toggleMode(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isCreatingRoom.value
                              ? Colors.blue
                              : Colors.white,
                        ),
                        child: Text(
                          'Create Room',
                          style: TextStyle(
                              color: controller.isCreatingRoom.value
                                  ? Colors.black
                                  : Colors.grey),
                        ),
                      ),
                    ),
                    Obx(() => ElevatedButton(
                          onPressed: () => controller.isCreatingRoom.value
                              ? controller.toggleMode()
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !controller.isCreatingRoom.value
                                ? Colors.blue
                                : Colors.white,
                          ),
                          child: Text(
                            'Join Room',
                            style: TextStyle(
                                color: !controller.isCreatingRoom.value
                                    ? Colors.black
                                    : Colors.grey),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  maxLines: 1,
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  controller: controller.roomController,
                  decoration: const InputDecoration(
                    labelText: 'Room Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  controller.submitForm(); // Call the method correctly
                },
                child: Obx(() =>
                    Text(controller.isCreatingRoom.value ? 'Create' : 'Join')),
              ),
            ],
          ),
        ),
        // Progress Indicator
        Obx(() {
          if (controller.isLoading.value) {
            return WidgetUtil.buildCircularProgressIndicator();
          }
          return const SizedBox
              .shrink(); // Return an empty widget when not loading
        }),
      ],
    );
  }
}
