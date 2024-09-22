import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/Username_dialog_controller.dart';

class UsernameDialog extends StatelessWidget {
  final UsernameDialogController controller =
    Get.put(UsernameDialogController());

  UsernameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Username'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            return TextField(
              controller: controller.usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                errorText: controller.isValid.value
                    ? null
                    : controller.isNotValidMsg.toString(),
              ),
              // onChanged: (value) {
              //   controller.validateUsername(value.toString().trim().toLowerCase());
              // },
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(), // Close the dialog
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: controller.submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
