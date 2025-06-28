// models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String fullname;
  final String email;
  final String role;
  final String createdBy;
  final String mobile;
  final Timestamp dateCreated;
  final bool isAdmin;
  final String deviceId;
  final String macAddress;
  final String ipAddress;
  final Timestamp? lastLogin;

  AppUser({
    required this.uid,
    required this.fullname,
    required this.role,
    required this.createdBy,
    required this.email,
    required this.mobile,
    required this.dateCreated,
    this.isAdmin = false,
    this.deviceId = '',
    this.macAddress = '',
    this.ipAddress = '',
    this.lastLogin,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    // 1. Safe null check
    if (!doc.exists || doc.data() == null) {
      return AppUser(
        uid: doc.id,
        fullname: '',
        email: '',
        role: '',
        createdBy: '',
        mobile: '',
        dateCreated: Timestamp.now(),
        isAdmin: false,
        deviceId: '',
        macAddress: '',
        ipAddress: '',
        lastLogin: null,
      );
    }

    // 2. Safe type casting
    final data = doc.data()! as Map<String, dynamic>;

    // 3. Handle potential null fields
    return AppUser(
      uid: doc.id,
      fullname: data['fullname']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? '',
      createdBy: data['createdBy']?.toString() ?? '',
      mobile: data['mobile']?.toString() ?? '',
      dateCreated: (data['dateCreated'] as Timestamp?) ?? Timestamp.now(),
      isAdmin: data['isAdmin'] as bool? ?? false,
      deviceId: data['deviceId']?.toString() ?? '',
      macAddress: data['macAd']?.toString() ?? '',
      // Field name mismatch handled
      ipAddress: data['ipAddress']?.toString() ?? '',
      lastLogin: data['lastLogin'] as Timestamp?,
    );
  }
}