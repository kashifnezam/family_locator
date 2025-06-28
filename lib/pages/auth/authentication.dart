// views/authentication_view.dart
import 'package:family_room/pages/auth/create_account.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../controller/auth_controller.dart';

class AuthenticationView extends StatelessWidget {
  final AuthController _authController=  Get.put(AuthController());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  AuthenticationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Account Login",
          style: TextStyle(fontSize: 18, letterSpacing: 2),
        ),
        backgroundColor: Colors.indigo.shade200,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 2, left: 38, right: 38),
        child: Obx(() => ListView(
          children: [
            Lottie.asset("assets/animations/login.json", height: 300),

            // Email Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: const TextStyle(color: Colors.indigo),
                prefixIcon: Icon(Icons.email, color: Colors.indigo.shade300),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.indigo),
                  borderRadius: BorderRadius.all(Radius.circular(13)),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Password Field
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: const TextStyle(color: Colors.indigo),
                prefixIcon: Icon(Icons.password, color: Colors.indigo.shade300),
                suffixIcon: Icon(Icons.visibility, color: Colors.indigo.shade300),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.indigo),
                  borderRadius: BorderRadius.all(Radius.circular(13)),
                ),
              ),
            ),

            // Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    if (_emailController.text.isEmpty) {
                      Get.snackbar("Error", "Please enter your email first");
                      return;
                    }
                    _authController.resetPassword(_emailController.text.trim());
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.indigo.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Login Button
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: _authController.isLoading.value
                    ? null
                    : () => _authController.login(
                  _emailController.text.trim(),
                  _passController.text.trim(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  disabledBackgroundColor: Colors.indigo.withOpacity(0.5),
                ),
                child: _authController.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),

            // Create Account Button
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.indigo),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size.fromHeight(45),
              ),
              onPressed: () => Get.to(()=>CreateAccountView()),
              child: const Text(
                "Create an Account",
                style: TextStyle(color: Colors.indigo),
              ),
            ),
          ],
        )),
      ),
    );
  }
}