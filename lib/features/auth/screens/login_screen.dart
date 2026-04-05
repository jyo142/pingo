import 'package:flutter/material.dart';
import 'package:pingo/core/constants/image_assets.dart';
import 'package:pingo/features/auth/data/auth_service.dart';
import 'package:pingo/features/auth/widgets/google_signin.dart';
import 'package:pingo/features/auth/widgets/login_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();

  Future<void> _handleGoogleSignIn() async {
    try {
      await _authService.nativeGoogleSignIn();
    } catch (e) {
      // Errors are usually handled inside the button widget we made,
      // but you can add iadditional logic here if needed.
      debugPrint("Login Error: $e");
      rethrow; // Pass error back to the button to stop loading state
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Background Layer
          const PingoBackground(),

          // 📱 Foreground UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  // Logo
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.25),
                          blurRadius: 30,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Image.asset(ImageAssets.logo, height: 300),
                  ),

                  const SizedBox(height: 16),

                  const Spacer(),

                  // Button section (push to bottom like modern apps)
                  GoogleSignInButton(onSignIn: _handleGoogleSignIn),

                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
