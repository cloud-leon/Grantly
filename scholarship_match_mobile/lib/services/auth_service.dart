import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'profile_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  AuthService._internal();

  // Temporarily comment out Firebase implementation
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProfileService _profileService = ProfileService();
  final Duration verificationTimeout = const Duration(seconds: 30);

  // Phone Authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification if possible
          try {
            await _auth.signInWithCredential(credential);
          } catch (e) {
            onError(e.toString());
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout
          print('Auto-retrieval timeout');
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // Verify OTP
  Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // Create the credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with the credential
      return await _auth.signInWithCredential(credential)
          .timeout(verificationTimeout);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.message}');
      throw Exception(e.message);
    } on TimeoutException {
      throw Exception('Verification timed out. Please try again.');
    } catch (e) {
      print('Error in verifyOTP: $e');
      throw Exception('Failed to verify OTP');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> getAccessToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      // Get the ID token
      final idToken = await user.getIdToken(true);  // force refresh
      if (idToken != null) {  // Add null check
        print('Got Firebase token: ${idToken.substring(0, 10)}...'); // Log partial token
      }
      return idToken;
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  // Get current user's Firebase UID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  Future<Map<String, dynamic>> checkAuthStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'isAuthenticated': false};
      }

      // Check for profile
      final profileService = ProfileService();
      final profile = await profileService.getProfile();

      // Check if profile exists and is complete
      final hasCompleteProfile = profile != null && profile.isComplete;

      return {
        'isAuthenticated': true,
        'uid': user.uid,
        'hasProfile': hasCompleteProfile,  // Only true if profile is complete
        'profile': profile,
      };
    } catch (e) {
      print('Error checking auth status: $e');
      return {'isAuthenticated': false};
    }
  }
}