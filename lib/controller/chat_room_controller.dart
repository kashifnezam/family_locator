import 'dart:async';

import 'package:family_locator/models/message_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String roomId;
  final String userId;

  RxList<MessageModel> messages = <MessageModel>[].obs;
  RxMap<String, String> userNames = <String, String>{}.obs;
  RxBool isMessageValid = false.obs;
  RxBool isLoading = true.obs;

  late StreamSubscription<QuerySnapshot> _messagesSubscription;

  ChatRoomController({required this.roomId, required this.userId});

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
  }

  @override
  void onClose() {
    _messagesSubscription.cancel();
    super.onClose();
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
        return MessageModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      messages.value = newMessages;
      fetchUserNames(newMessages);
      isLoading.value = false;
    }, onError: (error) {
      print('Error fetching messages: $error');
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
      print('Error fetching user names: $e');
    }
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
      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message. Please try again.');
    }
  }
}
