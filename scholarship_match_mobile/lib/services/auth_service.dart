// Temporarily remove Firebase imports
// import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Temporarily comment out Firebase implementation
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // Phone Authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    // Temporarily disable phone auth
    throw UnimplementedError('Phone authentication is not implemented yet');
  }

  // Verify OTP
  Future<dynamic> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    // Temporarily disable OTP verification
    throw UnimplementedError('OTP verification is not implemented yet');
  }

  // Sign Out
  Future<void> signOut() async {
    // Temporarily disable sign out
    throw UnimplementedError('Sign out is not implemented yet');
  }

  // Get current user
  dynamic get currentUser => null;

  // Auth state changes stream
  Stream<dynamic> get authStateChanges => Stream.value(null);
}