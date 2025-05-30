import 'package:family_room/utils/constants.dart';
import 'package:family_room/widgets/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import '../controller/history_tpr_controller.dart';

class HistoryTPR extends StatelessWidget {
  final String userId;
  final List userDetails;
  final HistoryTPRController controller;

  HistoryTPR({super.key, required this.userId, required this.userDetails})
      : controller = Get.put(
            HistoryTPRController(userId: userId)); // Initialize controller here

  //------------ Get Week Day ----------
  String getWeekdayAbbreviation(DateTime date) {
    return DateFormat('EEEE')
        .format(date); // 'EEE' gives abbreviated day names like Mon, Tue, etc.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: CircleAvatar(
            radius: AppConstants.width * 0.05,
            child: userDetails[0].isEmpty
                ? Text(userDetails[1].substring(0, 2).toUpperCase())
                : CustomWidget.getImage(userDetails[0]),
          ),
          title: Text(userDetails.length > 1 ? userDetails[1] : "Unknown User"),
          subtitle: Obx(
            () {
              if (controller.markerInfo.isEmpty) {
                return Text("History not available");
              } else {
                return Text(
                  "${controller.markerInfo[0].split(" ")[0]} - ${controller.markerInfo[1].split(" ")[0]}",
                  style: TextStyle(fontSize: 12),
                );
              }
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final today = DateTime.now();
              final twoDaysAgo = today.subtract(const Duration(days: 2));
              final result = await showOmniDateTimeRangePicker(
                context: context,
                startInitialDate: today,
                startFirstDate:
                    twoDaysAgo, // Allow selection starting from two days ago
                startLastDate:
                    today, // Enable today as the last selectable date
                endInitialDate: today,
                endFirstDate: twoDaysAgo, // Same restriction for the end date
                endLastDate: today,
                is24HourMode: false,
                isShowSeconds: false,
                minutesInterval: 1,
                secondsInterval: 1,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                constraints: const BoxConstraints(
                  maxWidth: 350,
                  maxHeight: 650,
                ),
                transitionBuilder: (context, anim1, anim2, child) {
                  return FadeTransition(
                    opacity: anim1.drive(Tween(begin: 0, end: 1)),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 200),
                barrierDismissible: true,
                endSelectableDayPredicate: (dateTime) {
                  // Disable 25th Feb 2023
                  return dateTime != DateTime(2023, 2, 25);
                },
              );

              if (result != null) {
                controller.getTPR(dateRange: result);
              }
            },
            child: Icon(Icons.calendar_month),
          ),
        ],
      ),
      body: Obx(() {
        return Stack(
          children: [
            FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
                minZoom: 0.2,
                initialRotation: 0,
                backgroundColor: Colors.blue.shade100,
                initialCameraFit: CameraFit.bounds(
                  bounds: controller.polylinePoints.isNotEmpty
                      ? LatLngBounds.fromPoints(controller.polylinePoints)
                      : MapConstants.indiaBounds,
                  padding: const EdgeInsets.all(30),
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  tileProvider: CachedTileProvider(
                    // use the store for your CachedTileProvider instance
                    store: MapConstants.cacheStore,
                  ),
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: controller.polylinePoints,
                      strokeWidth: 3.0,
                      color: Colors.blue,
                      // pattern: StrokePattern.dashed(segments: [1, 4]),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Arrow markers along the polyline path
                    ...controller.arrowMarkers.map((arrow) {
                      return Marker(
                        width: 20,
                        height: 20,
                        point: arrow['position'],
                        child: Transform.rotate(
                          angle: arrow['angle'] + 30,
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                      );
                    }),

                    // Red flag for the last point
                  ],
                ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(50),
                    maxZoom: 15,
                    markers: controller.markerInfo.isNotEmpty
                        ? [
                            if (controller.polylinePoints.isNotEmpty)
                              Marker(
                                point: controller.polylinePoints.first,
                                child: GestureDetector(
                                  onTap: () => CustomWidget.confirmDialogue(
                                    title: "Start Time",
                                    content: controller.markerInfo[0],
                                    isCancel: false,
                                  ),
                                  child: Icon(
                                    Icons.flag,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ),
                              ),
                            if (controller.polylinePoints.isNotEmpty)
                              Marker(
                                width: 30,
                                height: 30,
                                point: controller.polylinePoints.last,
                                child: GestureDetector(
                                  onTap: () => CustomWidget.confirmDialogue(
                                      title: "End Time",
                                      content: controller.markerInfo[1],
                                      isCancel: false),
                                  child: Icon(
                                    Icons.flag,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                ),
                              ),
                          ]
                        : [],
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blueGrey,
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
                )
              ],
            ),
            if (controller.isLoading.value)
              CustomWidget.buildCircularProgressIndicator(),
          ],
        );
      }),
    );
  }
}
