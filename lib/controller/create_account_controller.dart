import 'package:family_room/utils/custom_alert.dart';
import 'package:get/get.dart';

import '../service/auth_service_modal.dart';

class CreateAccountController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> signUp({
    required String fullname,
    required String mobile,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      isLoading(true);
      errorMessage('');

      // Validation
      if (fullname.isEmpty || mobile.isEmpty || email.isEmpty || password.isEmpty) {
        throw 'Please fill all fields';
      }

      if (!email.isEmail) {
        throw 'Please enter a valid email';
      }

      if (password != confirmPassword) {
        throw 'Passwords do not match';
      }

      if (password.length < 6) {
        throw 'Password must be at least 6 characters';
      }

      // CustomAlert.loadAlert("Please wait...");
      // Create account
      await _authService.signUp(
        fullname: fullname,
        mobile: mobile,
        email: email,
        password: password,
      );

      Get.back();
      CustomAlert.successAlert(
        'Account created! Please verify your email before logging in.',
        title: 'Success',
      );
    } catch (e) {
      errorMessage(e.toString());
      CustomAlert.errorAlert(
        e.toString(),
        title: 'Sign Up Failed',
      );
    } finally {
      isLoading(false);
      // CustomAlert.dismissAlert();
    }
  }
}