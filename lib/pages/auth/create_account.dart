// views/create_account_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../controller/create_account_controller.dart';

class CreateAccountView extends StatelessWidget {
  final CreateAccountController _controller = Get.put(CreateAccountController());
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;

  CreateAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Account Creation",
          style: TextStyle(fontSize: 18, letterSpacing: 2),
        ),
        backgroundColor: Colors.indigo.shade200,
      ),
      body: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 12, left: 30, right: 30),
        child: Obx(() => ListView(
          children: [
            Lottie.asset("assets/animations/signup.json", height: 150),

            // Full Name Field
            _buildTextField(
              controller: _fullNameController,
              label: "Full Name",
              icon: Icons.person,
            ),
            const SizedBox(height: 20),

            // Email Field
            _buildTextField(
              controller: _emailController,
              label: "Email",
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Mobile Field
            _buildTextField(
              controller: _mobileController,
              label: "Mobile Number",
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Password Field
            Obx(() => _buildTextField(
              controller: _passController,
              label: "Password",
              icon: Icons.password,
              obscureText: _obscurePassword.value,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword.value ? Icons.visibility : Icons.visibility_off,
                  color: Colors.indigo.shade300,
                ),
                onPressed: () => _obscurePassword.toggle(),
              ),
            )),
            const SizedBox(height: 20),

            // Confirm Password Field
            Obx(() => _buildTextField(
              controller: _confirmPassController,
              label: "Confirm Password",
              icon: Icons.password,
              obscureText: _obscureConfirmPassword.value,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword.value ? Icons.visibility : Icons.visibility_off,
                  color: Colors.indigo.shade300,
                ),
                onPressed: () => _obscureConfirmPassword.toggle(),
              ),
            )),
            const SizedBox(height: 20),

            // Sign Up Button
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: _controller.isLoading.value ? null : () => _controller.signUp(
                  fullname: _fullNameController.text.trim(),
                  mobile: _mobileController.text.trim(),
                  email: _emailController.text.trim(),
                  password: _passController.text.trim(),
                  confirmPassword: _confirmPassController.text.trim(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  disabledBackgroundColor: Colors.indigo.withValues(alpha: 0.5),
                ),
                child: _controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Create Business Account",
                  style: TextStyle(letterSpacing: 2, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sign In Button
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.indigo),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size.fromHeight(45),
              ),
              onPressed: () => Get.back(),
              child: const Text(
                "Login",
                style: TextStyle(color: Colors.indigo, letterSpacing: 2),
              ),
            ),
            const SizedBox(height: 30),
          ],
        )),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.indigo),
        prefixIcon: Icon(icon, color: Colors.indigo.shade300),
        suffixIcon: suffixIcon,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.indigo, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Colors.indigo),
          borderRadius: BorderRadius.all(Radius.circular(13)),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(13)),
        ),
      ),
    );
  }
}