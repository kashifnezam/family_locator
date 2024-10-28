import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/widgets/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

import '../controller/history_tpr_controller.dart';

class HistoryTPR extends StatelessWidget {
  final String userId;
  final List userDetails;
  final HistoryTPRController controller;

  HistoryTPR({super.key, required this.userId, required this.userDetails})
      : controller = Get.put(
            HistoryTPRController(userId: userId)); // Initialize controller here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text(userDetails.length > 1 ? userDetails[1] : "Unknown User"),
          subtitle: Text("History of Last 3 days"),
        ),
        centerTitle: true,
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
                  subdomains: ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                        points: controller.polylinePoints,
                        strokeWidth: 3.0,
                        color: Colors.blue,
                        pattern: StrokePattern.dashed(segments: [1, 4])),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Green flag for the starting point
                    if (controller.polylinePoints.isNotEmpty)
                      Marker(
                        width: 30,
                        height: 30,
                        point: controller.polylinePoints.first,
                        child: Icon(
                          Icons.flag,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),

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
                    if (controller.polylinePoints.isNotEmpty)
                      Marker(
                        width: 30,
                        height: 30,
                        point: controller.polylinePoints.last,
                        child: Icon(
                          Icons.flag,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                  ],
                ),
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
