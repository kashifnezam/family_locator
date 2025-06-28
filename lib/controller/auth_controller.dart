import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_room/utils/constants.dart';
import 'package:family_room/utils/custom_alert.dart';
import 'package:get/get.dart';
import '../pages/splash_screen.dart';
import '../service/auth_service_modal.dart';
import '../service/device_service_modal.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final DeviceService _deviceService = DeviceService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxBool isUsernameAvailable = false.obs;
  final RxString usernameError = ''.obs;

  Future<void> checkUsernameAvailability(String username) async {
    try {
      if (username.length < 4) {
        isUsernameAvailable.value = false;
        usernameError.value = 'Username too short';
        return;
      }

      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
        isUsernameAvailable.value = false;
        usernameError.value = 'Only letters, numbers and _ allowed';
        return;
      }

      final available = await _authService.isUsernameAvailable(username);
      isUsernameAvailable.value = available;
      usernameError.value = available ? '' : 'Username already taken';
    } catch (e) {
      isUsernameAvailable.value = false;
      usernameError.value = 'Error checking username';
    }
  }

  Future<void> loginWithUsername(String username, String password) async {
    try {
      isLoading(true);
      errorMessage('');

      final userCredential = await _authService.loginWithUsername(
        username: username,
        password: password,
      );

      final user = await _authService.getUserData(userCredential.user!.uid);
      await _deviceService.updateDeviceInfo(user.uid);

      Get.to(() => const SplashScreen());
    } catch (e) {
      errorMessage(e.toString());
      CustomAlert.errorAlert(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> createMemberWithUsername({
    required String username,
    required String fullname,
    required String password,
    String? mobile,
    String? email,
  }) async {
    try {
      isLoading(true);
      errorMessage('');

      // First check username availability
      final available = await _authService.isUsernameAvailable(username);
      if (!available) throw 'Username already taken';

      // Prepare user data
      final userData = {
        'fullname': fullname,
        'role': 'member',
        'mobile': mobile,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': false, // Since we're using username
        'username': username, // Store the actual username
      };

      await _authService.registerWithUsername(
        username: username,
        password: password,
        userData: userData,
      );
      Get.back();
      CustomAlert.successAlert('Member account created successfully');
    } catch (e) {
      errorMessage(e.toString());
      CustomAlert.errorAlert(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      errorMessage('');

      final user = await _authService.login(email, password);
      await _deviceService.updateDeviceInfo(user.uid);

      Get.to(() => const SplashScreen()); // Or your home route
    } catch (e) {
      AppConstants.log.e(e.toString());
      errorMessage(e.toString());
      CustomAlert.errorAlert(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> signUp({
    required String fullname,
    required String mobile,
    required String email,
    required String password,
  }) async {
    try {
      isLoading(true);
      errorMessage('');

      await _authService.signUp(
        fullname: fullname,
        mobile: mobile,
        email: email,
        password: password,
      );

      CustomAlert.successAlert(
        'Account created. Please verify your email.',
      );
      Get.back(); // Return to login screen
    } catch (e) {
      errorMessage(e.toString());
      CustomAlert.errorAlert(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading(true);
      await _authService.sendPasswordResetEmail(email);
      CustomAlert.successAlert('Password reset link sent to $email');
    } catch (e) {
      errorMessage(e.toString());
      CustomAlert.errorAlert(e.toString());
    } finally {
      isLoading(false);
    }
  }
}
