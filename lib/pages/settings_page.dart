import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  final SettingsController settingsController = Get.put(SettingsController());

  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(() {
              return SwitchListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.location_history_rounded),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Enable Location History'),
                  ],
                ),
                value: settingsController.isLocationTrackingEnabled.value,
                onChanged: (value) {
                  settingsController.toggleLocationTracking(value);
                },
              );
            }),
            // Add more settings options here as needed
          ],
        ),
      ),
    );
  }
}
