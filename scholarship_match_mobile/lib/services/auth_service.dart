// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
// class AuthService {
//   // final FirebaseAuth _auth = FirebaseAuth.instance;
//   // final GoogleSignIn _googleSignIn = GoogleSignIn();

//   // Phone Authentication
//   Future<void> verifyPhoneNumber({
//     required String phoneNumber,
//     required Function(String) onCodeSent,
//     required Function(String) onError,
//   }) async {
//     throw UnimplementedError('Phone authentication is not implemented yet');
//     // try {
//     //   await _auth.verifyPhoneNumber(
//     //     phoneNumber: phoneNumber,
//     //     verificationCompleted: (PhoneAuthCredential credential) async {
//     //       await _auth.signInWithCredential(credential);
//     //     },
//     //     verificationFailed: (FirebaseAuthException e) {
//     //       onError(e.message ?? 'Verification failed');
//     //     },
//     //     codeSent: (String verificationId, int? resendToken) {
//     //       onCodeSent(verificationId);
//     //     },
//     //     codeAutoRetrievalTimeout: (String verificationId) {},
//     //   );
//     // } catch (e) {
//     //   onError(e.toString());
//     // }
//   }

//   Future<UserCredential?> verifyOTP({
//     required String verificationId,
//     required String smsCode,
//   }) async {
//     throw UnimplementedError('Phone authentication is not implemented yet');
//     // try {
      
//     //   PhoneAuthCredential credential = PhoneAuthProvider.credential(
//     //     verificationId: verificationId,
//     //     smsCode: smsCode,
//     //   );
//     //   return await _auth.signInWithCredential(credential);
//     // } catch (e) {
//     //   return null;
//     // }
//   }

//   // // Google Sign In
//   // Future<UserCredential?> signInWithGoogle() async {
//   //   try {
//   //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//   //     if (googleUser == null) return null;

//   //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//   //     final credential = GoogleAuthProvider.credential(
//   //       accessToken: googleAuth.accessToken,
//   //       idToken: googleAuth.idToken,
//   //     );

//   //     return await _auth.signInWithCredential(credential);
//   //   } catch (e) {
//   //     return null;
//   //   }
//   // }

//   // // Apple Sign In
//   // Future<UserCredential?> signInWithApple() async {
//   //   try {
//   //     final appleCredential = await SignInWithApple.getAppleIDCredential(
//   //       scopes: [
//   //         AppleIDAuthorizationScopes.email,
//   //         AppleIDAuthorizationScopes.fullName,
//   //       ],
//   //     );

//   //     final oauthCredential = OAuthProvider('apple.com').credential(
//   //       idToken: appleCredential.identityToken,
//   //       accessToken: appleCredential.authorizationCode,
//   //     );

//   //     return await _auth.signInWithCredential(oauthCredential);
//   //   } catch (e) {
//   //     return null;
//   //   }
//   // }

//   // Sign Out
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }

//   // Get current user
//   dynamic get currentUser => null;

//   // Auth state changes stream
//   Stream<dynamic> get authStateChanges => Stream.value(null);
// } 