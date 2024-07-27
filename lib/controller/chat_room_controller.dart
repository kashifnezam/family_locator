import 'dart:async';
import 'dart:convert';
import 'package:family_locator/models/message_model.dart';
import 'package:family_locator/utils/constants.dart';
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

  RxList<MessageModel> messages = <MessageModel>[].obs;
  RxMap<String, String> userNames = <String, String>{}.obs;
  RxMap<String, LatLng> userLocations = <String, LatLng>{}.obs;
  RxBool isMessageValid = false.obs;
  RxBool isLoading = true.obs;
  RxBool isMapExpanded = false.obs;
  Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  RxDouble zoomLevel = 2.0.obs;
  DocumentSnapshot? _lastDocument;

  bool _hasMoreMessages = true;
  final mapController = MapController();
  final RxBool isMapReady = false.obs;
  static const int messagesPerPage = 20;
  final ScrollController scrollController = ScrollController();

  late StreamSubscription<QuerySnapshot> messagesSubscription;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      locationsSubscription;

  ChatRoomController({required this.roomId, required this.userId});

  @override
  void onInit() {
    super.onInit();
    fetchMessages(initial: true).then((_) => scrollToBottom());
    fetchLocations();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.offset < 5) {
      loadMoreMessages(); // Load more messages when scrolled to the top
    }
  }

  void toggleMapExpansion() {
    isMapExpanded.toggle();
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

      fetchUserNames(newMessages);
      isLoading.value = false;
    } catch (error) {
      AppConstants.log.e('Error fetching messages: $error');
      isLoading.value = false;
    }
  }

  Future<void> fetchUserNames(List<MessageModel> newMessages) async {
    Set<String> uniqueUserIds = newMessages.map((m) => m.sender).toSet()
      ..removeWhere((id) => userNames.containsKey(id));

    if (uniqueUserIds.isEmpty) return;

    try {
      var userDocs = await _firestore
          .collection('anonymous')
          .where(FieldPath.documentId, whereIn: uniqueUserIds.toList())
          .get();

      for (var doc in userDocs.docs) {
        userNames[doc.id] = doc.get('name') ?? 'Unknown';
      }
    } catch (e) {
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

  //Load more messages on scroll
  void loadMoreMessages() {
    if (!isLoading.value && _hasMoreMessages) {
      fetchMessages();
    }
  }

  List<LatLng> getPathBetweenMarkers() {
    return userLocations.values.toList();
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
      final route = data['routes'][0]['geometry']['coordinates'] as List;
      return route
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList(); // Convert to LatLng
    } else {
      throw Exception('Failed to load route');
    }
  }

  void onMarkerTap(LatLng selectedLocation) async {
    AppConstants.log.e("mai to heel gya");
    try {
      final route =
          await fetchRoute(selectedLocation, userLocations.values.toList());
      // Update your polyline layer with the new route
      updatePolyline(route);
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  RxList<LatLng> routePoints = <LatLng>[].obs;

  void updatePolyline(List<LatLng> newRoute) {
    routePoints.value = newRoute;
  }

  Future<void> fetchRouteToMarker(LatLng selectedLocation) async {
    try {
      // Get the list of waypoints (other markers)
      List<LatLng> waypoints =
          userLocations.values.where((loc) => loc != selectedLocation).toList();

      // Call the method to get the route
      List<LatLng> route = await fetchRoute(selectedLocation, waypoints);

      // Update the route points to display on the map
      updatePolyline(route);
    } catch (e) {
      print('Error fetching route: $e');
    }
  }
}
