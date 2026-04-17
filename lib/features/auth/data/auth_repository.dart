import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// The currently signed-in user, or `null` if not authenticated.
  User? get currentUser => _firebaseAuth.currentUser;

  /// A stream that emits whenever the authentication state changes.
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  /// Signs in with an email and password.
  ///
  /// Throws a [FirebaseAuthException] if the sign-in fails.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Creates a new account with an email and password.
  ///
  /// Throws a [FirebaseAuthException] if the sign-up fails.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Signs in with Google.
  ///
  /// Returns `null` if the user cancelled the sign-in flow.
  /// Throws a [FirebaseAuthException] if the sign-in fails.
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Signs out from both Firebase and Google.
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
