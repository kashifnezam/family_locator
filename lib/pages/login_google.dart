import 'package:family_locator/utils/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class GoogleSignIn extends StatelessWidget {
  const GoogleSignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Other widgets (if needed)
            SignInButton(
              Buttons.Google,
              onPressed: () {
                googleLogin();
              },
            ),
          ],
        ),
      ),
    );
  }
}
