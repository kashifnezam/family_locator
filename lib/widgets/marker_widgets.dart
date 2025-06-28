import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../controller/home_controller.dart';
import '../pages/history_tpr.dart';
import '../utils/constants.dart';
import 'custom_widget.dart';

class UserMarkerWidget extends StatefulWidget {
  final String userId;
  final List<String> userDetails;
  final LatLng location;
  final bool isCurrentUser;

  const UserMarkerWidget({
    required this.userId,
    required this.userDetails,
    required this.location,
    required this.isCurrentUser,
  });

  @override
  State<UserMarkerWidget> createState() => _UserMarkerWidgetState();
}

class _UserMarkerWidgetState extends State<UserMarkerWidget> {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials();
    return GestureDetector(
      onTap: _showUserInfo,
      child: Tooltip(
        message: widget.userDetails.length > 1 ? widget.userDetails[1] : "Unknown",
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.isCurrentUser ? Colors.blue : Colors.black,
            ),
            color: widget.isCurrentUser ? Colors.blueGrey : Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: widget.isCurrentUser ? Colors.white : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    if (widget.userDetails.length > 1 && widget.userDetails[1].isNotEmpty) {
      return widget.isCurrentUser
          ? "You"
          : widget.userDetails[1].substring(0, 1).toUpperCase();
    }
    return '?';
  }

  void _showUserInfo() {
    {
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile picture on top
                CircleAvatar(
                  backgroundColor: Colors.blueGrey,
                  radius: AppConstants.width * 0.12,
                  child: widget.userDetails[0].isNotEmpty
                      ? CustomWidget.getImage(widget.userDetails[0])
                      : Text(
                    controller.username.value
                        .substring(0, 2)
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                    height: 16), // Space between profile picture and text
                // User information text
                Text(
                  widget.userDetails.isNotEmpty && widget.userDetails.length > 1
                      ? "Name: ${widget.userDetails[1]}\nRooms: ${widget.userDetails.skip(2).join(', ')}"
                      : "No user information available.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign
                      .center, // Center the text for better alignment
                ),
              ],
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
                    userId: widget.userId,
                    userDetails: widget.userDetails,
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
    } // Your existing dialog code
  }
}