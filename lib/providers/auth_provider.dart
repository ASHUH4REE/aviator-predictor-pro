import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

enum AuthStatus { unknown, signedOut, signedIn }

/// Listens to FirebaseAuth state and exposes a simple status flag.
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    AuthService.instance.authChanges().listen(_onAuth);
  }

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _errorMessage;
  bool _busy = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _busy;

  void _onAuth(User? user) {
    _user = user;
    _status = user == null ? AuthStatus.signedOut : AuthStatus.signedIn;
    notifyListeners();
  }

  void _setBusy(bool v) {
    _busy = v;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> registerEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setBusy(true);
    _setError(null);
    try {
      await AuthService.instance.registerWithEmail(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Registration failed.');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> loginEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setBusy(true);
    _setError(null);
    try {
      await AuthService.instance.loginWithEmail(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Login failed.');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> loginGoogle() async {
    _setBusy(true);
    _setError(null);
    try {
      final UserCredential? cred = await AuthService.instance.signInWithGoogle();
      return cred != null;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> sendReset(String email) async {
    _setBusy(true);
    _setError(null);
    try {
      await AuthService.instance.sendPasswordReset(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Failed to send reset email.');
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> logout() => AuthService.instance.logout();
}
