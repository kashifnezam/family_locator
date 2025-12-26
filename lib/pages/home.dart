import 'package:family_room/controller/home_controller.dart';
import 'package:family_room/pages/auth/authentication.dart';
import 'package:family_room/pages/family_room.dart';
import 'package:family_room/pages/org/organization_page.dart';
import 'package:family_room/pages/task/add_task_screen.dart';
import 'package:family_room/pages/task/task_list_screen.dart';
import 'package:family_room/utils/constants.dart';
import 'package:family_room/utils/offline_data.dart';
import 'package:family_room/widgets/custom_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:get/get.dart';
import 'package:upgrader/upgrader.dart';
import '../utils/custom_alert.dart';
import '../utils/device_info.dart';
import '../widgets/button_widget.dart';
import '../widgets/marker_widgets.dart';
import 'edit_profile.dart';
import 'history_tpr.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final HomeController controller = Get.put(HomeController());
  final GlobalKey _toolTipKey = GlobalKey();

  void _showTooltip() {
    final dynamic tooltip = _toolTipKey.currentState;
    tooltip?.ensureTooltipVisible();
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: Scaffold(
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
        body: _buildMap(),
      ),
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
        getToolTip(),
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
              label: "Rooms",
              onTap: () {
                Get.back();
                CustomWidget.roomWidget();
              },
            ),
            _buildDrawerItem(
              icon: Icons.cast_connected,
              color: Colors.white,
              label: "Connections",
              onTap: () => Get.to(() => TaskListScreen()),
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              color: Colors.white60,
              label: "Settings",
              // onTap: () => Get.to(() => const SettingsPage()),
            ),
            // _buildDrawerItem(
            //   icon: Icons.account_balance_outlined,
            //   label: "Donate",
            //   onTap: () => Get.to(() => SupportUs()),
            // ),

            _buildDrawerItem(
              icon: Icons.business,
              label: "Organization Settings",
              onTap: () => Get.to(() => OrganizationSettingsPage()),
            ),
            const Divider(color: Colors.white60),
            _buildDrawerItem(
              icon: Icons.group_add,
              color: Colors.white60,
              label: "Invite Friends",
            ),
            _buildDrawerItem(
                icon: Icons.login_outlined,
                label: "Logout",
                onTap: () async {
                  try {
                    // 1. Sign out from Firebase
                    await FirebaseAuth.instance.signOut();

                    // 2. Clear offline data (SharedPreferences)
                    await OfflineData.clearAll();
                    const platform =
                        MethodChannel('com.kashif.location_service');
                    await platform.invokeMethod('stopLocationUpdates');

                    // 3. Navigate to authentication screen
                    Get.offAll(() => AuthenticationView());
                  } catch (e) {
                    // Optional: Add error handling
                    debugPrint('Logout error: $e');
                    CustomAlert.errorAlert(
                      title: "Logout Failed",
                      // Make sure context is available
                      "Couldn't logout properly. Please try again.",
                    );
                  }
                }),
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
            radius: AppConstants.width * 0.11,
            child: controller.dpImagePath.value.isNotEmpty
                ? CustomWidget.getImage(controller.dpImagePath.value)
                : Flexible(
                    child: Text(
                      controller.username.value.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  controller.email.value,
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
          maxZoom: 18,
          keepAlive: true,
          minZoom: 0.2,
          initialRotation: 0,
          interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom |
                  InteractiveFlag.drag |
                  InteractiveFlag.flingAnimation),
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
            userAgentPackageName: "com.kashif.family_room",
            tileProvider: CachedTileProvider(
              // use the store for your CachedTileProvider instance
              store: MapConstants.cacheStore,
            ),
          ),
          MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: 120,
              disableClusteringAtZoom: 15,
              // Cluster until this zoom level
              spiderfyCircleRadius: 80,
              spiderfySpiralDistanceMultiplier: 2,
              showPolygon: false,
              // Disable polygon for performance
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

  Widget getToolTip() {
    return GestureDetector(
      onTap: _showTooltip,
      child: Tooltip(
        key: _toolTipKey,
        message:
            "To ensure the latest information is displayed, please restart the app whenever you join a room or a new member is added.",
        padding: EdgeInsets.all(12.0),
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        showDuration: Duration(seconds: 5),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade800,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        textStyle: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        child: IconButton(
          icon: Icon(Icons.info_outline, color: Colors.white),
          onPressed: _showTooltip,
        ),
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
          ? (userId == DeviceInfo.userUID
              ? "You"
              : userDetails[1].substring(0, 2).toUpperCase())
          : '?';

      return Marker(
        point: location,
        width: 40,
        height: 40,
        child: UserMarkerWidget(
          userId: userId,
          userDetails: userDetails,
          location: location,
          isCurrentUser: userId == DeviceInfo.userUID,
        ),
      );
    }).toList();
  }

}
