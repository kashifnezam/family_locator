import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_room/pages/home.dart';
import 'package:family_room/pages/splash_screen.dart';
import 'package:family_room/utils/constants.dart';
import 'package:family_room/utils/custom_alert.dart';
import 'package:family_room/utils/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

Future<void> signUp(String fullname, String mobile, String email, String pass,
    BuildContext context) async {
  if (fullname.isEmpty || mobile.isEmpty || email.isEmpty || pass.isEmpty) {
    CustomAlert.errorAlert(
      title: "Account Creation Failed",
      context,
      "Please fill all the details",
    );
    return;
  }

  try {
    // 1. Create user with email/password
    final UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: pass);

    // 2. Send email verification
    await userCredential.user?.sendEmailVerification();

    // 3. Store additional user data in Firestore
    await FirebaseFirestore.instance
        .collection("user")
        .doc(userCredential.user?.uid)
        .set({
      "fullname": fullname,
      "mobile": mobile,
      "email": email,
      "dataCreated": DateTime.now().toString(),
      "userID": userCredential.user?.uid,
      "isAdmin": false,
      "deviceId": DeviceInfo.deviceId ?? '',
      "macAd": DeviceInfo.macAddress ?? '',
      "ipAddress": DeviceInfo.ipAddress ?? '',
    });

    // 5. Sign out and go back (optional)
    await FirebaseAuth.instance.signOut();
    Get.back();
    // 4. Show success message
    CustomAlert.successAlert(
      context,
      "Account created successfully. Please check your email for verification.",
    );
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    switch (e.code) {
      case 'email-already-in-use':
        errorMessage = "This email is already registered.";
        break;
      case 'invalid-email':
        errorMessage = "Please enter a valid email address.";
        break;
      case 'weak-password':
        errorMessage = "Password should be at least 6 characters.";
        break;
      default:
        errorMessage = "Account creation failed: ${e.message}";
    }
    CustomAlert.errorAlert(
      title: "Account Creation Failed",
      context,
      errorMessage,
    );
  } catch (e) {
    CustomAlert.errorAlert(
      title: "Account Creation Failed",
      context,
      e.toString(),
    );
  }
}

Future<void> login(String email, String pass, BuildContext context) async {
  if (email.isEmpty || pass.isEmpty) {
    Get.back();
    CustomAlert.errorAlert(
      title: "Login Failed",
      context,
      "Either email or password is empty",
    );
    return;
  }

  try {
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: pass);

    // Check if email is verified
    if (userCredential.user?.emailVerified ?? false) {
      // Update device info if fields are missing
      await _updateDeviceInfo(userCredential.user!.uid, context);
      Get.to(() => const SplashScreen());
    } else {
      // Option 1: Force verification before login
      await FirebaseAuth.instance.signOut();
      Get.back();
      CustomAlert.errorAlert(
        title: "Email Not Verified",
        context,
        "Please verify your email first. Check your inbox.",
      );

      // Option 2: Allow login but show warning
      // CustomAlert.warningAlert(
      //   title: "Email Not Verified",
      //   context,
      //   "Please verify your email for full access.",
      // );
      // Get.to(() => const Home());
    }
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        errorMessage = "Invalid email or password.";
        break;
      case 'user-disabled':
        errorMessage = "This account has been disabled.";
        break;
      default:
        errorMessage = "Login failed: ${e.message}";
    }
    Get.back();
    CustomAlert.errorAlert(
      title: "Login Failed",
      context,
      errorMessage,
    );
  } catch (e) {
    Get.back();
    CustomAlert.errorAlert(
      title: "Login Failed",
      context,
      e.toString(),
    );
  }
}

Future<void> resetPassword(String email, BuildContext context) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    CustomAlert.successAlert(
      context,
      "Password reset link sent to $email",
    );
  } on FirebaseAuthException catch (e) {
    String errorMessage = "Failed to send reset link";
    if (e.code == 'user-not-found') {
      errorMessage = "No account found with this email";
    } else if (e.code == 'too-many-requests') {
      errorMessage = "Too many requests. Please try again later";
    }

    CustomAlert.errorAlert(
      title: "Error",
      context,
      "$errorMessage: ${e.message}",
    );
  } catch (e) {
    CustomAlert.errorAlert(
      title: "Error",
      context,
      "Failed to send reset link: ${e.toString()}",
    );
  }
}

Future<void> _updateDeviceInfo(String userId, BuildContext context) async {
  try{
  final userDoc = FirebaseFirestore.instance.collection("user").doc(userId);
  final docSnapshot = await userDoc.get();
 AppConstants.log.e(docSnapshot);
  if (docSnapshot.exists) {
    final data = docSnapshot.data() as Map<String, dynamic>? ?? {};
    AppConstants.log.e(data);

    await userDoc.update({
      'deviceId': DeviceInfo.deviceId ?? '',
      'macAd': DeviceInfo.macAddress ?? '',
      'ipAddress': DeviceInfo.ipAddress ?? '',
      'lastLogin': DateTime.now().toString(), // Optional: track last login time
    });
  }} catch (e){
    Get.back();
    CustomAlert.errorAlert(
      title: "Error",
      context,
      "Failed to update data: ${e.toString()}",
    );
  }
}
