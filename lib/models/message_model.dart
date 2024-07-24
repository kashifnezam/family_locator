import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String sender;
  final String text;
  final Timestamp timestamp;

  MessageModel(
      {required this.sender, required this.text, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'text': text,
      'timestamp': timestamp,
    };
  }

  static MessageModel fromMap(Map<String, dynamic> map) {
    return MessageModel(
      sender: map['sender'],
      text: map['text'],
      timestamp: map['timestamp'],
    );
  }
}
