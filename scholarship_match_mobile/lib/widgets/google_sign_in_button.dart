import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/services/auth_service.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const GoogleSignInButton({
    super.key,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
      ),
      onPressed: () async {
        try {
          final authService = AuthService();
          final result = await authService.signInWithGoogle();
          
          if (result != null && result.user != null) {
            onSuccess?.call();
          } else {
            onError?.call();
          }
        } catch (e) {
          onError?.call();
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/google_logo.png',
            height: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Continue with Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 