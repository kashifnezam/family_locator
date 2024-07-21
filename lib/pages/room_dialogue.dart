import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/room_dialogue_controller.dart';

class RoomDialog extends StatelessWidget {
  final controller = Get.put(RoomDialogController());

  RoomDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text(
              controller.isCreatingRoom.value ? 'Create Room' : 'Join Room')),
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
              Obx(() => ElevatedButton(
                    onPressed: () => controller.isCreatingRoom.value
                        ? null
                        : controller.toggleMode(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isCreatingRoom.value
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    child: const Text('Create Room'),
                  )),
              Obx(() => ElevatedButton(
                    onPressed: () => controller.isCreatingRoom.value
                        ? controller.toggleMode()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !controller.isCreatingRoom.value
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    child: const Text('Join Room'),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.nameController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
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
          onPressed: controller.submitForm,
          child: Obx(
              () => Text(controller.isCreatingRoom.value ? 'Create' : 'Join')),
        ),
      ],
    );
  }
}
