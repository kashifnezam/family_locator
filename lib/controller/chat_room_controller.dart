import 'dart:async';
import 'dart:convert';
import 'package:family_locator/api/firebase_api.dart';
import 'package:family_locator/models/message_model.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:family_locator/utils/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class ChatRoomController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String roomId;
  final String userId;
  final String rooomName;
  Timer? _debounceTimer; // Timer for debounce

  RxList<MessageModel> messages = <MessageModel>[].obs;
  RxMap<String, String> userNames = <String, String>{}.obs;
  RxMap<String, LatLng> userLocations = <String, LatLng>{}.obs;
  RxBool isMessageValid = false.obs;
  RxBool isLoading = true.obs;
  RxBool isMapExpanded = false.obs;
  RxBool isLargerMap = false.obs;
  RxBool isNotification = false.obs;
  Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  RxDouble zoomLevel = 2.0.obs;
  DocumentSnapshot? _lastDocument;
  RxList<LatLng> routePoints = <LatLng>[].obs;

  bool _hasMoreMessages = true;
  final mapController = MapController();
  final RxBool isMapReady = false.obs;
  static const int messagesPerPage = 75;
  final ScrollController scrollController = ScrollController();
  RxBool isAtBottom = true.obs; // Reactive variable to track scroll position

  late StreamSubscription<QuerySnapshot> messagesSubscription;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      locationsSubscription;

  ChatRoomController({required this.roomId, required this.userId, required this.rooomName});

  @override
  void onInit() {
    super.onInit();
    fetchMessages(initial: true).then((_) => scrollToBottom());
    fetchLocations();
    scrollController.addListener(_scrollListener);
    listenToMessages(); // Start listening to messages
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    FirebaseApi.userJoinLeft("left", roomId);
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.offset < 0.5) {
      loadMoreMessages(); // Load more messages when scrolled to the top
    }
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent) {
      isAtBottom.value = true;
    } else {
      isAtBottom.value = false;
    }
  }

  void toggleMapExpansion() {
    isMapExpanded.toggle();
  }

  void toggleLargeMap() {
    isLargerMap.toggle();
  }
  void toggleNotification() {
    isNotification.toggle();
  }

  // to get the bounds of all users location
  LatLngBounds? get userLocationBounds {
    if (userLocations.isEmpty || userLocations.length < 2) return null;
    final points = userLocations.values.toList();
    return LatLngBounds.fromPoints(points);
  }

  //to give distance b/w two markers through polylines
  LatLng calculateMidpoint(LatLng start, LatLng end) {
    return LatLng(
      (start.latitude + end.latitude) / 2,
      (start.longitude + end.longitude) / 2,
    );
  }

  double calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  }

  //tp set the zoom level when click on marker or map
  void selectLocation(LatLng? location) {
    if (!isMapReady.value) return;
    selectedLocation.value = location;
    if (location != null) {
      zoomLevel.value = 5.0;
      mapController.move(location, 16.0);
    } else {
      zoomLevel.value = 2.0;
      fitMapToBounds();
    }
  }

  void fitMapToBounds() {
    if (!isMapReady.value ||
        userLocations.isEmpty ||
        userLocations.length < 2) {
      return;
    }
    final bounds = LatLngBounds.fromPoints(userLocations.values.toList());
    mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
  }

  void onMapCreated() {
    isMapReady.value = true;
    fitMapToBounds();
  }

  Future<void> fetchMessages({bool initial = false}) async {
    if (!_hasMoreMessages && !initial) return;
    isLoading.value = true;

    try {
      Query query = _firestore
          .collection('chatrooms')
          .doc(roomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(messagesPerPage);

      if (_lastDocument != null && !initial) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMoreMessages = false;
        isLoading.value = false;
        return;
      }

      List<MessageModel> newMessages = snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      if (initial) {
        messages.value = newMessages;
      } else {
        messages.addAll(newMessages);
      }

      _lastDocument = snapshot.docs.last;
      _hasMoreMessages = snapshot.docs.length == messagesPerPage;

      await fetchUserNames(roomId);
      isLoading.value = false;
    } catch (error) {
      AppConstants.log.e('Error fetching messages: $error');
      isLoading.value = false;
    }
  }

  // Updated method using getRoomMembers to fetch usernames
  Future<void> fetchUserNames(String roomId) async {
    try {
      // Fetch the list of members using the getRoomMembers method
      List<String> members =
          await FirebaseApi.getRoomMembers(roomId, "roomDetail", "members");

      if (members.isEmpty) {
        AppConstants.log.i('No members found in room.');
        return;
      }

      // Fetch details of each user in the members list
      var userDocs = await _firestore
          .collection('anonymous')
          .where(FieldPath.documentId, whereIn: members)
          .get();

      for (var doc in userDocs.docs) {
        // Store each username in the userNames map
        userNames[doc.id] = doc.get('usr') ?? 'Unknown';
      }

      // Log the fetched usernames
      AppConstants.log.i(userNames);
    } catch (e) {
      // Handle any errors during the operation
      AppConstants.log.e('Error fetching user names: $e');
    }
  }

  void fetchLocations() {
    locationsSubscription = _firestore
        .collection('roomDetail')
        .doc(roomId)
        .snapshots()
        .listen((roomSnapshot) {
      if (roomSnapshot.exists) {
        List<String> memberIds =
            List<String>.from(roomSnapshot.get('members') ?? []);

        if (memberIds.isNotEmpty) {
          _firestore
              .collection('anonymous')
              .where(FieldPath.documentId, whereIn: memberIds)
              .snapshots()
              .listen((anonymousSnapshot) {
            for (var doc in anonymousSnapshot.docs) {
              final userId = doc.id;
              final currLoc = doc.get('currLoc'); // Get the currLoc string
              final location =
                  _parseLocation(currLoc); // Parse the location string
              if (location != null) {
                userLocations[userId] = location; // Store the LatLng object
              }
            }
          });
        } else {
          userLocations.clear(); // Clear locations if there are no members
        }
      } else {
        AppConstants.log.e('Room not found');
        userLocations.clear(); // Clear locations if room doesn't exist
      }
    });
  }

  LatLng? _parseLocation(String currLoc) {
    // Example: "LatLng(latitude:28.617113, longitude:77.373625)"
    final regex =
        RegExp(r'LatLng\(latitude:(-?\d+\.\d+), longitude:(-?\d+\.\d+)\)');
    final match = regex.firstMatch(currLoc);
    if (match != null) {
      final latitude = double.parse(match.group(1)!);
      final longitude = double.parse(match.group(2)!);
      return LatLng(latitude, longitude);
    }
    return null; // Return null if parsing fails
  }

  void validateMessage(String text) {
    isMessageValid.value = text.trim().isNotEmpty;
  }

  Future<void> sendMessage(String text) async {
    text = text.trim();
    if (text.isEmpty) return;

    final message = MessageModel(
      sender: userId,
      text: text,
      timestamp: Timestamp.now(),
    );
    scrollToBottom();
    // Add the message to the local list immediately
    messages.insert(0, message); // Insert at the top for immediate visibility

    try {
      await _firestore
          .collection('chatrooms')
          .doc(roomId)
          .collection('messages')
          .add(message.toMap());
      AppConstants.log.i('Message sent successfully');
    } catch (e) {
      AppConstants.log.e('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message. Please try again.');
    }
  }

  //Load more messages on scroll
  void loadMoreMessages() {
    if (!isLoading.value && _hasMoreMessages) {
      fetchMessages();
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<List<LatLng>> fetchRoute(LatLng start, List<LatLng> waypoints) async {
    final waypointsString = waypoints
        .map((point) => '${point.longitude},${point.latitude}')
        .join(';');
    final url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};$waypointsString?overview=full';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Check if routes are available
      if (data['routes'].isNotEmpty) {
        final geometry = data['routes'][0]
            ['geometry']; // This is the encoded polyline string
        return decodePolyline(geometry); // Decode the polyline to LatLng points
      } else {
        throw Exception('No routes found');
      }
    } else {
      throw Exception('Failed to load route: ${response.body}');
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      // Decode latitude
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result >> 1) ^ -(result & 1));
      lat += dlat;

      shift = 0;
      result = 0;

      // Decode longitude
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result >> 1) ^ -(result & 1));
      lng += dlng;

      LatLng point = LatLng((lat / 1E5), (lng / 1E5));
      polyline.add(point);
    }

    return polyline;
  }

  void updatePolyline() {
    final myLoc = userLocations[DeviceInfo.deviceId];
    if (myLoc != null) {
      final waypoints =
          userLocations.values.where((loc) => loc != myLoc).toList();
      if (waypoints.length > 1) {
        // Cancel any existing timer
        _debounceTimer?.cancel();

        // Start a new timer for 3 seconds
        _debounceTimer = Timer(const Duration(seconds: 3), () {
          fetchRoute(myLoc, waypoints).then((route) {
            routePoints.value = route;
          });
        });
      }
    }
  }

  void listenToMessages() {
    _firestore
        .collection('chatrooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      // Clear messages and add new ones
      messages.clear();
      for (var doc in snapshot.docs) {
        messages.add(MessageModel.fromMap(doc.data()));
      }
      // Scroll to bottom only if the user is at the bottom
      if (isAtBottom.value) {
        scrollToBottom();
      }
    });
  }
}
