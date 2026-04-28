import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/user_model.dart';

/// Wraps FirebaseAuth + Firestore profile creation. UI never touches FirebaseAuth directly.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  static const String _kRememberMe = 'remember_me';
  static const String _kRememberedEmail = 'remembered_email';

  /// Stream of FirebaseAuth state — used by the splash screen / providers.
  Stream<User?> authChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // Email + password
  // ---------------------------------------------------------------------------

  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await cred.user!.updateDisplayName(name);

    final AppUser profile = AppUser(
      uid: cred.user!.uid,
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      createdAt: DateTime.now(),
      walletBalance: AppConstants.signupBonus,
    );

    await _db
        .collection(FirestorePaths.users)
        .doc(profile.uid)
        .set(profile.toMap());

    return profile;
  }

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool(_kRememberMe, true);
      await prefs.setString(_kRememberedEmail, email.trim());
    } else {
      await prefs.remove(_kRememberMe);
      await prefs.remove(_kRememberedEmail);
    }
    return cred;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<({bool remember, String? email})> readRememberedEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return (
      remember: prefs.getBool(_kRememberMe) ?? false,
      email: prefs.getString(_kRememberedEmail),
    );
  }

  // ---------------------------------------------------------------------------
  // Google sign in
  // ---------------------------------------------------------------------------

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    if (account == null) return null; // user dismissed
    final GoogleSignInAuthentication auth = await account.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
    final UserCredential cred = await _auth.signInWithCredential(credential);
    await _ensureProfile(cred.user!);
    return cred;
  }

  // ---------------------------------------------------------------------------
  // Phone OTP
  // ---------------------------------------------------------------------------

  Future<void> sendPhoneCode({
    required String phoneE164,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException error) onError,
    void Function(PhoneAuthCredential cred)? onAutoVerified,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneE164,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential cred) {
        onAutoVerified?.call(cred);
      },
      verificationFailed: onError,
      codeSent: (String verificationId, int? _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> confirmPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final UserCredential cred = await _auth.signInWithCredential(credential);
    await _ensureProfile(cred.user!);
    return cred;
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Lazily create a Firestore profile for OAuth/phone users.
  Future<void> _ensureProfile(User user) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _db.collection(FirestorePaths.users).doc(user.uid);
    final DocumentSnapshot<Map<String, dynamic>> snap = await ref.get();
    if (snap.exists) return;
    final AppUser profile = AppUser(
      uid: user.uid,
      name: user.displayName ?? 'Player',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      createdAt: DateTime.now(),
      walletBalance: AppConstants.signupBonus,
      avatar: user.photoURL,
    );
    await ref.set(profile.toMap());
  }
}
