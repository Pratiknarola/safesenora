import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseAuthListener {
  verificationCodeSent(int forceResendingToken);

  onLoginUserVerified(FirebaseUser currentUser);

  onError(String message);
}