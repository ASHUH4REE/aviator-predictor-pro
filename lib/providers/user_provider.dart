import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Streams the signed-in user profile and exposes common mutations.
class UserProvider extends ChangeNotifier {
  UserProvider() {
    AuthService.instance.authChanges().listen((user) {
      _sub?.cancel();
      if (user == null) {
        _profile = null;
        notifyListeners();
        return;
      }
      _sub = FirestoreService.instance.userStream(user.uid).listen((p) {
        _profile = p;
        notifyListeners();
      });
    });
  }

  AppUser? _profile;
  StreamSubscription<AppUser?>? _sub;

  AppUser? get profile => _profile;
  bool get isAdmin => _profile?.isAdmin ?? false;

  Future<void> updateName(String name) async {
    final AppUser? p = _profile;
    if (p == null) return;
    await FirestoreService.instance
        .updateUser(p.uid, <String, dynamic>{'name': name});
  }

  Future<void> updateAvatar(String url) async {
    final AppUser? p = _profile;
    if (p == null) return;
    await FirestoreService.instance
        .updateUser(p.uid, <String, dynamic>{'avatar': url});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
