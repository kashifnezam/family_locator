import 'package:family_locator/controller/home_controller.dart';
import 'package:family_locator/pages/family_room.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/widgets/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:get/get.dart';
import '../utils/device_info.dart';
import '../utils/offline_data.dart';
import '../widgets/button_widget.dart';
import '../widgets/username_dialogue.dart';
import 'room_dialogue.dart';

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
                      child: CircleAvatar(
                        radius: AppConstants.width * 0.09,
                        backgroundImage: NetworkImage(
                            "https://img.lovepik.com/element/45016/4170.png_860.png"),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "YMH",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70),
                        ),
                        Text(
                          "+91 7077220222",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white54,
                ),
                title: Text(
                  "Profile",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70),
                ),
              ),
              ListTile(
                onTap: () async {
                  Get.back();
                  CustomWidget.roomWidget();
                },
                leading: Icon(
                  Icons.groups_3_sharp,
                  color: Colors.white54,
                ),
                title: Text(
                  "Groups",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.cast_connected,
                  color: Colors.white54,
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
                  color: Colors.white54,
                ),
                title: Text(
                  "Settings",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70),
                ),
              ),
              Divider(
                color: Colors.white54,
              ),
              ListTile(
                leading: Icon(
                  Icons.group_add,
                  color: Colors.white54,
                ),
                title: Text(
                  "Invite Friends",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.logout_rounded,
                  color: Colors.white54,
                ),
                title: Text(
                  "Logout",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70),
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
                        final firstLetter = usr[0].isNotEmpty
                            ? userId == DeviceInfo.deviceId
                                ? "You"
                                : usr[0][0].toUpperCase()
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
                                      "Name: ${usr[0]} \nGroup in common: ${usr.skip(1).join(', ')}",
                                  isCancel: false);
                            },
                            child: Tooltip(
                              message: usr[0],
                              child: Container(
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
