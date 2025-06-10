import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../api/firebase_auth.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  @override
  Widget build(BuildContext context) {
    TextEditingController fullNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController mobileController = TextEditingController();
    TextEditingController passConroller = TextEditingController();
    TextEditingController cnfPassController = TextEditingController();

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
        child: ListView(
          children: [
            Lottie.asset("assets/animations/signup.json", height: 150),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo, width: 2),
                ),
                floatingLabelAlignment: FloatingLabelAlignment.center,
                labelText: "Full Name",
                labelStyle: const TextStyle(fontSize: 18, color: Colors.indigo),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.indigo.shade300,
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
                  borderSide: BorderSide(style: BorderStyle.solid),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                floatingLabelAlignment: FloatingLabelAlignment.center,
                labelText: "Email",
                labelStyle: const TextStyle(fontSize: 18, color: Colors.indigo),
                prefixIcon: Icon(
                  Icons.email_rounded,
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
                  borderSide: BorderSide(style: BorderStyle.solid),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: mobileController,
              decoration: InputDecoration(
                floatingLabelAlignment: FloatingLabelAlignment.center,
                labelText: "Mobile Number",
                labelStyle: const TextStyle(fontSize: 18, color: Colors.indigo),
                prefixIcon: Icon(
                  Icons.numbers,
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
                  borderSide: BorderSide(style: BorderStyle.solid),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: passConroller,
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
                  borderSide: BorderSide(style: BorderStyle.solid),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: cnfPassController,
              decoration: InputDecoration(
                floatingLabelAlignment: FloatingLabelAlignment.center,
                labelText: "Confirm Password",
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
                  borderSide: BorderSide(style: BorderStyle.solid),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  // Get.back();
                  String fullname = fullNameController.text.trim();
                  String email = emailController.text.trim();
                  var mobile = mobileController.text.trim();
                  var pass = passConroller.text.trim();
                  signUp(fullname, mobile, email, pass, context);
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Colors.indigo,
                  ),
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 18, letterSpacing: 2, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              decoration:
              BoxDecoration(border: Border.all(color: Colors.indigo), borderRadius: BorderRadius.all(Radius.circular(20),),),
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Colors.white,
                  ),
                ),
                child: const Text(
                  "Sign In",
                  style: TextStyle(
                      color: Colors.indigo, fontSize: 18, letterSpacing: 2),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
