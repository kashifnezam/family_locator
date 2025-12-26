// services/auth_service.dart
import 'dart:async';

import 'package:family_room/utils/constants.dart';
import 'package:family_room/utils/custom_alert.dart';
import 'package:family_room/utils/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../models/user_modal/app_user_modal.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference members =
      FirebaseFirestore.instance.collection('members');

  /// Check if username exists in any member document
  Future<bool> isUsernameAvailable(String username) async {
    try {
      // Query members where 'username' equals the input (case-sensitive)
      final query = await members
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();
      return query.docs.isEmpty; // Available if no documents found
    } catch (e) {
      CustomAlert.errorAlert('Error checking username: $e');
      return false; // Assume unavailable if error occurs
    }
  }


  /// Register with username (instead of email)
  Future<UserCredential> registerWithUsername({
    required String username,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // Create email-like string using username
      final authEmail = '$username@${AppConstants.authDomain}';
      // Define this constant in your AppConstants

      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: authEmail,
        password: password,
      );
      await _firestore.collection('members').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'usr': username,
        "cBy": DeviceInfo.userUID,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Store user data
      await _firestore
          .collection('user')
          .doc(userCredential.user!.uid)
          .set(userData);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Login with username
  Future<UserCredential> loginWithUsername({
    required String username,
    required String password,
  }) async {
    try {
      final authEmail = '$username@${AppConstants.authDomain}';
      return await _auth.signInWithEmailAndPassword(
        email: authEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signUp({
    required String fullname,
    required String mobile,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Create user
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Send verification email (don't await to prevent blocking)
      unawaited(userCredential.user?.sendEmailVerification());

      // 3. Save user data
      await FirebaseFirestore.instance
          .collection("user")
          .doc(userCredential.user?.uid)
          .set({
        'fullname': fullname,
        'mobile': mobile,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false,
        'emailVerified': false,
      });

      // 4. Sign out silently (handle any potential errors)
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint('Silent sign-out error: $e');
      }

      return; // Success case
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      debugPrint('Signup error: $e');
      throw 'Account creation failed. Please try again.';
    }
  }

  Future<AppUser> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        await _auth.signOut();
        throw Exception('Email not verified');
      }

      return await getUserData(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<AppUser> getUserData(String uid) async {
    final doc = await _firestore.collection('user').doc(uid).get();
    AppConstants.log.e(doc.data());
    AppConstants.log.e(uid);
    return AppUser.fromFirestore(doc);
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password too weak';
      case 'user-not-found':
      case 'wrong-password':
        return 'Invalid credentials';
      case 'user-disabled':
        return 'Account disabled';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  /// Password Reset Method
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }
}
