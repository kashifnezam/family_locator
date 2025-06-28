// models/member_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_room/utils/constants.dart';

class Member {
  final String uid;
  final String username;  // New unique username field
  final String fullname;
  final String? email;    // Make email optional
  final String role;
  final String createdBy;
  final String? mobile;   // Make mobile optional
  final Timestamp dateCreated;

  Member({
    required this.uid,
    required this.username,
    required this.fullname,
    this.email,
    this.role = 'employee',
    required this.createdBy,
    this.mobile,
    required this.dateCreated,
  });


  factory Member.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Member(
      uid: doc.id,
      username: data['username'] ?? '',
      fullname: data['fullname'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'employee',
      createdBy: data['createdBy'] ?? '',
      mobile: data['mobile'] ?? '',
      dateCreated: data['dateCreated'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullname': fullname,
      'email': email,
      'username': username,
      'role': role,
      'createdBy': createdBy,
      'mobile': mobile,
      'dateCreated': dateCreated,
    };
  }
}