import 'package:family_room/utils/custom_alert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../api/firebase_auth.dart';
import 'create_account.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

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
        child: ListView(
          children: [
            Lottie.asset("assets/animations/login.json", height: 300),

            // Email Field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                floatingLabelAlignment: FloatingLabelAlignment.center,
                labelText: "Email",
                labelStyle: const TextStyle(fontSize: 18, color: Colors.indigo),
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.indigo.shade300,
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.indigo),
                  borderRadius: BorderRadius.all(
                    Radius.circular(13),
                  ),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(13),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Password Field
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(
                floatingLabelAlignment: FloatingLabelAlignment.center,
                labelText: "Password",
                labelStyle: const TextStyle(fontSize: 18, color: Colors.indigo),
                prefixIcon: Icon(
                  Icons.password,
                  color: Colors.indigo.shade300,
                ),
                suffixIcon: Icon(
                  Icons.visibility,
                  color: Colors.indigo.shade300,
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.indigo),
                  borderRadius: BorderRadius.all(
                    Radius.circular(13),
                  ),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(13),
                  ),
                ),
              ),
            ),

            // Forgot Password & Resend Verification
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    if (emailController.text.isEmpty) {
                      Get.snackbar("Error", "Please enter your email first");
                      return;
                    }
                    // Add your forgot password logic here
                    resetPassword(emailController.text.trim(), context);
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.indigo.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 20),

            // Login Button
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed:() async {
                        CustomAlert.loadAlert(context, "Please Wait..");
                        await login(
                          emailController.text.trim(),
                          passController.text.trim(),
                          context,
                        );
                      },
                style: ButtonStyle(
                  backgroundColor: const WidgetStatePropertyAll(Colors.indigo),
                ),
                child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),

            // Create Account Button
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.indigo),
                  borderRadius: BorderRadius.circular(20)),
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const CreateAccount());
                },
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.white),
                ),
                child: const Text(
                  "Create an Account",
                  style: TextStyle(
                      color: Colors.indigo, fontSize: 18, letterSpacing: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
