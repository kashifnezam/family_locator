import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the GetX controller
    final settingsController = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.location_history),
            title: const Text("Store location"),
            subtitle: const Text(
              "Visible to all Room Members",
              style: TextStyle(fontSize: 12),
            ),
            trailing: Obx(() {
              return Switch(value: true, onChanged: null);
            }),
          ),
        ],
      ),
    );
  }

  // Custom radio button builder
  Widget _buildRadioButton(
    BuildContext context,
    SettingsController settingsController,
    int value,
    String label,
  ) {
    return GestureDetector(
      onTap: () => settingsController.setLocationHistoryOption(value),
      child: Row(
        children: [
          Radio<int>(
            value: value,
            groupValue: settingsController.locationHistoryOption.value,
            onChanged: settingsController.setLocationHistoryOption,
            activeColor: Theme.of(context).primaryColor,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: settingsController.locationHistoryOption.value == value
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade700,
                ),
          ),
        ],
      ),
    );
  }
}
