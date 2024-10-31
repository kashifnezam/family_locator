import 'package:family_locator/controller/home_controller.dart';
import 'package:family_locator/pages/family_room.dart';
import 'package:family_locator/pages/settings.dart';
import 'package:family_locator/pages/support_us.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/widgets/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:get/get.dart';
import '../utils/device_info.dart';
import '../widgets/button_widget.dart';
import 'edit_profile.dart';
import 'history_tpr.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildMap(),
    );
  }

  // App Bar with Family Room Button and Reset Map View Action
  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.blueGrey,
      title: GestureDetector(
        onTap: () => Get.to(() => const FamilyRoom()),
        child: ButtonWidget.elevatedBtn(
          "Family Room",
          height: AppConstants.height * 0.05,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: controller.fitMapToBounds,
          icon: const Icon(Icons.reset_tv_rounded),
        ),
      ],
    );
  }

  // Side Drawer with Profile Information and Navigation Options
  Drawer _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.blueGrey,
        child: ListView(
          children: [
            DrawerHeader(
              child: _buildProfileInfo(),
            ),
            _buildDrawerItem(
              icon: Icons.account_circle_outlined,
              label: "Profile",
              onTap: () {
                Get.back();
                Get.to(() => const EditProfile());
              },
            ),
            _buildDrawerItem(
              icon: Icons.groups_3_sharp,
              label: "Groups",
              onTap: () {
                Get.back();
                CustomWidget.roomWidget();
              },
            ),
            _buildDrawerItem(
              icon: Icons.cast_connected,
              color: Colors.white70,
              label: "Connections",
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              label: "Settings",
              onTap: () => Get.to(() => const SettingsPage()),
            ),
            _buildDrawerItem(
              icon: Icons.account_balance_outlined,
              label: "Donate",
              onTap: () => Get.to(() => SupportUs()),
            ),
            const Divider(color: Colors.white70),
            _buildDrawerItem(
              icon: Icons.group_add,
              label: "Invite Friends",
            ),
            _buildDrawerItem(
              icon: Icons.logout_rounded,
              color: Colors.white70,
              label: "Logout",
            ),
          ],
        ),
      ),
    );
  }

  // Profile information shown in the drawer header
  Column _buildProfileInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => CircleAvatar(
            backgroundColor: Colors.blueGrey,
            radius: AppConstants.width * 0.12,
            child: controller.dpImagePath.value.isNotEmpty
                ? CustomWidget.getImage(controller.dpImagePath.value)
                : Text(
                    controller.username.value.substring(0, 2).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.username.value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  DeviceInfo.deviceId ?? "Unknown Device",
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70),
                ),
              ],
            )),
      ],
    );
  }

  // Drawer item with consistent styling
  ListTile _buildDrawerItem(
      {required IconData icon,
      Color color = Colors.white,
      required String label,
      VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style:
            TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  // Map display with markers and clustering
  Widget _buildMap() {
    return Obx(
      () => FlutterMap(
        mapController: controller.mapController,
        options: MapOptions(
          interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
          minZoom: 0.2,
          initialRotation: 0,
          backgroundColor: Colors.blue.shade100,
          onMapReady: () async {
            await Future.delayed(Duration(
                seconds: 5)); // Delay to ensure the map is fully initialized
            controller.fitMapToBounds(); // Fit bounds after the delay
          },
          initialCameraFit: CameraFit.bounds(
            bounds: controller.userLocationBounds ?? MapConstants.indiaBounds,
            padding: const EdgeInsets.all(30),
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: 45,
              size: const Size(40, 40),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(50),
              maxZoom: 15,
              markers: _buildUserMarkers(),
              builder: (context, markers) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueGrey),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Text(
                      markers.length.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Generate user markers for the map
  List<Marker> _buildUserMarkers() {
    return controller.userLocations.entries.map((entry) {
      final userId = entry.key;
      final location = entry.value;

      // Check if userDetails has enough elements and set default values if empty
      final List<String> userDetails = controller.userDetails[userId] ?? [];
      final String initials = (userDetails.isNotEmpty &&
              userDetails.length > 1 &&
              userDetails[1].isNotEmpty)
          ? (userId == DeviceInfo.deviceId
              ? "You"
              : userDetails[1].substring(0, 2).toUpperCase())
          : '?';

      return Marker(
        point: location,
        width: 40,
        height: 40,
        child: GestureDetector(
          onDoubleTap: () => controller.selectLocation(location),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'User Info',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  content: Text(
                    userDetails.isNotEmpty && userDetails.length > 1
                        ? "Name: ${userDetails[1]}\nRooms: ${userDetails.skip(2).join(', ')}"
                        : "No user information available.",
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Get.back(); // Close the dialog
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => HistoryTPR(
                              userId: userId,
                              userDetails: userDetails,
                            ));
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                      ),
                      child: Text('View History'),
                    ),
                  ],
                );
              },
            );
          },
          child: Tooltip(
            message: userDetails.length > 1 ? userDetails[1] : "Unknown User",
            child: _buildMarkerContent(initials, userId, userDetails),
          ),
        ),
      );
    }).toList();
  }

// Build the marker content based on user details
  Widget _buildMarkerContent(
      String initials, String userId, List<String> userDetails) {
    return userDetails.isNotEmpty &&
            userDetails[0].isNotEmpty &&
            userId != DeviceInfo.deviceId
        ? CustomWidget.getImage(userDetails[0])
        : Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              color: userId == DeviceInfo.deviceId
                  ? Colors.blueGrey
                  : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: userId == DeviceInfo.deviceId
                      ? Colors.white
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
  }
}
