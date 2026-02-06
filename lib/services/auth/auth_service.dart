import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Firebase Authentication service wrapper.
///
/// Provides a unified interface for email/password, Google, and Apple
/// sign-in methods. All methods delegate to [FirebaseAuth] and the
/// corresponding platform sign-in packages.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------------------------------------------------------------------
  // Email / Password
  // ---------------------------------------------------------------------------

  /// Signs in an existing user with [email] and [password].
  ///
  /// Throws a [FirebaseAuthException] on failure (wrong password, user not
  /// found, etc.). Callers should catch and map the error code to a
  /// user-friendly Florida message.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Creates a new user account with [email] and [password].
  ///
  /// Throws a [FirebaseAuthException] if the email is already in use or the
  /// password is too weak.
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  /// Initiates the Google Sign-In flow and authenticates with Firebase.
  ///
  /// Returns `null` if the user cancels the sign-in dialog. Otherwise returns
  /// the resulting [UserCredential].
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      // User cancelled the sign-in flow.
      return null;
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  // ---------------------------------------------------------------------------
  // Apple Sign-In
  // ---------------------------------------------------------------------------

  /// Initiates the Apple Sign-In flow and authenticates with Firebase.
  ///
  /// Requests email and full-name scopes. Apple only returns the name on the
  /// *first* sign-in, so the caller should persist it immediately.
  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    return _auth.signInWithCredential(oauthCredential);
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  /// Signs the current user out of Firebase and any federated providers.
  ///
  /// Clears both the Firebase session and the cached Google Sign-In account
  /// so the next sign-in shows the account picker again.
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      // Google sign-out can fail if the user never signed in with Google.
      // This is safe to ignore.
      developer.log(
        'GoogleSignIn.signOut failed (non-fatal): $e',
        name: 'AuthService',
      );
    }
    await _auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // Password Reset
  // ---------------------------------------------------------------------------

  /// Sends a password-reset email to [email].
  ///
  /// Firebase silently succeeds even if the email is not registered (to avoid
  /// leaking user enumeration), so callers should always show a success
  /// message.
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ---------------------------------------------------------------------------
  // Streams & Getters
  // ---------------------------------------------------------------------------

  /// Stream of auth state changes (user sign-in / sign-out).
  ///
  /// Emits the current [User] on sign-in and `null` on sign-out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Stream of ID token changes (token refresh events).
  ///
  /// Used to keep the Riverpod auth token provider in sync with Firebase.
  /// Emits on sign-in, sign-out, and automatic token refresh.
  Stream<User?> get idTokenChanges => _auth.idTokenChanges();

  /// The currently signed-in Firebase user, or `null` if signed out.
  User? get currentUser => _auth.currentUser;
}
