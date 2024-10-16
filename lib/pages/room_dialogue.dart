import 'dart:io';
import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/widgets/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/room_dialogue_controller.dart';

class RoomDialog extends StatelessWidget {
  final controller = Get.put(RoomDialogController());

  RoomDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: AppConstants.width,
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
                  onPressed: () {
                    controller.imagepath.value = "";
                    controller.nameController.clear();
                    controller.roomController.clear();
                    Get.back();
                  },
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
                Obx(() {
                  return controller.isCreatingRoom.value
                      ? Column(
                          children: [
                            TextField(
                              maxLines: 1,
                              controller: controller.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Room Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: AppConstants.width * 0.45,
                                  child: TextField(
                                    maxLines: 1,
                                    keyboardType: TextInputType.number,
                                    controller: controller.roomController,
                                    decoration: const InputDecoration(
                                      labelText: 'Room Number',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    controller.imagepath.value =
                                        await CustomWidget.imagePickFrom(
                                            source: "gallary");
                                  },
                                  child: CircleAvatar(
                                      backgroundColor: Colors.blueGrey,
                                      radius: AppConstants.width * 0.07,
                                      backgroundImage: controller
                                                  .imagepath.value !=
                                              ""
                                          ? FileImage(
                                              File(controller.imagepath.value))
                                          : null,
                                      child: controller.imagepath.value == ""
                                          ? Icon(
                                              Icons.add_a_photo_sharp,
                                              color: Colors.white,
                                            )
                                          : null),
                                ),
                              ],
                            ),
                          ],
                        )
                      : TextField(
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          controller: controller.roomController,
                          decoration: const InputDecoration(
                            labelText: 'Room Number',
                            border: OutlineInputBorder(),
                          ),
                        );
                })
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.submitForm();
                  },
                  child: Obx(() => controller.isLoading.value
                      ? CustomWidget.buildCircularProgressIndicator()
                      : Text(
                          controller.isCreatingRoom.value ? 'Create' : 'Join')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
