import 'package:family_locator/controller/home_controller.dart';
import 'package:family_locator/pages/family_room.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/widgets/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:get/get.dart';
import '../utils/device_info.dart';
import '../widgets/button_widget.dart';
import 'edit_profile.dart';

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
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color of the back arrow
        ),
        backgroundColor: Colors.blueGrey,
        title: GestureDetector(
          onTap: () => Get.to(() => FamilyRoom()),
          child: ButtonWidget.elevatedBtn("Family Room",
              height: AppConstants.height * 0.05),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () => controller.fitMapToBounds(),
              icon: Icon(Icons.reset_tv_rounded))
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.blueGrey,
          child: ListView(
            children: [
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Obx(() {
                        return CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          radius: AppConstants.width * 0.09,
                          backgroundImage:
                              controller.dpImagePath.value.isNotEmpty
                                  ? NetworkImage(controller.dpImagePath.value)
                                  : null,
                          child: controller.dpImagePath.value.isEmpty
                              ? CircleAvatar(
                                  radius: AppConstants.width * 0.09,
                                  child: Text(
                                    controller.username.value
                                        .toString()
                                        .toUpperCase()
                                        .substring(0, 2),
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ) // Show initials if no image
                              : null,
                        );
                      }),
                    ),
                    Obx(
                      () {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.username.value,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              DeviceInfo.deviceId ?? "xx xxx xxx",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70),
                            ),
                          ],
                        );
                      },
                    )
                  ],
                ),
              ),
              ListTile(
                onTap: () {
                  Get.back();
                  Get.to(() => EditProfile());
                },
                leading: Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white,
                ),
                title: Text(
                  "Profile",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              ListTile(
                onTap: () {
                  Get.back();
                  CustomWidget.roomWidget();
                },
                leading: Icon(
                  Icons.groups_3_sharp,
                  color: Colors.white,
                ),
                title: Text(
                  "Groups",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.cast_connected,
                  color: Colors.white70,
                ),
                title: Text(
                  "Connections",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: Colors.white70,
                ),
                title: Text(
                  "Settings",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.account_balance_outlined,
                  color: Colors.white,
                ),
                title: Text(
                  "Donate",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Divider(
                color: Colors.white70,
              ),
              ListTile(
                leading: Icon(
                  Icons.group_add,
                  color: Colors.white,
                ),
                title: Text(
                  "Invite Friends",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                ),
                title: Text(
                  "Logout",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(
        () => FlutterMap(
          mapController: controller.mapController,
          options: MapOptions(
            // cameraConstraint:
            //     CameraConstraint.contain(bounds: MapConstants.maxBounds),
            minZoom: 0.2,
            backgroundColor: Colors.blue.shade100,
            // onMapReady: controller.onMapCreated,
            // initialZoom: controller.zoomLevel.value,
            initialCameraFit: CameraFit.bounds(
              bounds: controller.userLocationBounds ?? MapConstants.indiaBounds,
              padding: const EdgeInsets.all(30),
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              fallbackUrl:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // Provide fallback
            ),
            // PolylineLayer(
            //   polylines: [
            //     Polyline(
            //       points:
            //           controller.userLocations.values.toList(),
            //       strokeWidth: 1.0,
            //       color: Colors.grey,
            //     ),
            //     Polyline(
            //       points: controller.routePoints,
            //       strokeWidth: 4.0,
            //       color: Colors.blue,
            //     ),
            //   ],
            // ),
            Obx(
              () {
                return MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    inside: true,
                    centerMarkerOnClick: true,
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(50),
                    maxZoom: 15,
                    markers: [
                      ...controller.userLocations.entries.map((entry) {
                        final userId = entry.key;
                        final location = entry.value;
                        final List<String> usr =
                            controller.userDetails[userId] ?? [];
                        final firstLetter = usr[1].isNotEmpty
                            ? userId == DeviceInfo.deviceId
                                ? "You"
                                : usr[1].substring(0, 2).toUpperCase()
                            : '?';
                        return Marker(
                          point: location,
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onDoubleTap: () =>
                                controller.selectLocation(location),
                            onTap: () {
                              CustomWidget.confirmDialogue(
                                  title: "User Info",
                                  content:
                                      "Name: ${usr[1]} \nGroup in common: ${usr.skip(2).join(', ')}",
                                  isCancel: false);
                            },
                            child: Tooltip(
                              message: usr[1],
                              child: usr[0] != "" &&
                                      userId != DeviceInfo.deviceId
                                  ? CircleAvatar(
                                      backgroundImage: usr[0] != ""
                                          ? NetworkImage(usr[0])
                                          : null,
                                    )
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
                          ),
                        );
                      }),
                    ],
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.blue),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
