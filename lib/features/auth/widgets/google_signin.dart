import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class GoogleSignInButton extends StatefulWidget {
  final Future<void> Function() onSignIn;

  const GoogleSignInButton({
    super.key,
    required this.onSignIn,
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    // Prevent multiple taps while loading
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await widget.onSignIn();
    } catch (e) {
      // Show an error snackbar if the sign-in fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          )
        : SizedBox(
            width: double.infinity, // Makes button full width
            height: 50,
            child: SignInButton(
              Buttons.google,
              text: "Sign up with Google",
              onPressed: _handlePress,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
  }
}
