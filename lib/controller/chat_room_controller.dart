import 'dart:async';
import 'package:family_locator/models/message_model.dart';
import 'package:family_locator/utils/constants.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

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

  late StreamSubscription<QuerySnapshot> _messagesSubscription;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      _locationsSubscription;

  ChatRoomController({required this.roomId, required this.userId});

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
    fetchLocations();
  }

  @override
  void onClose() {
    _messagesSubscription.cancel();
    _locationsSubscription.cancel();
    super.onClose();
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

  void fetchMessages() {
    isLoading.value = true;
    _messagesSubscription = _firestore
        .collection('chatrooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      List<MessageModel> newMessages = snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data());
      }).toList();

      messages.value = newMessages;
      fetchUserNames(newMessages);
      isLoading.value = false;
    }, onError: (error) {
      AppConstants.log.e('Error fetching messages: $error');
      isLoading.value = false;
    });
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
    _locationsSubscription = _firestore
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
}
